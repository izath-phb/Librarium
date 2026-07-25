class Comment {
  final String id;
  final String bookId;
  final String userName;
  final String text;
  final String? parentId;
  final String createdAt;

  Comment({
    required this.id,
    required this.bookId,
    required this.userName,
    required this.text,
    this.parentId,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      bookId: json['book_id'],
      userName: json['user_name'],
      text: json['text'],
      parentId: json['parent_id'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book_id': bookId,
      'user_name': userName,
      'text': text,
      'parent_id': parentId,
      'created_at': createdAt,
    };
  }
}
