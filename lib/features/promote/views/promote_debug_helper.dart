import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'promote_screen.dart';

/// Helper widget để test màn Promote trong development
/// KHÔNG sử dụng trong production!
class PromoteDebugHelper extends StatelessWidget {
  const PromoteDebugHelper({super.key});

  Future<void> _resetAndShowPromote(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('has_seen_promote');
    
    if (!context.mounted) return;
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const PromoteScreen(),
      ),
    );
  }

  Future<bool> _checkPromoteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_seen_promote') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 Promote Screen Debug'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.preview,
                size: 80,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 24),
              const Text(
                'Debug Tool - Promote Screen',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              FutureBuilder<bool>(
                future: _checkPromoteStatus(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final hasSeen = snapshot.data!;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Trạng thái hiện tại:',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                hasSeen ? Icons.check_circle : Icons.cancel,
                                color: hasSeen ? Colors.green : Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                hasSeen ? 'Đã xem Promote' : 'Chưa xem Promote',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: hasSeen ? Colors.green : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => _resetAndShowPromote(context),
                icon: const Icon(Icons.refresh),
                label: const Text('🔄 Reset & Xem màn Promote'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PromoteScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.visibility),
                label: const Text('👁️ Xem trực tiếp (không reset)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Hướng dẫn:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '1. Nhấn "Reset & Xem" để reset flag và xem màn Promote\n'
                '2. Hoặc nhấn "Xem trực tiếp" để preview mà không reset\n'
                '3. Test các nút Skip và Next trong màn Promote',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Route helper để dễ dàng navigate
class PromoteDebugRoute {
  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => const PromoteDebugHelper(),
    );
  }
}
