## 3.0.0

- Upgraded `source_gen` to `^4.0.0`
- Widened `build` to `>=3.0.2 <5.0.0` and `analyzer` to `>=8.1.1 <15.0.0`
- Raised minimum SDK to `^3.9.0`

## 2.0.2

- Encode non-ASCII characters in .properties file as \uXXXX escapes

## 2.0.1

- Fixed missing `build` and `analyzer` dependencies in `pubspec.yaml`
- Fixed `generator.dart` to use public `package:build/build.dart` API
- Fixed nested map parsing error
- Updated `analysis_options.yaml` to use `lints` instead of deprecated `pedantic`
- Replaced deprecated `forEach` with `for` loop
- Improved package description
- Added `.pubignore` to exclude local and IDE files from published package
- Updated GitHub Actions workflow to use latest actions and Dart commands

## 2.0.0

- Migrated to null safety

## 1.1.0

- Implemented annotation-based configuration (`@GenEnv`)

## 0.1.0

- Initial version
