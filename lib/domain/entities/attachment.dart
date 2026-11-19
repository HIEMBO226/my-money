class Attachment {
  const Attachment({
    required this.id,
    required this.transactionId,
    required this.filePath,
    required this.fileName,
    required this.createdAt,
    this.mimeType,
  });

  final String id;
  final String transactionId;
  final String filePath;
  final String fileName;
  final String? mimeType;
  final DateTime createdAt;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Attachment &&
        other.id == id &&
        other.transactionId == transactionId &&
        other.filePath == filePath &&
        other.fileName == fileName &&
        other.mimeType == mimeType &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        transactionId,
        filePath,
        fileName,
        mimeType,
        createdAt,
      );
}
