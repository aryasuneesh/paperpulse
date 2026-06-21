String _sanitizeUtf16(String input) {
  final units = input.codeUnits;
  final result = <int>[];
  for (var i = 0; i < units.length; i++) {
    final unit = units[i];
    if (unit >= 0xD800 && unit <= 0xDBFF) {
      // High surrogate — valid only if followed by a low surrogate.
      if (i + 1 < units.length &&
          units[i + 1] >= 0xDC00 &&
          units[i + 1] <= 0xDFFF) {
        result.add(unit);
        result.add(units[++i]);
      }
      // else: lone high surrogate — drop it
    } else if (unit >= 0xDC00 && unit <= 0xDFFF) {
      // Lone low surrogate — drop it
    } else {
      result.add(unit);
    }
  }
  return String.fromCharCodes(result);
}

class Highlight {
  final String id;
  final String userId;
  final String paperId;
  final String textContent;
  final String color; // e.g., hex string
  final int? pageNumber;
  final String annotationName;
  final List<String> tags;
  final DateTime createdAt;
  final String readerType;     // 'pdf' | 'html'
  final String? searchText;    // HTML only: full sentence for window.find()
  final String annotationType; // 'highlight' | 'underline' | 'strikethrough' | 'squiggly'

  Highlight({
    required this.id,
    required this.userId,
    required this.paperId,
    required this.textContent,
    required this.color,
    this.pageNumber,
    required this.annotationName,
    this.tags = const [],
    required this.createdAt,
    this.readerType = 'pdf',
    this.searchText,
    this.annotationType = 'highlight',
  });

  factory Highlight.fromJson(Map<String, dynamic> json) {
    return Highlight(
      id: json['id'] as String,
      userId: json['userId'] as String,
      paperId: json['paperId'] as String,
      textContent: _sanitizeUtf16(json['textContent'] as String),
      color: json['color'] as String,
      pageNumber: json['pageNumber'] as int?,
      annotationName: json['annotationName'] as String? ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      readerType: json['readerType'] as String? ?? 'pdf',
      searchText: json['searchText'] as String?,
      annotationType: json['annotationType'] as String? ?? 'highlight',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'paperId': paperId,
      'textContent': textContent,
      'color': color,
      'pageNumber': pageNumber,
      'annotationName': annotationName,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'readerType': readerType,
      'searchText': searchText,
      'annotationType': annotationType,
    };
  }

  Highlight copyWith({
    String? id,
    String? userId,
    String? paperId,
    String? textContent,
    String? color,
    int? pageNumber,
    String? annotationName,
    List<String>? tags,
    DateTime? createdAt,
    String? readerType,
    String? searchText,
    String? annotationType,
  }) {
    return Highlight(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      paperId: paperId ?? this.paperId,
      textContent: textContent ?? this.textContent,
      color: color ?? this.color,
      pageNumber: pageNumber ?? this.pageNumber,
      annotationName: annotationName ?? this.annotationName,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      readerType: readerType ?? this.readerType,
      searchText: searchText ?? this.searchText,
      annotationType: annotationType ?? this.annotationType,
    );
  }
}
