/// Trạng thái upload media
enum MediaUploadStatus {
  local,
  pendingUpload,
  uploaded,
  failed;

  static MediaUploadStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'LOCAL':
        return MediaUploadStatus.local;
      case 'PENDING_UPLOAD':
        return MediaUploadStatus.pendingUpload;
      case 'UPLOADED':
        return MediaUploadStatus.uploaded;
      case 'FAILED':
        return MediaUploadStatus.failed;
      default:
        return MediaUploadStatus.local;
    }
  }

  String toDbString() {
    switch (this) {
      case MediaUploadStatus.local:
        return 'LOCAL';
      case MediaUploadStatus.pendingUpload:
        return 'PENDING_UPLOAD';
      case MediaUploadStatus.uploaded:
        return 'UPLOADED';
      case MediaUploadStatus.failed:
        return 'FAILED';
    }
  }
}

class LocalMarkerMedia {
  final String localMarkerMediaId;
  final String localMarkerId;
  final String type;
  final String localPath;
  final String? remoteUrl;
  final int? fileSizeBytes;
  final String? mimeType;
  final String uploadStatus;
  final DateTime createdAt;

  const LocalMarkerMedia({
    required this.localMarkerMediaId,
    required this.localMarkerId,
    this.type = 'IMAGE',
    required this.localPath,
    this.remoteUrl,
    this.fileSizeBytes,
    this.mimeType,
    this.uploadStatus = 'LOCAL',
    required this.createdAt,
  });

  factory LocalMarkerMedia.fromMap(Map<String, dynamic> map) {
    return LocalMarkerMedia(
      localMarkerMediaId: map['localMarkerMediaId'] as String,
      localMarkerId: map['localMarkerId'] as String,
      type: map['type'] as String? ?? 'IMAGE',
      localPath: map['localPath'] as String,
      remoteUrl: map['remoteUrl'] as String?,
      fileSizeBytes: map['fileSizeBytes'] as int?,
      mimeType: map['mimeType'] as String?,
      uploadStatus: map['uploadStatus'] as String? ?? 'LOCAL',
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'localMarkerMediaId': localMarkerMediaId,
      'localMarkerId': localMarkerId,
      'type': type,
      'localPath': localPath,
      'remoteUrl': remoteUrl,
      'fileSizeBytes': fileSizeBytes,
      'mimeType': mimeType,
      'uploadStatus': uploadStatus,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  LocalMarkerMedia copyWith({
    String? localMarkerMediaId,
    String? localMarkerId,
    String? type,
    String? localPath,
    String? remoteUrl,
    int? fileSizeBytes,
    String? mimeType,
    String? uploadStatus,
    DateTime? createdAt,
  }) {
    return LocalMarkerMedia(
      localMarkerMediaId: localMarkerMediaId ?? this.localMarkerMediaId,
      localMarkerId: localMarkerId ?? this.localMarkerId,
      type: type ?? this.type,
      localPath: localPath ?? this.localPath,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      mimeType: mimeType ?? this.mimeType,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
