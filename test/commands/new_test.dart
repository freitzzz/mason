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

  group('mason new', () {
    Logger logger;
    MasonCommandRunner commandRunner;

    setUp(() {
      logger = MockLogger();
      commandRunner = MasonCommandRunner(logger: logger);
      when(logger.progress(any)).thenReturn(([String _]) {});
      setUpTestingEnvironment(cwd, suffix: '.new');
    });

    tearDown(() {
      Directory.current = cwd;
    });

    test('completes successfully when mason.yaml does not exist', () async {
      final result = await commandRunner.run(['new', 'hello world']);
      expect(result, equals(ExitCode.success.code));
    });

    test('creates a new brick when it does not exist', () async {
      File(path.join(Directory.current.path, 'mason.yaml'))
          .writeAsStringSync('bricks:\n');
      final result = await commandRunner.run(['new', 'hello world']);
      expect(result, equals(ExitCode.success.code));
      final actual = Directory(
        path.join(testFixturesPath(cwd, suffix: '.new')),
      );
      final expected = Directory(
        path.join(testFixturesPath(cwd, suffix: 'new')),
      );
      expect(directoriesDeepEqual(actual, expected), isTrue);
    });

    test('exits with code 64 when brick name is missing', () async {
      final result = await commandRunner.run(['new']);
      expect(result, equals(ExitCode.usage.code));
      verify(logger.err('Name of the new brick is required.')).called(1);
    });

    test('exits with code 64 when brick already exists', () async {
      File(path.join(Directory.current.path, 'mason.yaml'))
          .writeAsStringSync('bricks:\n');
      final result = await commandRunner.run(['new', 'hello world']);
      expect(result, equals(ExitCode.success.code));
      final actual = Directory(
        path.join(testFixturesPath(cwd, suffix: '.new')),
      );
      final expected = Directory(
        path.join(testFixturesPath(cwd, suffix: 'new')),
      );
      expect(directoriesDeepEqual(actual, expected), isTrue);

      final secondResult = await commandRunner.run(['new', 'hello world']);
      expect(secondResult, equals(ExitCode.usage.code));
      final expectedBrickYamlPath = path.join(
        Directory.current.path,
        'bricks',
        'hello_world',
        'brick.yaml',
      );
      verify(
        logger.err('Existing brick: hello_world at $expectedBrickYamlPath'),
      ).called(1);
    });
  });
}
