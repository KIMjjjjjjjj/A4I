class Report {
  final Map<String, double> emotionData; // key : 일반화된 감정 value : 카테고리 비율
  final String feedback;                 // GPT 요약 피드백
  final List<String> keywords;           // 상위 3개의 키워드
  final List<String> topics;             // 상위 3개의 토픽

  Report({
    required this.emotionData,
    required this.feedback,
    required this.keywords,
    required this.topics,
  });

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      emotionData: Map<String, double>.from(map['emotionData'] ?? {}),
      feedback: map['feedback'] ?? '',
      keywords: List<String>.from(map['keywords'] ?? []),
      topics: List<String>.from(map['topics'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'emotionData': emotionData,
      'feedback': feedback,
      'keywords': keywords,
      'topics': topics,
    };
  }
}
