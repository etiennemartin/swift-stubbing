import UIKit

enum SteeringDirection {
    case left
    case right
    case straight
}

protocol Drivable {
    var maxSpeed: Float { get set }
    func start(retries: Int) -> Bool
    func stop()
    func steer(_ direction: SteeringDirection, velocity: Float)
}

class MockCar: Drivable {
    typealias SetupFunc = (inout Stubs) -> ()
    
    private var stubs: Stubs
    
    init(setup: SetupFunc? = nil) {
        var stubs = Stubs()
        setup?(&stubs)
        self.stubs = stubs
    }
    
    struct Stubs {
        var maxSpeed: Float = -1.0
        
        // Fails if a call is made to a function that is not implemented
        var start: (Int) -> Bool = { _ in
            fatalError("start function not stubbed!")
        }
        var stop: () -> Void = {
            fatalError("stop function not stubbed!")
        }
        var steer: (SteeringDirection, Float) -> Void = { _, _ in
            fatalError("steer function not stubbed!")
        }
        
        // Default implementation with no operations
        mutating func noop() {
            maxSpeed = 0.0
            start = { _ in return true }
            stop = { /* The goggles, they do nothing! */ }
            steer = { _, _ in }
        }
    }
    
    var maxSpeed: Float {
        get {
            return stubs.maxSpeed
        }
        set {
            stubs.maxSpeed = newValue
        }
    }
    
    func start(retries: Int) -> Bool {
        return stubs.start(retries)
    }
    
    func stop() {
        stubs.stop()
    }
    
    func steer(_ direction: SteeringDirection, velocity: Float) {
        stubs.steer(direction, velocity)
    }
}

// Creates a mock where all functions do nothing
var noopMock = MockCar {
    $0.noop()
}
print("noop maxSpeed: \(noopMock.maxSpeed)")

// Create an empty mock with an override for maxSpeed
var noopWithMaxSpeed = MockCar {
    $0.noop()
    $0.maxSpeed = 1000.0
}
print("noopWithMaxSpeed: \(noopWithMaxSpeed.maxSpeed)")

// Create a empty mock with a custom override for the steer method only.
var customSteering = MockCar {
    $0.steer = { direction, velocity in
        print("direction: \(direction), velocity: \(velocity)")
    }
}
customSteering.steer(.left, velocity: 100.0)

// Test out what happens when you run a non stubbed function
var fatalErrorMock = MockCar()
print(fatalErrorMock.stop())
