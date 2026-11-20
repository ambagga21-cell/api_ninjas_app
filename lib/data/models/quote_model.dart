class QuoteModel {
  final String quote;
  final String author;
  final String category;

  QuoteModel({
    required this.quote,
    required this.author,
    required this.category,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      quote: json['quote'] as String? ?? 'Нет текста цитаты',
      author: json['author'] as String? ?? 'Неизвестный автор',
      category: json['category'] as String? ?? 'general',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quote': quote,
      'author': author,
      'category': category,
    };
  }
}
