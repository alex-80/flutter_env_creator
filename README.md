# flutter_env_creator

A Dart/Flutter code generator that reads YAML environment files and produces:

- A typed Dart `Env` class (`*.env.dart`) with static fields
- An Android `{prefix}.properties` file with flat `key=value` pairs

## Features

- **Multi-environment support** — maintain a base YAML plus per-environment overlays (`dev`, `test`, `prod`, etc.)
- **Typed Dart output** — nested YAML objects become strongly-typed Dart classes
- **Android properties** — nested keys are flattened to dotted notation (e.g. `logger.enable=true`)
- **Overlay merging** — environment-specific values override the base; the overlay file is optional

## Installation

Add `flutter_env_creator` and `build_runner` as dev dependencies:

```yaml
dev_dependencies:
  flutter_env_creator: ^3.0.0
  build_runner: ^2.16.0
```

```bash
dart pub get   # or: flutter pub get
```

## Setup

### 1. Add the `@GenEnv` annotation

Place the annotation on any top-level element in your `lib/main.dart` (or any other `.dart` file):

```dart
import 'package:flutter_env_creator/annotation.dart';

@GenEnv(prefix: 'app', envDir: 'env')
void main() {}
```

| Parameter | Default | Description |
|-----------|---------|-------------|
| `prefix`  | `'env'` | Prefix for YAML filenames and the Android `.properties` file |
| `envDir`  | `'env'` | Directory (relative to project root) containing YAML files |

### 2. Create your YAML files

```
env/
├── app.yaml          # base config (always loaded)
├── app-dev.yaml      # dev overlay (optional)
└── app-test.yaml     # test overlay (optional)
```

**`env/app.yaml`** — base configuration:

```yaml
baseUrl: /api
logger:
  enable: false
timeout: 5000
```

**`env/app-dev.yaml`** — development overrides:

```yaml
name: dev
baseUrl: /api-dev
```

**`env/app-test.yaml`** — test overrides:

```yaml
name: test
baseUrl: /api-test
logger:
  enable: true
```

### 3. Run the generator

Set `APP_ENV` to select the overlay, then run `build_runner`:

```bash
APP_ENV=dev dart run build_runner build
```

> `APP_ENV` defaults to `dev` when not set. The corresponding overlay file (`{prefix}-{env}.yaml`) is optional — only the base YAML is required.

## Generated output

Running `APP_ENV=test dart run build_runner build` with the example above produces:

**`lib/main.env.dart`**

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

**`android/app.properties`**

```properties
# auto generate
baseUrl=/api-test
logger.enable=true
timeout=5000
name=test
```

## YAML → Dart class naming

Nested YAML keys produce class names by concatenating PascalCase segments, prefixed with the capitalised `prefix`. For example, with `prefix: 'app'`:

| YAML key path    | Generated class |
|------------------|-----------------|
| (root)           | `Env`           |
| `logger`         | `AppLogger`     |
| `key4.foo.bar`   | `AppKey4FooBar` |

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/alex-80/flutter_env_creator/issues
