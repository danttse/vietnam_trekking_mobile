import 'dart:io';

void main() {
  final file = File('lib/features/auth/data/vietnam_map_paths.dart');
  String content = file.readAsStringSync();
  
  // Cache paths in paint
  if (!content.contains('_cachedPaths')) {
    content = content.replaceFirst(
      'void paint(Canvas canvas, Size size) {\n      final paths=buildPaths(size);',
      '''static Size? _cachedSize;
    static List<Path>? _cachedPaths;

    @override
    void paint(Canvas canvas, Size size) {
      if (_cachedPaths == null || _cachedSize != size) {
        _cachedPaths = buildPaths(size);
        _cachedSize = size;
      }
      final paths = _cachedPaths!;'''
    );
  }
  
  // Fix shouldRepaint
  content = content.replaceFirst(
    'bool shouldRepaint(CustomPainter oldDelegate) {\n      return true;\n    }',
    'bool shouldRepaint(CustomPainter oldDelegate) {\n      return false;\n    }'
  );

  file.writeAsStringSync(content);
  print('Thanh cong fix lag!');
}
