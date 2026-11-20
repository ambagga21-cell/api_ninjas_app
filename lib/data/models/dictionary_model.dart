class DictionaryModel {
  final String word;
  final String definition;
  final bool valid;

  DictionaryModel({
    required this.word,
    required this.definition,
    required this.valid,
  });

  factory DictionaryModel.fromJson(Map<String, dynamic> json) {
    return DictionaryModel(
      word: json['word'] as String? ?? '',
      definition: json['definition'] as String? ?? 'Определение не найдено',
      valid: json['valid'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'definition': definition,
      'valid': valid,
    };
  }
}
