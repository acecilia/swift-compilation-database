import Foundation

func run(_ command: String) throws -> String {
    return try run("/bin/zsh" , with: ["-c", "\(command)"])
}

private func run(_ command: String, with arguments: [String] = []) throws -> String {
     let process = Process()
     process.launchPath = command
     process.arguments = arguments
     let outputPipe = Pipe()
     process.standardOutput = outputPipe
     process.launch()
     let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
     let output = String(decoding: outputData, as: UTF8.self)
     return output
 }
