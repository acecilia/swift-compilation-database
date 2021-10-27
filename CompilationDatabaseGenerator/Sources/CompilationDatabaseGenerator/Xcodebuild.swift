import Foundation

func xcodebuild(arguments: [String]) throws {
    var arguments = arguments

    guard let xcodebuildLogPath = arguments.removeFirst() else {
        print("Missing the path to the xcodebuild log")
        exit(1)
    }

    guard let outputPath = arguments.removeFirst() else {
        print("Missing the output path")
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
    try outputUrl.deletingLastPathComponent().mkdir()
    try entries.encode(to: outputUrl)
}
