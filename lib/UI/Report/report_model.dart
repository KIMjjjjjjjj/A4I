class Report {

  final Map<String, double> emotionData;
  final String? feedback;
  final List<String>? keywords;
  final List<String>? topics;
  final Map<String, List<double>>? emotionIntensityData;

  Report({
    required this.emotionData,
    this.feedback,
    this.keywords,
    this.topics,
    this.emotionIntensityData,
  });

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      emotionData: Map<String, double>.from(map['emotionData'] ?? {}),
      feedback: map['feedback'],
      keywords: map['keywords'] != null ? List<String>.from(map['keywords']) : null,
      topics: map['topics'] != null ? List<String>.from(map['topics']) : null,
      emotionIntensityData: map['emotionIntensityData'] != null
          ? (map['emotionIntensityData'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(
          key,
          List<double>.from(value),
        ),
      )
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'emotionData': emotionData,
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
