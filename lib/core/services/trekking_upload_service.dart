import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import 'trekking_catalog_service.dart';

/// Upload media with signed parameters; the storage request never carries JWT.
class TrekkingUploadService {
  final Dio api;
  final Dio storage;
  TrekkingUploadService({Dio? apiClient, Dio? storageClient})
    : api = apiClient ?? TrekkingCatalogService().dio,
      storage =
          storageClient ??
          Dio(
            BaseOptions(
              sendTimeout: const Duration(minutes: 2),
              receiveTimeout: const Duration(minutes: 2),
            ),
          );

  Future<String> uploadImage(String path, String purpose) async {
    final extension = p.extension(path).toLowerCase();
    final mime = switch (extension) {
      '.jpg' || '.jpeg' => 'image/jpeg',
      '.png' => 'image/png',
      '.webp' => 'image/webp',
      '.gif' => 'image/gif',
      _ => throw ArgumentError('Định dạng ảnh không được hỗ trợ.'),
    };
    final response = await api.post(
      '/uploads/presign',
      data: {
        'purpose': purpose,
        'fileName': p.basename(path),
        'contentType': mime,
        'fileSizeBytes': await File(path).length(),
      },
    );
    final signed = response.data['data'] as Map;
    final fields = Map<String, dynamic>.from(signed['uploadParams'] as Map);
    fields['file'] = await MultipartFile.fromFile(
      path,
      filename: p.basename(path),
    );
    final uploaded = await storage.post(
      signed['uploadUrl'] as String,
      data: FormData.fromMap(fields),
    );
    final url = uploaded.data['secure_url'] as String?;
    if (url == null || Uri.tryParse(url)?.scheme != 'https')
      throw StateError('Không nhận được URL ảnh sau khi tải lên.');
    return url;
  }
}
