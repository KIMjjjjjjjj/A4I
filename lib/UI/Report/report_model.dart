class Report {
  late final DateTime date;
  final Map<String, double> emotionData;
  final String? feedback;
  final List<String>? keywords;
  final List<String>? topics;
  final Map<String, List<double>>? emotionIntensityData;

  Report({
    required this.date,
    required this.emotionData,
    this.feedback,
    this.keywords,
    this.topics,
    this.emotionIntensityData,
  });

  factory Report.fromMap(DateTime date, Map<String, dynamic> map) {
    return Report(
      date: date,
      emotionData: map['emotionData'] != null
          ? (map['emotionData'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, (value as num).toDouble()),
          )
          : {},
      feedback: map['feedback'],
      keywords: map['keywords'] != null ? List<String>.from(map['keywords']) : null,
      topics: map['topics'] != null ? List<String>.from(map['topics']) : null,
      emotionIntensityData: map['emotionIntensityData'] != null
          ? (map['emotionIntensityData'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, (value as List).map((e) => (e as num).toDouble()).toList(),),
          )
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      if (feedback != null) 'emotionData': emotionData,
      if (feedback != null) 'feedback': feedback,
      if (keywords != null) 'keywords': keywords,
      if (topics != null) 'topics': topics,
      if (emotionIntensityData != null)
        'emotionIntensityData': emotionIntensityData!.map(
              (key, value) => MapEntry(key, value),
        ),
    };
  }
}
