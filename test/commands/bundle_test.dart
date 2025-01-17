import 'dart:io';

import 'package:io/io.dart';
import 'package:mason/mason.dart';
import 'package:mason/src/command_runner.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../helpers/helpers.dart';

class MockLogger extends Mock implements Logger {}

void main() {
  final cwd = Directory.current;

  group('mason bundle', () {
    Logger logger;
    MasonCommandRunner commandRunner;

    setUp(() {
      logger = MockLogger();
      commandRunner = MasonCommandRunner(logger: logger);
      when(logger.progress(any)).thenReturn(([String _]) {});
      setUpTestingEnvironment(cwd, suffix: '.bundle');
    });

    tearDown(() {
      Directory.current = cwd;
    });

    test('creates a new universal bundle', () async {
      final testDir = Directory(
        path.join(Directory.current.path, 'universal'),
      )..createSync(recursive: true);
      Directory.current = testDir.path;
      final result =
          await commandRunner.run(['bundle', '../../../../bricks/greeting']);
      expect(result, equals(ExitCode.success.code));
      final actual = Directory(
        path.join(testFixturesPath(cwd, suffix: '.bundle'), 'universal'),
      );
      final expected = Directory(
        path.join(testFixturesPath(cwd, suffix: 'bundle'), 'universal'),
      );
      expect(directoriesDeepEqual(actual, expected), isTrue);
    });

    test('creates a new dart bundle', () async {
      final testDir = Directory(
        path.join(Directory.current.path, 'dart'),
      )..createSync(recursive: true);
      Directory.current = testDir.path;
      final result = await commandRunner
          .run(['bundle', '../../../../bricks/greeting', '-t', 'dart']);
      expect(result, equals(ExitCode.success.code));
      final actual = Directory(
        path.join(testFixturesPath(cwd, suffix: '.bundle'), 'dart'),
      );
      final expected = Directory(
        path.join(testFixturesPath(cwd, suffix: 'bundle'), 'dart'),
      );
      expect(directoriesDeepEqual(actual, expected), isTrue);
    });

    test('exits with code 64 when no brick path is provided', () async {
      final result = await commandRunner.run(['bundle']);
      expect(result, equals(ExitCode.usage.code));
      verify(
        logger.err('path to the brick template must be provided'),
      ).called(1);
    });

    test('exits with code 64 when no brick exists at path', () async {
      final result = await commandRunner.run(['bundle', './path/to/brick']);
      expect(result, equals(ExitCode.usage.code));
      verify(
        logger.err('could not find brick at ./path/to/brick'),
      ).called(1);
    });
  });
}
