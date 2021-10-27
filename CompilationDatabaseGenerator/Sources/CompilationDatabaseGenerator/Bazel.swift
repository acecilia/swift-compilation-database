import Foundation

func bazel(arguments: [String]) throws {
    var arguments = arguments

    guard let outputPath = arguments.removeFirst() else {
        print("Missing the output path")
        exit(1)
    }

    let bazelOutputPath = "bazel-out/darwin-fastbuild/bin"
    let compilerArgumentFiles = try FileManager.default
        .contentsOfDirectory(atPath: bazelOutputPath)
        .filter { $0.hasSuffix(".swiftmodule-0.params") }
        .map { "\(bazelOutputPath)/\($0)" }

    var entries: [CompilationDatabaseEntry] = []
    for compilerArgumentFile in compilerArgumentFiles {
        let url = URL(fileURLWithPath: compilerArgumentFile)
        let compilerArguments = try String(contentsOf: url)
            .replacingOccurrences(of: "Sources/", with: "\(FileManager.default.currentDirectoryPath)/Sources/")
            .replacingOccurrences(of: "bazel-out/", with: "\(FileManager.default.currentDirectoryPath)/bazel-out/")
            .replacingOccurrences(
                of: "__BAZEL_XCODE_SDKROOT__",
                with: "/Applications/Xcode_12.5.1.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX11.3.sdk"
            )
            .components(separatedBy: .newlines)
            .filter { !$0.contains("-Xwrapped-swift") }

        let files = compilerArguments.filter {
            $0.hasSuffix(".swift")
        }
        let newEntries = files.map {
            CompilationDatabaseEntry.init(file: $0, arguments: compilerArguments)
        }
        entries.append(contentsOf: newEntries)
    }

    let outputUrl = URL(fileURLWithPath: outputPath)
    try outputUrl.deletingLastPathComponent().mkdir()
    try entries.encode(to: outputUrl)
}
