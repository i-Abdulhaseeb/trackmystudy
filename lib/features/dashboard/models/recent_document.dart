class RecentDocument {
  final String? fileId;
  final String name;
  final String course;
  final String type;
  final String lastOpened;

  const RecentDocument({
    this.fileId,
    required this.name,
    required this.course,
    required this.type,
    required this.lastOpened,
  });
}
