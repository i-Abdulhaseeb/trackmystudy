class ViewerNote {
  const ViewerNote({
    required this.id,
    required this.page,
    required this.text,
    this.bookmark = false,
  });

  final String id;
  final int page;
  final String text;
  final bool bookmark;

  Map<String, Object> toJson() => {
    'id': id,
    'page': page,
    'text': text,
    'bookmark': bookmark,
  };

  factory ViewerNote.fromJson(Map<String, dynamic> json) => ViewerNote(
    id: json['id'] as String,
    page: json['page'] as int,
    text: json['text'] as String,
    bookmark: json['bookmark'] as bool? ?? false,
  );
}
