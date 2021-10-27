import Foundation

struct CompilationDatabaseEntry: Codable {
    let file: String
    let arguments: [String]
}

extension Array where Element == CompilationDatabaseEntry {
    func encode(to path: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        let data = try encoder.encode(self)
        try data.write(to: path)
    }
}
