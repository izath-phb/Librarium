class Book {
  final String id;
  final String title;
  final String author;
  final double price;
  final String? description;
  final String? imageUrl;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.price,
    this.description,
    this.imageUrl,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      price: json['price'].toDouble(),
      description: json['description'],
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'price': price,
      'description': description,
      'image_url': imageUrl,
    };
  }
}
