import 'dart:io';
import 'package:path/path.dart' as path;

class Config {
  final String pwd;
  final String prefix;
  final String outputDir;
  final String inputDir;

  Config({this.prefix, this.outputDir, this.pwd, this.inputDir});

  Config.defaluts()
      : this(
            prefix: 'env',
            pwd: Platform.environment['PWD'],
            outputDir: path.join(Platform.environment['PWD'], 'lib'),
            inputDir: path.join(Platform.environment['PWD'], 'env'));
}
