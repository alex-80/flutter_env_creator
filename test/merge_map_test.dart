import 'package:flutter_env_creator/merge_map.dart';
import 'package:test/test.dart';

void main() {
  group('merge map', () {
    test('Can merge two simple maps', () {
      var merged = mergeMap([
        {'hello': 'world'},
        {'hello': 'dolly'}
      ]);
      expect(merged['hello'], equals('dolly'));
    });

    test("The last map's values supersede those of prior", () {
      var merged = mergeMap([
        {'letter': 'a'},
        {'letter': 'b'},
        {'letter': 'c'}
      ]);
      expect(merged['letter'], equals('c'));
    });

    test('Can merge two once-nested maps', () {
      // ignore: omit_local_variable_types
      Map map1 = {
        'hello': 'world',
        'foo': {'nested': false}
      };
      // ignore: omit_local_variable_types
      Map map2 = {
        'goodbye': 'sad life',
        'foo': {'nested': true, 'it': 'works'}
      };
      var merged = mergeMap([map1, map2]);

      expect(merged['hello'], equals('world'));
      expect(merged['goodbye'], equals('sad life'));
      expect(merged['foo']['nested'], equals(true));
      expect(merged['foo']['it'], equals('works'));
    });

    test('Once-nested map supersession', () {
      // ignore: omit_local_variable_types
      Map map1 = {
        'hello': 'world',
        'foo': {'nested': false}
      };
      // ignore: omit_local_variable_types
      Map map2 = {
        'goodbye': 'sad life',
        'foo': {'nested': true, 'it': 'works'}
      };
      // ignore: omit_local_variable_types
      Map map3 = {
        'foo': {'nested': 'supersession'}
      };

      var merged = mergeMap([map1, map2, map3]);
      expect(merged['foo']['nested'], equals('supersession'));
    });

    test('Can merge two twice-nested maps', () {
      // ignore: omit_local_variable_types
      Map map1 = {
        'a': {
          'b': {'c': 'd'}
        }
      };
      // ignore: omit_local_variable_types
      Map map2 = {
        'a': {
          'b': {'c': 'D', 'e': 'f'}
        }
      };
      var merged = mergeMap([map1, map2]);

      expect(merged['a']['b']['c'], equals('D'));
      expect(merged['a']['b']['e'], equals('f'));
    });

    test('Twice-nested map supersession', () {
      // ignore: omit_local_variable_types
      Map map1 = {
        'a': {
          'b': {'c': 'd'}
        }
      };
      // ignore: omit_local_variable_types
      Map map2 = {
        'a': {
          'b': {'c': 'D', 'e': 'f'}
        }
      };
      // ignore: omit_local_variable_types
      Map map3 = {
        'a': {
          'b': {'e': 'supersession'}
        }
      };
      var merged = mergeMap([map1, map2, map3]);

      expect(merged['a']['b']['c'], equals('D'));
      expect(merged['a']['b']['e'], equals('supersession'));
    });

    test('Merge primitive type', () {
      final result = mergeMap([
        {'key1': 'value1'},
        {'key2': 'value2'}
      ]);

      expect(result, equals({'key1': 'value1', 'key2': 'value2'}));
    });

    test('Merge reference type', () {
      final result = mergeMap([
        {
          'object1': {'key1': 'value1'}
        },
        {
          'object1': {'key2': 'value2'}
        }
      ]);
      expect(
        result,
        equals({
          'object1': {'key1': 'value1', 'key2': 'value2'}
        }),
      );
    });

    test('Merge two reference type', () {
      final result = mergeMap([
        {
          'object1': {'key1': 'value1'},
          'object2': {'key2': 'value2'},
        },
        {
          'object1': {'key2': 'value2'},
          'object2': {'key2': 'value2-override'},
        }
      ]);
      expect(
        result,
        equals({
          'object1': {'key1': 'value1', 'key2': 'value2'},
          'object2': {'key2': 'value2-override'},
        }),
      );
    });

    test('Nested reference type', () {
      final result = mergeMap([
        {
          'key1': null,
          'key2': 'value2',
          'key3': null,
          'key4': {
            'hello': 'value4_1',
            'world': 'value4_2',
            'foo': {
              'bar': {
                'bzz': {'b': 1, 'c': 2}
              }
            }
          },
          'key5': {'local': false},
          'key6': {'remote': ''},
          'key7': {
            'nested': {'a': true, 'b': 'value7_1_2'}
          }
        },
        {
          'key1': 'dev1',
          'key2': 'dev2',
          'key3': 'dev3',
          'key5': {'local': true}
        }
      ]);
      expect(
        result,
        equals({
          'key1': 'dev1',
          'key2': 'dev2',
          'key3': 'dev3',
          'key4': {
            'hello': 'value4_1',
            'world': 'value4_2',
            'foo': {
              'bar': {
                'bzz': {'b': 1, 'c': 2}
              }
            }
          },
          'key5': {'local': true},
          'key6': {'remote': ''},
          'key7': {
            'nested': {'a': true, 'b': 'value7_1_2'}
          }
        }),
      );
    });
  });
}
