class RiddleModel {
  final String title;
  final String question;
  final String answer;

  RiddleModel({
    required this.title,
    required this.question,
    required this.answer,
  });

  factory RiddleModel.fromJson(Map<String, dynamic> json) {
    return RiddleModel(
      title: json['title'] as String? ?? 'Загадка',
      question: json['question'] as String? ?? 'Нет текста вопроса',
      answer: json['answer'] as String? ?? 'Ответ не указан',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'question': question,
      'answer': answer,
    };
  }
}
