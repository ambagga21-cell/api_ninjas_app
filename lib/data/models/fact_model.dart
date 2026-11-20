class FactModel {
  final String fact;

  FactModel({
    required this.fact,
  });

  factory FactModel.fromJson(Map<String, dynamic> json) {
    return FactModel(
      fact: json['fact'] as String? ?? 'Нет описания факта',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fact': fact,
    };
  }
}
