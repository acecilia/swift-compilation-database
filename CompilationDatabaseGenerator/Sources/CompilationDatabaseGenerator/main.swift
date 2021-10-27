import Foundation

var arguments = Array(CommandLine.arguments.dropFirst())

guard let typeOfProcessing = arguments.removeFirst() else {
    print("Missing the path to the xcodebuild log")
    exit(1)
}

if typeOfProcessing == "xcodebuild" {
    try xcodebuild(arguments: arguments)
} else if typeOfProcessing == "bazel" {
    try bazel(arguments: arguments)
} else {
    print("Unknown processing type")
    exit(1)
}


