import Foundation

public func sayHi1() {
    print("hello world, I am ModuleA1")
}

public func unusedPublic() { }
func unusedInternal() { }

// swiftlint:disable all
// swiftlint:enable unused_declaration
private func unusedPrivate() { }
