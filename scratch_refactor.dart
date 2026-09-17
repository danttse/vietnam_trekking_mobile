import 'dart:io';

void main() {
  final file = File('lib/features/auth/data/vietnam_map_paths.dart');
  String content = file.readAsStringSync();

  final startIndex = content.indexOf(RegExp(r'List<Path> buildPaths\(Size size\)[\s]*\{'));
  final endIndex = content.indexOf(RegExp(r'return paths;[\s]*\}'), startIndex);

  if (startIndex == -1 || endIndex == -1) {
    print('Khong tim thay ham buildPaths hoac return paths;');
    return;
  }

  // Tách phần đầu và cuối
  final headerMatch = RegExp(r'List<Path> buildPaths\(Size size\)[\s]*\{').firstMatch(content);
  final footerMatch = RegExp(r'return paths;[\s]*\}').firstMatch(content);
  
  final header = content.substring(0, startIndex);
  final footer = content.substring(endIndex + footerMatch!.group(0)!.length);
  
  final body = content.substring(startIndex + headerMatch!.group(0)!.length, endIndex);
  
  // Tách theo paths.add(path);
  final segments = body.split('paths.add(path);');
  
  StringBuffer newCode = StringBuffer();
  newCode.write(header);
  newCode.write('List<Path> buildPaths(Size size) {\n');
  newCode.write('      final List<Path> paths = [];\n');
  
  int chunkCount = 0;
  List<String> chunkCalls = [];
  
  // Group 3 paths per chunk
  for (int i = 0; i < segments.length - 1; i += 3) {
    chunkCount++;
    chunkCalls.add('      paths.addAll(_buildPathsChunk\$chunkCount(size));\n');
  }
  
  for (String call in chunkCalls) {
    newCode.write(call);
  }
  newCode.write('      return paths;\n    }\n\n');
  
  // Write chunks
  chunkCount = 0;
  for (int i = 0; i < segments.length - 1; i += 3) {
    chunkCount++;
    newCode.write('    List<Path> _buildPathsChunk\$chunkCount(Size size) {\n');
    newCode.write('      final List<Path> paths = [];\n');
    newCode.write('      Path path = Path();\n');
    
    for (int j = 0; j < 3 && (i + j) < segments.length - 1; j++) {
      String segment = segments[i + j];
      segment = segment.replaceAll(RegExp(r'Paint paint = Paint\(\);'), '');
      if (j == 0 && i == 0) {
        segment = segment.replaceAll(RegExp(r'final List<Path> paths = \[\];'), '');
      }
      newCode.write(segment);
      newCode.write('      paths.add(path);\n');
    }
    
    newCode.write('      return paths;\n    }\n\n');
  }

  newCode.write(footer);

  file.writeAsStringSync(newCode.toString());
  print('Thanh cong! Da chia nho ham thanh \$chunkCount ham con.');
}
