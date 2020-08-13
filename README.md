# flutter_env_creator

Automatically generates dart code from your `yaml` file.

## Usage

- Add flutter_env_creator as a dev dependency in your pubspec.yaml file.

```yaml
dev_dependencies:
  flutter_env_creator: ^0.1.0
```

```bash
flutter pub get
```

- Add your settings to your project's pubspec.yaml file

```yaml
flutter_env_creator:
  prefix: app
  inputDir: env
  outputDir: lib
```

- create your yaml file

env
├── app-dev.yaml
├── app-test.yaml
└── app.yaml

app.yaml

```yaml
baseUrl: /api
logger:
  enable: false
timeout: 5000
```

app-test.yaml

```yaml
name: test
baseUrl: /api-test
logger:
  enable: true
```

app-dev.yaml
```yaml
name: dev
baseUrl: /api-dev
```

- Run the package:

```bash
pub run flutter_env_creator:create -t test
```

## Result
It will genreate app.dart file and app.properties file

lib/app.dart
```dart
/// auto generate
class Env {
    static final baseUrl = '/api-test';
    static final logger = AppLogger();
    static final timeout = 5000;
    static final name = 'test';
}
class AppLogger {
    final enable = true;
}  
```

android/app.properties

```properties
# auto generate
baseUrl=/api-test
logger.enable=true
timeout=5000
name=test
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://example.com/issues/replaceme
