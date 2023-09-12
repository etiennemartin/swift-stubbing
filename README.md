# swift-stubbing

This repo is meant to show off a pattern that allows you to build simple and extensible Stubbable implementation of protocols. This goes hand in hand with Swift and Protocol based programming. The main goals here are:

- Allow easy creation of classes that adhere to a protocol with stubbable members and functions.
- Create easy default implementations with clear meaning of what they do.
- Make Dependency injection easier to work with.
- Make code more testable.

This approach does contain a bit of overhead and boilerplate code. Overtime we will be adding code generation examples that may help you automate the process of writing stubbable classes (i.e. using [Sourcery](https://github.com/krzysztofzablocki/Sourcery))

## The Template

In its simplest form, the following is the template used to generate a stubbable class. It might not make any sense at the moment due to the fact that the protocol in play has no definitions within it, but bare with me for a bit.

```swift
// Protocol to stub
protocol MyProtocol {}

// Stubbable implementation of the Protocol
class StubbableMyProtocol: MyProtocol {
    typealias SetupFunc = (inout Stubs) -> ()

    // storage for stubs
    var stubs: Stubs

    init(setup: SetupFunc? = nil) {
        var stubs = Stubs()
        setup?(&stubs)
        self.stubs = stubs
    }

    // Default implementation of the stubs.
    struct Stubs {
    }
}
```

The following template shows the bulk of what you'll be playing with. It creates a class that adheres to the protocol at hand, and setups all the boilerplate that will allow us to assign stubs at initialization.

## More in-depth example

Now seeing the template might not have any value at the moment, lets dive into a more concrete example here:

```swift
protocol HttpClientConnecting {
    var maxConnections: Int { get set }
    func connect(url: URL) -> Bool
}

class StubbableHttpClient: HttpClientConnecting {
    typealias SetupFunc = (inout Stubs) -> ()

    // storage for stubs
    var stubs: Stubs

    init(setup: SetupFunc? = nil) {
        var stubs = Stubs()
        setup?(&stubs)
        self.stubs = stubs
    }

    // Default implementation of the stubs.
    struct Stubs {
        // The default implementation here should make the application crash or behave poorly.
        // The idea here is to point out the developer error in setting up the stubbable class.
        var maxConnections: Int = -1
        var connect: (URL) -> Bool = { _ in fatalError("connect function is not stubbed!") }

        // Wholistic default implementation no-op functions
        mutating func noop() {
            maxConnections = 0
            connect = { _ in return true }
        }

        // Default implementation that guaranties connection failures
        mutating func failedConnection() {
            maxConnections = 1
            connect = { _ in return false }
        }
    }

    // Relay to the stubs implementations
    var maxConnections: Int {
        get { return stubs.maxConnections }
        set { stubs.maxConnections = newValue }
    }

    func connect(url: URL) -> Bool {
        return stubs.connect(url)
    }
}
```

Alright that was a bunch of code to read through. The following examples shows you how to setup a mock. It creates a class that you can initialize in any way you see fit. It also provides some defaults for creation of pre-stubbed instances. The following shows some examples of how we can initialize this Stubbable class.

```swift
// noop instance
var noop = StubbableHttpClient {
    // Calls the Stubs struct's method noop() and sets up all the internals to be no-op.
    $0.noop()
}
print(noop.connect(url: URL(string: "")!))
// Output: true

// implementation that will always fails connect()
var alwaysFail = StubbableHttpClient {
    $0.failedConnection()
}
print(noop.connect(url: URL(string: "")!))
// Output: false

// FatalError case where a stub wasn't defined
var crashyCrash = StubbableHttpClient()
_ = crashyCrash.connect(url: URL(string: "")!)
// Output: fatalError

// Custom implementation of a stub
var custom = StubbableHttpClient {
    $0.connect = { url in
        print(url)
        return true
    }
}
print(custom.connect(url: URL(string: "http://www.my-domain.com")!))
// Output: http://www.my-domain.com
```

As you can see this stubbable implemenation can be used in serveral different ways. Gone are the days of having mutiple "mock" implementations of the same protocol. With this approach one implementation can rule them all!

## Playground?

While this isn't a library, I did provide some code in the StubbingPlayground folder above. Feel free to checkout this repo and take the playground for a spin.

## Source generation

Coming soon!
