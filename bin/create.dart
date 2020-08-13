import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter_env_creator/flutter_env_creator.dart'
    as flutter_env_creator;

void main(List<String> args) {
  final parser = ArgParser();
  parser.addOption('target', abbr: 't', callback: (target) {
    if (target == null) {
      print(parser.usage);
      return;
    }
    flutter_env_creator.create(target);
    stdout.writeln('build success');
  });

  parser.parse(args);
}
