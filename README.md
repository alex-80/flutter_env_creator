# flutter_env_creator

Automatically generates dart code from your `yaml` file.

## Usage

- Add flutter_env_creator as a dev dependency in your pubspec.yaml file.

```yaml
dev_dependencies:
  flutter_env_creator: ^1.1.0
```

```bash
flutter pub get
```

- Add @GenEnv annotation to your project's lib/main.dart file

```dart
import 'package:flutter_env_creator/annotation.dart';

@GenEnv(prefix: 'app', envDir: 'env')
void main() {}
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
APP_ENV=dev flutter pub run build_runner build
```

## Result
It will genreate main.env.dart file and app.properties file

lib/app.dart
```dart
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
