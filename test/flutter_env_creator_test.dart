// @dart=2.9

import 'package:test/test.dart';
import 'package:flutter_env_creator/extension.dart';
import 'package:flutter_env_creator/flutter_env_creator.dart'
    as flutter_env_creator;

extension StringE on String {
  String trimTab() {
    return replaceAll(RegExp(r'\t'), '');
  }
}

void main() {
  group('String', () {
    test('First Char UpperCase', () {
      final string = 'name';
      expect(string.toFirstUpperCase(), equals('Name'));
    });
  });
  group('flutter_env_creator', () {
    final map = {
      'name': 'test',
      'basePath': '/api',
      'logger': {'enable': true},
      'timeout': 5000
    };

    test('Generate Dart Source Data', () {
      final result = flutter_env_creator.genDartSourceData(map, 'Env');

      expect(
          result,
          equals({
            'fields': [
              {'key': 'name', 'val': "'test'"},
              {'key': 'basePath', 'val': "'/api'"},
              {'key': 'logger', 'val': 'EnvLogger()'},
              {'key': 'timeout', 'val': 5000}
            ],
            'classes': [
              {
                'name': 'EnvLogger',
                'fields': [
                  {'key': 'enable', 'val': true}
                ]
              }
            ]
          }));
    });

    test('Generate Dart Source', () {
      final result = flutter_env_creator.genDartSource(map, 'Env');
      expect(
          result.trim(),
          equals('''
class Env {
    static final name = 'test';
    static final basePath = '/api';
    static final logger = EnvLogger();
    static final timeout = 5000;
}
class EnvLogger {
    final enable = true;
}
'''
              .trim()));
    });

    test('Generate Property Source Data', () {
      final result = flutter_env_creator.genPropertySourceData(map);

      expect(
          result,
          equals({
            'fields': [
              {'key': 'name', 'val': 'test'},
              {'key': 'basePath', 'val': '/api'},
              {'key': 'logger.enable', 'val': true},
              {'key': 'timeout', 'val': 5000},
            ]
          }));
    });

    test('Generate Property Source', () {
      final result = flutter_env_creator.genPropertySource(map);
      expect(
          result.trim(),
          equals('''
# auto generate
name=test
basePath=/api
logger.enable=true
timeout=5000
            '''
              .trim()));
    });
  });
}
