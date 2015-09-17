//: [Previous](@previous)

/*: A struct wrapping `next`, `error` and `completed` functions
 *  All functions are optional
 */
struct Observer <T, E> {
    let next: (T -> Void)?
    let error: (E -> Void)?
    let completed: (() -> Void)?
}

//: Similarly the `Controller` contains functions for sending events
struct Controller <T, E> {
    let sendNext: T -> Void
    let sendError: E -> Void
    let sendCompleted: () -> Void
}

class Signal <T, E> {
    
//: `observers` are structs
    private var observers = [Observer<T,E>]()
    
    static func create () -> (Signal<T,E>, Controller<T,E>) {
        let signal = Signal<T,E>()
//: and the `controller` wraps all three functions
        let controller = Controller(
            sendNext: signal.sendNext,
            sendError: signal.sendError,
            sendCompleted: signal.sendCompleted)
        return (signal, controller)
    }
    
/*:
Instead of taking an `Observer` argument, we pass in `next`, `error`, and `completed` functions
All arguments are optional and default to nil, which makes them proper named parameters.
We can call observe like this:
- `signal.observe(next: function)`
- `signal.observe(next: function, completed: otherFunction)`
 */
    func observe (
        next next: (T -> Void)? = nil,
        error: (E -> Void)? = nil,
        completed: (() -> Void)? = nil)
    {
        observers.append(Observer(next: next, error: error, completed: completed))
    }
    
//: Use `flatMap` to extract only non-nil functions
    private func sendNext (value: T) {
        observers
            .flatMap { $0.next }
            .forEach { $0(value) }
    }
    
    private func sendError (error: E) {
        observers
            .flatMap { $0.error }
            .forEach { $0(error) }
    }
    
    private func sendCompleted () {
        observers
            .flatMap { $0.completed }
            .forEach { $0() }
    }
}

let (signal, controller) = Signal<Int, ()>.create()
signal
    .observe(next: println, completed: { println("completed") })

for i in 0..<10 {
    controller.sendNext(i)
}
controller.sendCompleted()

//: To make signals really usefule, we will implement some operations on [the next page](@next)
