import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/services/auth_event_bus.dart';
import '../../../../core/services/token_storage.dart';
import '../../../auth/data/exceptions/auth_exception.dart';
import '../../../auth/repository/auth_repository_impl.dart';

class ChangeAvatarScreen extends StatefulWidget {
  final String? initialAvatarUrl;

  const ChangeAvatarScreen({super.key, this.initialAvatarUrl});

  @override
  State<ChangeAvatarScreen> createState() => _ChangeAvatarScreenState();
}

class _ChangeAvatarScreenState extends State<ChangeAvatarScreen> {
  static const Color accentColor = Color(0xFFE07A5F);

  final ImagePicker _picker = ImagePicker();
  late final AuthRepositoryImpl _repository;

  File? _pickedFile;       // file đã chọn nhưng chưa upload
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final tokenStorage = const SecureTokenStorage();
    final eventBus = AuthEventBus();
    final dio = DioClient.createDio(tokenStorage: tokenStorage, eventBus: eventBus);
    _repository = AuthRepositoryImpl(dio: dio, tokenStorage: tokenStorage);
  }

  // ── Chọn ảnh ──────────────────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (picked == null) return;
      setState(() {
        _pickedFile = File(picked.path);
        _errorMessage = null;
      });
    } catch (e) {
      setState(() => _errorMessage = 'Không thể chọn ảnh. Vui lòng thử lại');
    }
  }

  // ── Upload ─────────────────────────────────────────────────────────────────

  Future<void> _handleSave() async {
    if (_pickedFile == null) {
      setState(() => _errorMessage = 'Vui lòng chọn ảnh trước khi lưu');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _repository.uploadAvatar(_pickedFile!.path);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật ảnh đại diện!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, user);
    } on AuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Upload thất bại. Vui lòng thử lại';
      });
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                        border: Border.all(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2)),
                      ),
                      child: Icon(Icons.arrow_back, size: 20, color: colorScheme.onSurface),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Đổi Ảnh Đại Diện',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Avatar preview
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 140, height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                                  width: 3,
                                ),
                              ),
                              child: ClipOval(child: _buildPreview(colorScheme)),
                            ),
                            Positioned(
                              right: 2, bottom: 2,
                              child: Container(
                                width: 38, height: 38,
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: colorScheme.surface, width: 3),
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Show picked file indicator
                      if (_pickedFile != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Ảnh đã chọn — nhấn "Lưu" để upload',
                          style: TextStyle(fontSize: 12, color: colorScheme.primary),
                          textAlign: TextAlign.center,
                        ),
                      ],

                      const SizedBox(height: 36),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'TÙY CHỌN TẢI ẢNH',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Options
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.15)),
                        ),
                        child: Column(
                          children: [
                            _buildOptionTile(
                              icon: Icons.camera_alt_outlined,
                              title: 'Chụp ảnh mới',
                              colorScheme: colorScheme,
                              onTap: () => _pickImage(ImageSource.camera),
                            ),
                            Divider(height: 1, thickness: 1, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.1)),
                            _buildOptionTile(
                              icon: Icons.photo_library_outlined,
                              title: 'Chọn từ thư viện',
                              colorScheme: colorScheme,
                              onTap: () => _pickImage(ImageSource.gallery),
                            ),
                          ],
                        ),
                      ),

                      // Error message
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          _errorMessage!,
                          style: TextStyle(color: colorScheme.error, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Save button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Lưu thay đổi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(ColorScheme colorScheme) {
    if (_pickedFile != null) {
      return Image.file(_pickedFile!, fit: BoxFit.cover);
    }
    if (widget.initialAvatarUrl != null && widget.initialAvatarUrl!.isNotEmpty) {
      return Image.network(
        widget.initialAvatarUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _avatarFallback(colorScheme),
      );
    }
    return _avatarFallback(colorScheme);
  }

  Widget _avatarFallback(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(Icons.person, size: 70, color: colorScheme.onSurfaceVariant),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required ColorScheme colorScheme,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: accentColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title, style: TextStyle(color: colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w600)),
            ),
            Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6), size: 20),
          ],
        ),
      ),
    );
  }
}
