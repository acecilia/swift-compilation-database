setup:
	rm -rf SwiftCompilationDatabase.xcodeproj
	rm -rf outputs
	mkdir outputs

gen_project:
	mint run yonaskolb/XcodeGen@2.25.0

# Xcode 12.5.1 at the time of writing
generate_xcodebuild_log: 
	xcodebuild \
		-project SwiftCompilationDatabase.xcodeproj \
		-scheme "ModuleB" \
		-destination generic/platform=MacOS \
		clean build \
		> outputs/xcodebuild.log

generate_compilation_database_from_xcodebuild:
	swift run --package-path CompilationDatabaseGenerator CompilationDatabaseGenerator xcodebuild outputs/xcodebuild.log outputs/compile_commands.json

generate_compilation_database_from_bazel:
	swift run --package-path CompilationDatabaseGenerator CompilationDatabaseGenerator bazel outputs/compile_commands.json

run_swiftlint_using_compilation_database:
	mint run realm/SwiftLint@0.45.0 analyze --compile-commands outputs/compile_commands.json

run_swiftlint_using_xcodebuild_log:
	mint run realm/SwiftLint@0.45.0 analyze --compiler-log-path outputs/xcodebuild.log

build_bazel:
	bazelisk build -s //:ModuleB

go_with_bazel_compilation_database: setup build_bazel generate_compilation_database_from_bazel run_swiftlint_using_compilation_database
go_with_xcodebuild_compilation_database: setup gen_project generate_xcodebuild_log generate_compilation_database_from_xcodebuild run_swiftlint_using_compilation_database
go_with_xcodebuild: setup gen_project generate_xcodebuild_log run_swiftlint_using_xcodebuild_log
