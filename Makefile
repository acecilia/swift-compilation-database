setup:
	rm -rf outputs
	mkdir outputs

gen_project:
	xcodegen

generate_xcodebuild_log: 
	xcodebuild \
		-project SwiftCompilationDatabase.xcodeproj \
		-scheme "ModuleB" \
		-destination generic/platform=iOS \
		clean build \
		> outputs/xcodebuild.log

generate_compilation_database_from_xcodebuild:
	swift run --package-path CompilationDatabaseGenerator CompilationDatabaseGenerator outputs/xcodebuild.log outputs/compile_commands.json

run_swiftlint_using_compilation_database:
	swiftlint analyze --compile-commands outputs/compile_commands.json

run_swiftlint_using_xcodebuild_log:
	swiftlint analyze --compiler-log-path outputs/xcodebuild.log

go_with_compilation_database: setup gen_project generate_xcodebuild_log generate_compilation_database_from_xcodebuild run_swiftlint_using_compilation_database
go_with_xcodebuild: setup gen_project generate_xcodebuild_log run_swiftlint_using_xcodebuild_log
