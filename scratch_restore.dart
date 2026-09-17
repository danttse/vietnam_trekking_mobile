import 'dart:io';

void main() {
  final file = File('lib/features/auth/data/vietnam_map_paths.dart');
  String content = file.readAsStringSync();
  
  // Extract the header (everything up to "List<Path> buildPaths(Size size) {")
  int buildPathsIndex = content.indexOf('List<Path> buildPaths(Size size) {');
  if (buildPathsIndex == -1) {
    print('Error: Could not find buildPaths header');
    return;
  }
  
  String header = content.substring(0, buildPathsIndex);
  
  // Extract all the path blocks
  RegExp pathBlockRegex = RegExp(r'// Path number \d+[\s\S]*?paths\.add\(path\);');
  Iterable<Match> matches = pathBlockRegex.allMatches(content);
  
  // Extract footer (the paint method and beyond)
  int paintIndex = content.indexOf('void paint(Canvas canvas, Size size) {');
  String footer = '';
  if (paintIndex != -1) {
    // Need to find the @override before paint
    int overrideIndex = content.lastIndexOf('@override', paintIndex);
    if (overrideIndex != -1) {
      footer = content.substring(overrideIndex);
    } else {
      footer = content.substring(paintIndex);
    }
  }

  StringBuffer restoredCode = StringBuffer();
  restoredCode.write(header);
  restoredCode.write('    List<Path> buildPaths(Size size) {\n');
  restoredCode.write('      final List<Path> paths = [];\n');
  restoredCode.write('      Paint paint = Paint();\n');
  restoredCode.write('      Path path = Path();\n\n');
  
  for (Match m in matches) {
    restoredCode.write('      ${m.group(0)}\n\n');
  }
  
  restoredCode.write('      return paths;\n');
  restoredCode.write('    }\n\n');
  restoredCode.write('    $footer');
  
  file.writeAsStringSync(restoredCode.toString());
  print('Thanh cong khac phuc file ve nhu cu!');
}
