import 'dart:io';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;

const _equality = DeepCollectionEquality();

bool directoriesDeepEqual(Directory a, Directory b) {
  if (identical(a, b)) return true;
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;

  final dirAContents = a.listSync(recursive: true).whereType<File>();
  final dirBContents = b.listSync(recursive: true).whereType<File>();

  if (dirAContents.length != dirBContents.length) return false;

  for (var i = 0; i < dirAContents.length; i++) {
    final fileEntityA = (dirAContents.elementAt(i));
    final fileEntityB = dirBContents.elementAt(i);

    final fileA = File(fileEntityA.path);
    final fileB = File(fileEntityB.path);

    if (path.basename(fileA.path) != path.basename(fileB.path)) return false;
    if (!_equality.equals(fileA.readAsBytesSync(), fileB.readAsBytesSync())) {
      return false;
    }
  }

  return true;
}
