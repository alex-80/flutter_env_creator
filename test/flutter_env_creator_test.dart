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

    test('Nested reference type', () {
      final result = flutter_env_creator.genDartSource({
        'key4': {
          'world': 'value4_2',
          'foo': {
            'bar': {
              'bzz': {'b': 1}
            }
          }
        },
        'key7': {
          'nested': {'b': 'value7_1_2'}
        }
      }, 'Env');
      expect(
        result.trim(),
        equals('''
class Env {
    static final key4 = EnvKey4();
    static final key7 = EnvKey7();
}
class EnvKey4 {
    final world = 'value4_2';
    final foo = EnvKey4Foo();
}  
class EnvKey4Foo {
    final bar = EnvKey4FooBar();
}  
class EnvKey4FooBar {
    final bzz = EnvKey4FooBarBzz();
}  
class EnvKey4FooBarBzz {
    final b = 1;
}  
class EnvKey7 {
    final nested = EnvKey7Nested();
}  
class EnvKey7Nested {
    final b = 'value7_1_2';
}
          '''
            .trim()),
      );
    });
  });
}
