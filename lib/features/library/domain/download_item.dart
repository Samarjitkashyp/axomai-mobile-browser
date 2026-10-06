/// Model representing a download record in the SQLite database.
class DownloadItem {
  final int? id;
  final String fileName;
  final String url;
  final String filePath;
  final int fileSize;
  final DateTime createdAt;

  const DownloadItem({
    this.id,
    required this.fileName,
    required this.url,
    required this.filePath,
    required this.fileSize,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'file_name': fileName,
      'url': url,
      'file_path': filePath,
      'file_size': fileSize,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory DownloadItem.fromMap(Map<String, dynamic> map) {
    return DownloadItem(
      id: map['id'] as int?,
      fileName: (map['file_name'] as String?) ?? '',
      url: (map['url'] as String?) ?? '',
      filePath: (map['file_path'] as String?) ?? '',
      fileSize: (map['file_size'] as int?) ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['created_at'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}
