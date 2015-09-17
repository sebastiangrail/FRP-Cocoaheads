//: [Previous](@previous)

class Signal <T> {
    typealias Observer = T -> Void
//: In addition to an Observer type we also have a controller function
    typealias Controller = T -> Void
    
//: `create` returns both a signal and its controller
    static func create () -> (Signal<T>, Controller) {
        let signal = Signal<T>()
//: The controller for the signal is just its `sendNext` function
        let controller = signal.sendNext
        return (signal, controller)
    }
    
    private var observers = [Observer]()
    
    func observe (observer: Observer) {
        observers.append(observer)
    }
    
//: `sendNext` is now private
    private func sendNext (value: T) {
        observers.forEach { $0(value) }
    }
}

//: signal and controller are now separated
let (signal, controller) = Signal<Int>.create()
signal
    .observe(println)

for i in 0..<10 {
    controller(i)
}

//: We will add error and completion handling on [the next page](@next)
