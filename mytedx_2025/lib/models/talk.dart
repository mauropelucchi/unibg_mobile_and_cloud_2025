class Talk {
  final String title;
  final String details;
  final String mainSpeaker;
  final String url;
  final List<String> keyPhrases;

  Talk.fromJSON(Map<String, dynamic> jsonMap)
      : title = jsonMap['title'],
        details = jsonMap['description'],
        mainSpeaker = (jsonMap['speakers'] ?? ""),
        url = (jsonMap['url'] ?? ""),
        keyPhrases = (jsonMap['comprehend_analysis']['KeyPhrases'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
}