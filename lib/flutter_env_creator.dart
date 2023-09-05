import 'package:flutter_env_creator/config.dart';
import 'package:flutter_env_creator/extension.dart';
import 'package:flutter_env_creator/merge_map.dart';
import 'package:mustache_template/mustache.dart';
import 'package:yaml/yaml.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

const String _dartTpl = '''
class Env {
  {{# fields }}
    static final {{ key }} = {{ val }};
  {{/ fields }}
}
{{# classes }}
class {{ name }} {
  {{# fields }}
    final {{ key }} = {{ val }};
  {{/ fields }}
}  
{{/ classes }}
''';

const String _propertyTpl = '''
# auto generate
{{# fields }}
{{ key }}={{ val }}
{{/ fields }}
''';

Map<String, List<dynamic>> genDartSourceData(
    Map<dynamic, dynamic> map, String prefix) {
  var dartSourceData = <String, List<dynamic>>{'fields': [], 'classes': []};

  late void Function(dynamic value,
      {required int level,
      required List fields,
      String? parentKey}) initDartSourceData;

  final classes = dartSourceData['classes'];

  initDartSourceData = (dynamic mapOrList,
      {required int level, required List fields, String? parentKey}) {
    if (mapOrList is Map) {
      mapOrList.forEach((key, value) {
        if (value is Map || value is List) {
          final upperKey = (key as String).toFirstUpperCase();
          final className = '$parentKey$upperKey';

          // if (level == 0) {
          //   dartSourceData['fields']!.add({'key': key, 'val': '$className()'});
          // } else {
          //   final index = level - 1;
          //   if (index >= 0 && index < classes!.length) {
          //     final Map<String, dynamic> clazz = classes[index];

          //     (clazz['fields'] as List)
          //         .add({'key': key, 'val': '$className()'});
          //   }
          // }
          fields.add({'key': key, 'val': '$className()'});
          final newFields = [];
          classes!.add({'name': className, 'fields': newFields});

          initDartSourceData(
            value,
            level: level + 1,
            fields: newFields,
            parentKey: className,
          );
        } else {
          var val = value;
          if (value is String) {
            val = "'$val'";
          }
          if (level == 0) {
            dartSourceData['fields']!.add({'key': key, 'val': val});
          } else {
            final index = classes!.length - 1;
            if (index >= 0 && index < classes.length) {
              final Map<String, dynamic> clazz = classes[index];

              (clazz['fields'] as List).add({'key': key, 'val': val});
            }
          }
        }
      });
      return;
    }

    if (mapOrList is List) {
      mapOrList.forEach((element) {
        initDartSourceData(element, level: level + 1, fields: []);
      });
      return;
    }
  };

  initDartSourceData(
    map,
    level: 0,
    fields: dartSourceData['fields']!,
    parentKey: prefix,
  );

  return dartSourceData;
}

String genDartSource(Map<dynamic, dynamic> map, String prefix) {
  final data = genDartSourceData(map, prefix);

  final result = Template(_dartTpl, htmlEscapeValues: false).renderString(data);

  return result;
}

Map<String, List<dynamic>> genPropertySourceData(Map<dynamic, dynamic> map) {
  var propertySourceData = <String, List<dynamic>>{'fields': []};
  final fields = propertySourceData['fields'];

  late void Function(dynamic value, {String? path}) initPropertySourceData;

  initPropertySourceData = (dynamic value, {String? path}) {
    if (value is Map) {
      value.forEach((key, value) {
        final keyPath = path != null ? '$path.$key' : key;
        if (value is Map || value is List) {
          initPropertySourceData(value, path: keyPath);
        } else {
          fields!.add({'key': keyPath, 'val': value});
        }
      });
    }

    if (value is List) {
      value.forEach((element) {
        initPropertySourceData(element, path: path);
      });
    }
  };

  initPropertySourceData(map);

  return propertySourceData;
}

String genPropertySource(dynamic value) {
  final data = genPropertySourceData(value);
  final result =
      Template(_propertyTpl, htmlEscapeValues: false).renderString(data);
  return result;
}

YamlMap _getYamlConfig(String yamlPath) {
  final file = File(yamlPath);

  if (!file.existsSync()) {
    throw Exception('$yamlPath not exists');
  }

  final content = file.readAsStringSync();
  final doc = loadYaml(content);

  return doc as YamlMap;
}

String generateEnv(Config config) {
  final propertyPath = path.join('android', '${config.envPrefix}.properties');

  final baseYamlPath = path.join(config.envDir, '${config.envPrefix}.yaml');
  final yamlPath =
      path.join(config.envDir, '${config.envPrefix}-${config.env}.yaml');

  final configs = [_getYamlConfig(baseYamlPath).value];

  if (File(yamlPath).existsSync()) {
    configs.add(_getYamlConfig(yamlPath).value);
  }

  final merged = mergeMap(configs, acceptNull: true);
  final dartOutput = genDartSource(merged, config.envPrefix.toFirstUpperCase());

  final propertyOutput = genPropertySource(merged);

  final propertyOutputDir = path.dirname(propertyPath);

  if (!Directory(propertyOutputDir).existsSync()) {
    Directory(propertyOutputDir).createSync(recursive: true);
  }

  File(propertyPath).writeAsString(propertyOutput);

  return dartOutput;
}
