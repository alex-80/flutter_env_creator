import 'dart:io';

import 'package:build/src/builder/build_step.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_env_creator/config.dart';
import 'package:source_gen/source_gen.dart';
import 'package:flutter_env_creator/flutter_env_creator.dart'
    as flutter_env_creator;

import 'annotation.dart';

class EnvGenerator extends GeneratorForAnnotation<GenEnv> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
   
    final envDir = annotation.peek('envDir')?.stringValue ?? 'env';
    final prefix = annotation.peek('prefix')?.stringValue ?? 'env';
    final env = Platform.environment['APP_ENV'] ?? 'dev';
   
    final config = Config(env: env, envPrefix: prefix, envDir: envDir);

    return flutter_env_creator.generateEnv(config);
  }
}
