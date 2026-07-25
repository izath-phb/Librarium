import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';

class AddressSelectionScreen extends StatefulWidget {
  final String currentAddress;

  const AddressSelectionScreen({super.key, required this.currentAddress});

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  late TextEditingController _addressController;
  final MapController _mapController = MapController();
  final Dio _dio = Dio();
  
  // Default to Jakarta
  LatLng _selectedLocation = const LatLng(-6.200000, 106.816666);
  bool _isLoading = false;
  Timer? _debounce;
  List<dynamic> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.currentAddress);
    
    // If there's an initial address, try to geocode it (simplified)
    if (widget.currentAddress.isNotEmpty) {
      _searchAddress(widget.currentAddress);
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _searchAddress(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _recommendations = [];
      });
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': 5,
        },
        options: Options(
          headers: {'User-Agent': 'LibrariumApp/1.0'}, // Required by Nominatim
        )
      );

      if (response.statusCode == 200 && response.data.isNotEmpty) {
        setState(() {
          _recommendations = response.data;
          
          // Auto-move map to first result
          final first = response.data[0];
          final lat = double.parse(first['lat']);
          final lon = double.parse(first['lon']);
          _selectedLocation = LatLng(lat, lon);
        });
        
        _mapController.move(_selectedLocation, 16.0);
      } else {
        setState(() {
          _recommendations = [];
        });
      }
    } catch (e) {
      print('Geocoding error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _reverseGeocode(LatLng position) async {
    setState(() => _isLoading = true);
    
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': position.latitude,
          'lon': position.longitude,
          'format': 'json',
        },
        options: Options(
          headers: {'User-Agent': 'LibrariumApp/1.0'},
        )
      );

      if (response.statusCode == 200 && response.data != null) {
        final address = response.data['display_name'];
        if (address != null) {
          setState(() {
            _addressController.text = address;
          });
        }
      }
    } catch (e) {
      print('Reverse geocoding error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onAddressChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      _searchAddress(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color navyColor = Color(0xFF1E1E50);
    const Color bgColor = Color(0xFFFAF9F6);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: navyColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pilih Lokasi',
          style: TextStyle(
            color: navyColor,
            fontWeight: FontWeight.w900,
            fontSize: 16.sp,
            fontFamily: 'serif',
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Interactive Map Area
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedLocation,
                    initialZoom: 14.0,
                    onTap: (tapPosition, point) {
                      setState(() {
                        _selectedLocation = point;
                      });
                      _reverseGeocode(point);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.librarium',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedLocation,
                          width: 80,
                          height: 80,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                Positioned(
                  top: 16.h,
                  right: 16.w,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.my_location, color: navyColor),
                    onPressed: () {
                      _mapController.move(_selectedLocation, 16.0);
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Address Details Form
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail Alamat',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                    color: navyColor,
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: _addressController,
                  onChanged: _onAddressChanged,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Alamat Lengkap',
                    hintText: 'Ketik alamat Anda...',
                    labelStyle: TextStyle(color: Colors.black54, fontSize: 12.sp),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(color: navyColor),
                    ),
                    suffixIcon: const Icon(Icons.search, color: Colors.grey),
                  ),
                ),
                if (_recommendations.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(top: 4.h),
                    constraints: BoxConstraints(maxHeight: 140.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _recommendations.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _recommendations[index];
                        return ListTile(
                          title: Text(item['display_name'] ?? '', style: TextStyle(fontSize: 12.sp)),
                          leading: const Icon(Icons.location_on, color: Colors.red, size: 20),
                          onTap: () {
                            FocusScope.of(context).unfocus(); // Close keyboard
                            final lat = double.parse(item['lat']);
                            final lon = double.parse(item['lon']);
                            setState(() {
                              _selectedLocation = LatLng(lat, lon);
                              _addressController.text = item['display_name'];
                              _recommendations = [];
                            });
                            _mapController.move(_selectedLocation, 16.0);
                          },
                        );
                      },
                    ),
                  ),
                SizedBox(height: 16.h),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Catatan untuk kurir (opsional)',
                    labelStyle: TextStyle(color: Colors.black54, fontSize: 12.sp),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(color: navyColor),
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_addressController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Alamat tidak boleh kosong')),
                        );
                        return;
                      }
                      // Return the new address to checkout screen
                      Navigator.pop(context, _addressController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: navyColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    child: Text(
                      'Simpan Alamat',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
