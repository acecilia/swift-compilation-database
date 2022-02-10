// This file shows how adding a tag to a documentation comment crashes the SourceKitService
// The crash will show the following output:
// > sourcekit: [1:connection-event-handler:12547: 0.0000] Connection interruptsourcekit: [1:updateSemanticEditorDelay:12547: 0.0002] disabling semantic editor for 10 secondssourcekit: [1:pingService:12547: 0.0003] pinging servicesourcekitten: connection to SourceKitService restored!
// > sourcekit: [1:ping-event-handler:12803: 0.0125] service restoredsourcekitten: connection to SourceKitService restored!
//
// After the crash, swiftlint will fail collecting information for any remaining swift files,
// with the error:
// > Could not index file at path './swift-compilation-database/Sources/ModuleA/ModuleA2.swift' with the unused_declaration rule.

/// - Tag: sometag
func sayHi() {
    print("hello world")
}