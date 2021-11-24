import Foundation

func bazel(arguments: [String]) throws {
    var arguments = arguments

    guard let outputPath = arguments.removeFirst() else {
        print("Missing the output path")
        exit(1)
    }

    let developerDir = try run("xcrun xcode-select -p").trimmingCharacters(in: .whitespacesAndNewlines)
    let sdkDir = try run("xcrun --show-sdk-path").trimmingCharacters(in: .whitespacesAndNewlines)

    let targets = try run("bazelisk query 'kind('swift_library', //...)'")
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .components(separatedBy: .newlines)
    _ = try run("bazel build \(targets.joined(separator: " "))")
    let outputString = try run("bazel aquery 'mnemonic('SwiftCompile', \(targets.joined(separator: " + ")))' --output=jsonproto")
    let decoder = JSONDecoder()
    let output = try decoder.decode(Output.self, from: Data(outputString.utf8))

    var entries: [CompilationDatabaseEntry] = []
    for action in output.actions {
        let patchedArguments = Array(action.arguments.dropFirst(2))
            .filter { !$0.contains("-Xwrapped-swift") }
            .map {
                $0
                    .replacingOccurrences(of: "Sources/", with: "\(FileManager.default.currentDirectoryPath)/Sources/")
                    .replacingOccurrences(of: "bazel-out/", with: "\(FileManager.default.currentDirectoryPath)/bazel-out/")
                    .replacingOccurrences(of: "__BAZEL_XCODE_SDKROOT__", with: sdkDir)
                    .replacingOccurrences(of: "__BAZEL_XCODE_DEVELOPER_DIR__", with: developerDir)
            }

        let files = patchedArguments.filter {
            $0.hasSuffix(".swift")
        }
        let newEntries = files.map {
            CompilationDatabaseEntry(file: $0, arguments: patchedArguments)
        }
        entries.append(contentsOf: newEntries)
    }

    let outputUrl = URL(fileURLWithPath: outputPath)
    try outputUrl.deletingLastPathComponent().mkdir()
    try entries.encode(to: outputUrl)

    try outputString.write(to: outputUrl.appendingPathExtension("raw.json"), atomically: true, encoding: .utf8)
}

struct Output: Codable {
    let actions: [Action]
}

struct Action: Codable {
    let arguments: [String]
}
