class Order {
  final String? id;
  final String customerName;
  final String? customerAddress;
  final double latitude;
  final double longitude;
  final String bookId;
  final String? createdAt;
  final String status;
  final double totalPrice;
  final String? paymentMethod;

  Order({
    this.id,
    required this.customerName,
    this.customerAddress,
    required this.latitude,
    required this.longitude,
    required this.bookId,
    this.createdAt,
    this.status = 'pending',
    this.totalPrice = 0.0,
    this.paymentMethod,
  });

  Map<String, dynamic> toJson() {
    return {
      'customer_name': customerName,
      'customer_address': customerAddress,
      'latitude': latitude,
      'longitude': longitude,
      'book_id': bookId,
      'total_price': totalPrice,
      'payment_method': paymentMethod,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerName: json['customer_name'] ?? '',
      customerAddress: json['customer_address'],
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      bookId: json['book_id'] ?? '',
      createdAt: json['created_at'],
      status: json['status'] ?? 'pending',
      totalPrice: (json['total_price'] ?? 0.0).toDouble(),
      paymentMethod: json['payment_method'],
    );
  }
}
