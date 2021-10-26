import Foundation

var arguments = Array(CommandLine.arguments.dropFirst())

guard let xcodebuildLogPath = arguments.removeFirst() else {
    print("Pass the path to the xcodebuild log as the first argument")
    exit(1)
}

guard let outputPath = arguments.removeFirst() else {
    print("Pass the output path as the second argument")
    exit(1)
}

let url = URL(fileURLWithPath: xcodebuildLogPath)
let xcodebuildLog = try String(contentsOf: url)
let lines = xcodebuildLog.components(separatedBy: .newlines)

var entries: [CompilationDatabaseEntry] = []
for line in lines {
    let arguments = line
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .components(separatedBy: .whitespaces)
    guard arguments.first?.hasSuffix("swiftc") == true else {
        continue
    }
    let patchedArguments = Array(arguments.dropFirst()).expandingResponseFiles
    let files = patchedArguments.filter { $0.hasSuffix(".swift") }
    for file in files {
        let entry = CompilationDatabaseEntry(file: file, arguments: patchedArguments)
        entries.append(entry)
    }
}

let outputUrl = URL(fileURLWithPath: outputPath)
try FileManager.default.createDirectory(
    atPath: outputUrl.deletingLastPathComponent().path,
    withIntermediateDirectories: true,
    attributes: nil
)

let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
let data = try encoder.encode(entries)
try data.write(to: outputUrl)


