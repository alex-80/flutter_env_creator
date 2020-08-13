import 'package:flutter_env_creator/config.dart';
import 'package:flutter_env_creator/extension.dart';
import 'package:mustache/mustache.dart';
import 'package:yaml/yaml.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:merge_map/merge_map.dart';

const String _dartTpl = '''
/// auto generate
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

  void Function(dynamic value, {int level, String parentKey})
      initDartSourceData;

  initDartSourceData = (dynamic mapOrList, {int level, String parentKey}) {
    if (mapOrList is Map) {
      final classes = dartSourceData['classes'];

      mapOrList.forEach((key, value) {
        if (value is Map || value is List) {
          final upperKey = (key as String).toFirstUpperCase();
          final className = '$parentKey$upperKey';

          if (level == 0) {
            dartSourceData['fields'].add({'key': key, 'val': '$className()'});
          } else {
            final index = level - 1;
            if (index >= 0 && index < classes.length) {
              final Map<String, dynamic> clazz = classes[index];

              (clazz['fields'] as List)
                  .add({'key': key, 'val': '$className()'});
            }
          }
          classes.add({'name': className, 'fields': []});

          initDartSourceData(value, level: level + 1, parentKey: className);
        } else {
          var val = value;
          if (value is String) {
            val = "'$val'";
          }
          if (level == 0) {
            dartSourceData['fields'].add({'key': key, 'val': val});
          } else {
            final index = classes.length - 1;
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
        initDartSourceData(element, level: level + 1);
      });
      return;
    }
  };

  initDartSourceData(map, level: 0, parentKey: prefix);

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

  void Function(dynamic value, {String path}) initPropertySourceData;

  initPropertySourceData = (dynamic value, {String path}) {
    if (value is Map) {
      value.forEach((key, value) {
        final keyPath = path != null ? '$path.$key' : key;
        if (value is Map || value is List) {
          initPropertySourceData(value, path: keyPath);
        } else {
          fields.add({'key': keyPath, 'val': value});
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

/// Get config from pubspec.yaml
Config _getConfig() {
  final pwd = Platform.environment['PWD'];
  final filePath = path.join(pwd, 'pubspec.yaml');
  final file = File(filePath);
  final yamlMap = loadYaml(file.readAsStringSync());
  final defalutConfig = Config.defaluts();

  if (yamlMap == null || !(yamlMap['flutter_env_creator'] is Map)) {
    stdout.writeln(
        'Your `$filePath` file does not contain a `flutter_env_creator` section, use defalut instead');
    return defalutConfig;
  }

  final config = yamlMap['flutter_env_creator'];

  return Config(
      pwd: pwd,
      prefix: config['prefix'] ?? defalutConfig.prefix,
      outputDir: config['outputDir'] ?? defalutConfig.outputDir,
      inputDir: config['inputDir'] ?? defalutConfig.inputDir);
}

void create(String target) {
  final config = _getConfig();

  final dartPath = path.join(config.outputDir, '${config.prefix}.dart');
  final propertyPath =
      path.join(config.pwd, 'android', '${config.prefix}.properties');

  final baseYamlPath = path.join(config.inputDir, '${config.prefix}.yaml');
  final yamlPath = path.join(config.inputDir, '${config.prefix}-$target.yaml');

  final configs = [_getYamlConfig(baseYamlPath).value];

  if (File(yamlPath).existsSync()) {
    configs.add(_getYamlConfig(yamlPath).value);
  }

  final merged = mergeMap(configs, acceptNull: true);
  final dartOutput = genDartSource(merged, config.prefix.toFirstUpperCase());

  final propertyOutput = genPropertySource(merged);

  final dartOutDir = path.dirname(dartPath);
  final propertyOutputDir = path.dirname(propertyPath);

  if (!Directory(dartOutDir).existsSync()) {
    Directory(dartOutDir).createSync(recursive: true);
  }

  if (!Directory(propertyOutputDir).existsSync()) {
    Directory(propertyOutputDir).createSync(recursive: true);
  }

  File(dartPath).writeAsString(dartOutput);
  File(propertyPath).writeAsString(propertyOutput);
}
