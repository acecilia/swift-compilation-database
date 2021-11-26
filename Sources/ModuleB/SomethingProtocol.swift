// File that demonstrates a false positive when the conformance of a protocol
// happens on an extension in a different file

protocol SomethingProtocol {
    func someFunction1()
    func someFunction2()
    func someFunction3()
}

final class Something: SomethingProtocol {
    func someFunction1() {
        print("someFunction1")
    }
}

extension Something {
    func someFunction2() {
        print("someFunction2")
    }
}

// swiftlint:disable:next unused_declaration
public final class Consumer {
    let something: SomethingProtocol

    public convenience init() {
        self.init(something: Something())
    }

    init(something: SomethingProtocol) {
        self.something = something
    }

    // swiftlint:disable:next unused_declaration
    public func doSomething() {
        something.someFunction1()
        something.someFunction2()
        something.someFunction3()
    }
}
