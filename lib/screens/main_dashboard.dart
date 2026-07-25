import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'home_tab.dart';
import 'explore_tab.dart';
import 'library_tab.dart';
import 'profile_tab.dart';
import '../widgets/book_search_delegate.dart';
class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeTab(),
    ExploreTab(),
    LibraryTab(),
    ProfileTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFF9F9F9),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books_outlined),
            activeIcon: Icon(Icons.library_books),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange[300],
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontSize: 10.sp),
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex != 3 ? FloatingActionButton(
        onPressed: () {
          showSearch(context: context, delegate: BookSearchDelegate());
        },
        backgroundColor: Colors.orange[300],
        child: const Icon(Icons.search, color: Colors.white),
      ) : null,
    );
  }
}
