# Copilot Instructions

## Package Overview

`flutter_env_creator` is a Dart/Flutter `source_gen`-based code generator. It reads YAML environment files and produces two outputs:
- A Dart `Env` class (`*.env.dart`) with typed static fields
- An Android `{prefix}.properties` file with flat `key=value` pairs

## Commands

```bash
# Install dependencies
dart pub get

# Run all tests
dart test

# Run a single test file
dart test test/merge_map_test.dart

# Lint
dart analyze

# Generate code in a consumer project (APP_ENV controls which overlay YAML is used)
APP_ENV=dev dart run build_runner build
```

## Architecture

The pipeline from annotation to generated file:

1. **`annotation.dart`** — defines `@GenEnv(prefix, envDir)`, placed in the consumer's `main.dart`
2. **`builder.dart`** — `build_runner` entry point; exposes `markBuilder()` which wraps `EnvGenerator` in a `LibraryBuilder` (configured in `build.yaml`)
3. **`generator.dart`** — `EnvGenerator extends GeneratorForAnnotation<GenEnv>`; reads `APP_ENV` from the environment, builds a `Config`, delegates to `generateEnv()`
4. **`flutter_env_creator.dart`** — core logic: reads YAML files, merges them via `mergeMap()`, renders both Mustache templates, writes the `.properties` file as a side-effect, and returns the Dart source string
5. **`merge_map.dart`** — recursively merges an ordered list of maps; later maps override earlier ones (used to layer env-specific YAML on top of the base YAML)
6. **`config.dart`** — plain data class: `envPrefix`, `envDir`, `env`

## Key Conventions

### YAML → Dart class naming
Nested YAML keys produce class names by concatenating PascalCase key segments, prefixed with the capitalised `prefix`. For example, with `prefix: 'app'` and a key path `key4.foo.bar`, the generated class is `AppKey4FooBar`. The top-level class is always named `Env`.

### YAML merge strategy
Two files are merged: `{envDir}/{prefix}.yaml` (base) and `{envDir}/{prefix}-{env}.yaml` (overlay). The overlay is optional. `mergeMap` is called with `acceptNull: true` so an overlay can explicitly set a key to `null`.

### Generated file location
The `.env.dart` file is written next to the annotated `.dart` file (same directory). The `.properties` file is always written to `android/{prefix}.properties` relative to the project root.

### Mustache templates
Both output formats use `mustache_template` with `htmlEscapeValues: false`. Templates are inline string constants in `flutter_env_creator.dart`. String values are single-quoted in Dart output; non-string primitives are rendered as-is.

### build.yaml configuration
The builder is registered as `flutter_env_creator|mark_builder` with `build_to: source` and `auto_apply: root_package`. Changes to the builder registration require updating both `build.yaml` and `builder.dart`.

## Rules
- Do not automatically commit code.