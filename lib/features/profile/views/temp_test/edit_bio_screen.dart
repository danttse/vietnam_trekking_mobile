import 'package:flutter/material.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/services/auth_event_bus.dart';
import '../../../../core/services/token_storage.dart';
import '../../../auth/data/exceptions/auth_exception.dart';
import '../../../auth/repository/auth_repository_impl.dart';

class EditBioScreen extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final String initialBio;
  final String? avatarUrl;
  final bool isPro;

  const EditBioScreen({
    super.key,
    this.initialName = '',
    this.initialEmail = '',
    this.initialBio = '',
    this.avatarUrl,
    this.isPro = false,
  });

  @override
  State<EditBioScreen> createState() => _EditBioScreenState();
}

class _EditBioScreenState extends State<EditBioScreen> {
  static const Color accentColor = Color(0xFFE07A5F);
  static const int maxBioLength = 500;

  late final TextEditingController _bioController;
  late final AuthRepositoryImpl _repository;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.initialBio);
    _bioController.addListener(() => setState(() {}));

    final tokenStorage = const SecureTokenStorage();
    final eventBus = AuthEventBus();
    final dio = DioClient.createDio(tokenStorage: tokenStorage, eventBus: eventBus);
    _repository = AuthRepositoryImpl(dio: dio, tokenStorage: tokenStorage);
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final bio = _bioController.text.trim();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _repository.updateBio(bio);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật bio thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      // Trả về user mới nhất để caller có thể refresh
      Navigator.pop(context, user);
    } on AuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Đã có lỗi xảy ra. Vui lòng thử lại';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentLength = _bioController.text.length;

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
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Icon(Icons.arrow_back, size: 20, color: colorScheme.onSurface),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Chỉnh Sửa Bio',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User info card
                      if (widget.initialName.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Row(
                            children: [
                              ClipOval(
                                child: widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty
                                    ? Image.network(widget.avatarUrl!, width: 48, height: 48, fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => _avatarFallback(colorScheme))
                                    : _avatarFallback(colorScheme),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(widget.initialName,
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                                    if (widget.initialEmail.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(widget.initialEmail,
                                          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),

                      Text(
                        'GIỚI THIỆU BẢN THÂN (BIO)',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _errorMessage != null
                                ? colorScheme.error.withValues(alpha: 0.5)
                                : colorScheme.onSurfaceVariant.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TextField(
                              controller: _bioController,
                              maxLines: 5,
                              maxLength: maxBioLength,
                              style: TextStyle(color: colorScheme.onSurface, fontSize: 13.5, height: 1.45),
                              decoration: InputDecoration(
                                hintText: 'Nhập tiểu sử giới thiệu bản thân...',
                                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 13.5),
                                border: InputBorder.none,
                                counterText: '',
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$currentLength / $maxBioLength',
                              style: TextStyle(
                                color: currentLength >= maxBioLength
                                    ? colorScheme.error
                                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Error message
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _errorMessage!,
                          style: TextStyle(color: colorScheme.error, fontSize: 13),
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

  Widget _avatarFallback(ColorScheme colorScheme) {
    return Container(
      width: 48, height: 48,
      color: colorScheme.surfaceContainerHighest,
      child: Icon(Icons.person, size: 28, color: colorScheme.onSurfaceVariant),
    );
  }
}
