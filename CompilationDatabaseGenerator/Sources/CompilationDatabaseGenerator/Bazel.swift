import Foundation

func bazel(arguments: [String]) throws {
    var arguments = arguments

    guard let outputPath = arguments.removeFirst() else {
        print("Missing the output path")
        exit(1)
    }
    let outputUrl = URL(fileURLWithPath: outputPath)
    try outputUrl.deletingLastPathComponent().mkdir()
    let vfsoverlyRootPath = outputUrl.deletingLastPathComponent().appendingPathComponent("vfsoverly")
    try vfsoverlyRootPath.mkdir()

    let developerDir = try run("xcrun xcode-select -p").trimmingCharacters(in: .whitespacesAndNewlines)
    let sdkDir = try run("xcrun --sdk iphonesimulator --show-sdk-path").trimmingCharacters(in: .whitespacesAndNewlines)

    let targets = try run("bazelisk query 'kind('swift_library', //...)'")
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .components(separatedBy: .newlines)
    _ = try run("bazel build \(targets.joined(separator: " "))")
    let outputString = try run("bazel aquery 'mnemonic('SwiftCompile', \(targets.joined(separator: " + ")))' --output=jsonproto")
    let decoder = JSONDecoder()
    let output = try decoder.decode(Output.self, from: Data(outputString.utf8))

    var entries: [CompilationDatabaseEntry] = []
    for action in output.actions {
        let patchedArguments = try Array(action.arguments.dropFirst(2))
            .patchedArguments(vfsoverlyRootPath: vfsoverlyRootPath, sdkDir: sdkDir, developerDir: developerDir)


        let files = patchedArguments.filter {
            $0.hasSuffix(".swift")
        }
        let newEntries = files.map {
            CompilationDatabaseEntry(file: $0, arguments: patchedArguments)
        }
        entries.append(contentsOf: newEntries)

        let cmd = try action.arguments
            .patchedArguments(vfsoverlyRootPath: vfsoverlyRootPath, sdkDir: sdkDir, developerDir: developerDir)
            .joined(separator: " ")
        print("Full command: \(cmd)")
    }

    try entries.encode(to: outputUrl)

    try outputString.write(to: outputUrl.appendingPathExtension("raw.json"), atomically: true, encoding: .utf8)
}

struct Output: Codable {
    let actions: [Action]
}

struct Action: Codable {
    let arguments: [String]
}

private extension Collection where Element == String {
    func patchedArguments(vfsoverlyRootPath: URL, sdkDir: String, developerDir: String) throws -> [Element] {
        try self.filter { !$0.contains("-Xwrapped-swift") }
            .map {
                try $0
                    .patchingVfsoverly(vfsoverlyRootPath: vfsoverlyRootPath)
                    .replacingOccurrences(of: "Sources/", with: "\(FileManager.default.currentDirectoryPath)/Sources/")
                    .replacingOccurrences(of: "bazel-out/", with: "\(FileManager.default.currentDirectoryPath)/bazel-out/")
                    .replacingOccurrences(of: "__BAZEL_XCODE_SDKROOT__", with: sdkDir)
                    .replacingOccurrences(of: "__BAZEL_XCODE_DEVELOPER_DIR__", with: developerDir)
            }
    }
}

private extension String {
    func patchingVfsoverly(vfsoverlyRootPath: URL) throws -> String {
        guard hasPrefix("-vfsoverlay") else {
            return self
        }

        let vfsoverlyPath = self.replacingOccurrences(of: "-vfsoverlay", with: "")
        let vfsoverlyFile = URL(fileURLWithPath: vfsoverlyPath)
        let vfsoverlyContent = try String(contentsOf: vfsoverlyFile, encoding: .utf8)
            .replacingOccurrences(
                of: "bazel-out/",
                with: "\(FileManager.default.currentDirectoryPath)/bazel-out/"
            )

        let newVfsoverlyFilePath = vfsoverlyRootPath.appendingPathComponent(
            vfsoverlyPath.replacingOccurrences(of: "bazel-out/", with: "")
        )
        try newVfsoverlyFilePath.deletingLastPathComponent().mkdir()
        try vfsoverlyContent.write(
            to: newVfsoverlyFilePath,
            atomically: true,
            encoding: .utf8
        )
        return "-vfsoverlay\(newVfsoverlyFilePath.path)"
    }
}
