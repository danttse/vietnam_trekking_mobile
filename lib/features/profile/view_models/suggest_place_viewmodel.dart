import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/services/offline_store.dart';
import '../../../core/services/user_api_service.dart';
import '../../../core/services/trekking_upload_service.dart';
import '../../../core/network/api_error_handler.dart';

class SuggestPlaceViewModel extends ChangeNotifier {
  final UserApiService _api;
  final TrekkingUploadService _uploads;
  final TextEditingController placeNameController = TextEditingController();
  final TextEditingController gpsController = TextEditingController();
  final TextEditingController altitudeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];
  final Map<String, String> _provinceIds = {};
  final Map<String, String> _uploadedImages = {};
  final String _operationId = List.generate(
    16,
    (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
  String _selectedProvince = '';
  String _selectedDifficulty = 'Khó';
  bool _isLoading = false;
  bool _disposed = false;
  String? error;

  SuggestPlaceViewModel({UserApiService? api, TrekkingUploadService? uploads})
    : _api = api ?? UserApiService(),
      _uploads = uploads ?? TrekkingUploadService() {
    loadProvinces();
  }
  List<File> get selectedImages => _selectedImages;
  String get selectedProvince => _selectedProvince;
  String get selectedDifficulty => _selectedDifficulty;
  List<String> get provinces => _provinceIds.keys.toList();
  List<String> get difficulties => const ['Dễ', 'Trung bình', 'Khó', 'Cực khó'];
  bool get isLoading => _isLoading;

  Future<void> loadProvinces() async {
    try {
      final data = await _api.getProvinceVisits();
      if (_disposed) return;
      _provinceIds.clear();
      for (final province in data['provinces'] as List) {
        _provinceIds[province['name'] as String] =
            province['provinceId'] as String;
      }
      if (!_provinceIds.containsKey(_selectedProvince))
        _selectedProvince = provinces.isEmpty ? '' : provinces.first;
      error = null;
    } catch (e) {
      if (!_disposed) error = ApiErrorHandler.handle(e);
    }
    if (!_disposed) notifyListeners();
  }

  void setProvince(String? value) {
    if (value != null) {
      _selectedProvince = value;
      notifyListeners();
    }
  }

  void setDifficulty(String? value) {
    if (value != null) {
      _selectedDifficulty = value;
      notifyListeners();
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled())
        throw StateError('Vui lòng bật GPS.');
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied)
        permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever)
        throw StateError('Vui lòng cấp quyền vị trí.');
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      if (_disposed) return;
      gpsController.text = '${position.latitude}, ${position.longitude}';
      altitudeController.text = position.altitude.toStringAsFixed(0);
      error = null;
    } catch (e) {
      if (!_disposed) error = ApiErrorHandler.handle(e);
    }
    if (!_disposed) notifyListeners();
  }

  Future<void> pickImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (!_disposed && file != null && _selectedImages.length < 20) {
      _selectedImages.add(File(file.path));
      notifyListeners();
    }
  }

  Future<void> pickMultiImages() async {
    final files = await _picker.pickMultiImage(imageQuality: 80);
    if (_disposed) return;
    _selectedImages.addAll(
      files.take(20 - _selectedImages.length).map((f) => File(f.path)),
    );
    notifyListeners();
  }

  void removeImage(int index) {
    _selectedImages.removeAt(index);
    notifyListeners();
  }

  Future<bool> submit() async {
    if (_isLoading) return false;
    final coords = gpsController.text
        .split(',')
        .map((s) => double.tryParse(s.trim()))
        .toList();
    if (placeNameController.text.trim().length < 2 ||
        descriptionController.text.trim().length < 10 ||
        !_provinceIds.containsKey(_selectedProvince) ||
        coords.length != 2 ||
        coords.any((n) => n == null || !n.isFinite) ||
        coords[0]!.abs() > 90 ||
        coords[1]!.abs() > 180) {
      error = 'Nhập tên từ 2 ký tự, mô tả từ 10 ký tự, chọn tỉnh và tọa độ dạng vĩ độ, kinh độ.';
      notifyListeners();
      return false;
    }
    _isLoading = true;
    error = null;
    notifyListeners();
    try {
      final urls = <String>[];
      for (final image in _selectedImages) {
        final url =
            _uploadedImages[image.path] ??
            await _uploads.uploadImage(image.path, 'PLACE_SUGGESTION');
        _uploadedImages[image.path] = url;
        urls.add(url);
      }
      final payload = {
        'clientOperationId': _operationId,
        'provinceId': _provinceIds[_selectedProvince],
        'proposedName': placeNameController.text.trim(),
        'description': descriptionController.text.trim(),
        'location': {
          'type': 'Point',
          'coordinates': [coords[1], coords[0]],
        },
        'difficulty': [
          'EASY',
          'MODERATE',
          'HARD',
          'EXPERT',
        ][difficulties.indexOf(_selectedDifficulty)],
        'images': urls,
      };

      // Luu offline vao local_contributions va outbox truoc de dam bao an toan du lieu
      String? localOwner;
      try {
        localOwner = await OfflineStore.currentOwner();
        if (localOwner != null && localOwner.isNotEmpty) {
          final db = await DatabaseHelper.instance.database;
          final now = DateTime.now().toUtc().toIso8601String();
          await db.insert(
            'local_contributions',
            {
              'localContributionId': _operationId,
              'userId': localOwner,
              'type': 'PLACE_SUGGESTION',
              'payload': jsonEncode(payload),
              'serverStatus': 'PENDING_REVIEW',
              'syncStatus': 'PENDING',
              'createdAt': now,
              'updatedAt': now,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          await db.insert(
            'offline_outbox',
            {
              'operationId': _operationId,
              'ownerId': localOwner,
              'method': 'POST',
              'path': '/contributions/places',
              'body': jsonEncode({...payload, '_contributionRef': _operationId}),
              'createdAt': now,
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      } catch (_) {}

      final response = await _api.trekking.post(
        '/contributions/places',
        data: payload,
      );

      // Cap nhat SYNCED va don dep outbox khi gui thanh cong len server
      try {
        if (localOwner != null && localOwner.isNotEmpty) {
          final db = await DatabaseHelper.instance.database;
          final respData = response.data is Map ? response.data as Map : null;
          final inner = respData?['data'] is Map ? respData!['data'] as Map : respData;
          final serverId = inner?['placeSuggestionId'] ??
              inner?['id'] ??
              respData?['placeSuggestionId'] ??
              respData?['id'];

          await db.update(
            'local_contributions',
            {
              'syncStatus': 'SYNCED',
              if (serverId != null) 'serverContributionId': serverId.toString(),
              'lastSyncedAt': DateTime.now().toUtc().toIso8601String(),
            },
            where: 'localContributionId = ?',
            whereArgs: [_operationId],
          );
          await db.delete(
            'offline_outbox',
            where: 'operationId = ? AND ownerId = ?',
            whereArgs: [_operationId, localOwner],
          );
        }
      } catch (_) {}

      return true;
    } catch (e) {
      if (!_disposed) error = ApiErrorHandler.handle(e);
      return false;
    } finally {
      if (!_disposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    placeNameController.dispose();
    gpsController.dispose();
    altitudeController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
