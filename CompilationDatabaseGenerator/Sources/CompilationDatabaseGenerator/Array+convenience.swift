import Foundation

extension Array where Element == String {
    var expandingResponseFiles: [String] {
        return flatMap { arg -> [String] in
            guard arg.starts(with: "@") else {
                return [arg]
            }
            let responseFile = String(arg.dropFirst())
            return (try? String(contentsOf: URL(fileURLWithPath: responseFile))).flatMap {
                $0.trimmingCharacters(in: .newlines)
                  .components(separatedBy: "\n")
                  .expandingResponseFiles
            } ?? [arg]
        }
    }
}

extension Array {
    mutating func removeFirst() -> Element? {
        if first != nil {
            return removeFirst() as Element
        }
        return nil
    }
}
