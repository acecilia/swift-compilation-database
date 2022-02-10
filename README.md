# Swift compilation database

This repository demonstrates how to use swiftlint to identify unused code or unused imports in a Swift codebase.

## How to run

* `make go_with_xcodebuild`: will generate an xcode project, build the code with xcodebuild, generate a build log and feed it to swiftlint
* `make go_with_xcodebuild_compilation_database`: will generate an xcode project, build the code with xcodebuild, generate a build log, convert the build log into a compilation database and feed it to swiftlint
* `make go_with_bazel_compilation_database`: will run `bazel aquery` to obtain the compilation commands, which then are processed to generate a compilation database. Then, it feeds it to swiftlint