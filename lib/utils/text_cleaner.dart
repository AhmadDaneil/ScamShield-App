class TextCleaner{
  static String clean(String text){
    text = text.toLowerCase();

    text = text.replaceAll(
      RegExp(r'http\s+|www\s+'),
      '',
    );

    text = text.replaceAll(RegExp(r'<.*?>'),
    ''
    );

    text = text.replaceAll('#','');

    text = text.replaceAll(RegExp(r'[!?]{2,}'),
    '!',
    );

    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    return text;
  }
  
  static List<double> extractFeatures(String text) {
    final words = text.split(' ');

    final textLength = words.length.toDouble();

    final exclamationCount = 
        text.split('').where((c) => c == '!').length.toDouble();

    final questionCount = 
        text.split('').where((c) => c == '?').length.toDouble();

    final upperCount =
        text.split('').where((c) => c == c.toUpperCase() && c.trim().isNotEmpty).length;
    final uppercaseRatio =
        text.isNotEmpty ? upperCount / text.length : 0.0;

    final urlCount = text.split('').where((c) => c == 'h').length.toDouble();

    final digitCount =
        text.split('').where((c) => RegExp(r'\d').hasMatch(c)).length;
    final digitRatio = text.isNotEmpty ? digitCount / text.length : 0.0;

    return [
      textLength,
      exclamationCount,
      questionCount,
      uppercaseRatio,
      urlCount,
      digitRatio,
    ];
  }
}