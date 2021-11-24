import Foundation
import ModuleA

public func sayHi() {
    ModuleA.sayHi1()
    ModuleA.sayHi2()
    print("hello world, I am ModuleB")
}

extension Int {
    public func something1() {
        let formatter = makeFormatter()
        something2(formatter)
    }

    private func something2(
        _ formatter: NumberFormatter
    ) {
        print("something2")
    }
}
