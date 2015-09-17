//: [Previous](@previous)

struct Observer <T, E> {
    let next: (T -> Void)?
    let error: (E -> Void)?
    let completed: (() -> Void)?
}

struct Controller <T, E> {
    let sendNext: T -> Void
    let sendError: E -> Void
    let sendCompleted: () -> Void
}

class Signal <T, E> {
    
    private var observers = [Observer<T,E>]()
    
    static func create () -> (Signal<T,E>, Controller<T,E>) {
        let signal = Signal<T,E>()
        let controller = Controller(
            sendNext: signal.sendNext,
            sendError: signal.sendError,
            sendCompleted: signal.sendCompleted)
        return (signal, controller)
    }
    
    func observe (
        next next: (T -> Void)? = nil,
        error: (E -> Void)? = nil,
        completed: (() -> Void)? = nil)
    {
        observers.append(Observer(next: next, error: error, completed: completed))
    }
    
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
    
//: `filter` creates a new signal that only send values for which the predicate is true
    func filter (predicate: T -> Bool) -> Signal<T,E> {
        
        let (result, controller) = Signal<T,E>.create()
        
//: We observe the underlying signal and send values that pass the filter predicate
        self.observe(
            next: { value in
                if predicate(value) {
                    controller.sendNext(value)
                }
            },
//: `sendError` and `sendCompleted` are just passed through
            error: controller.sendError,
            completed: controller.sendCompleted)
        
        return result
    }
    
//: `map` creates a new signal that sends transformed values
    func map <U> (transform: T -> U) -> Signal<U,E> {
        let (result, controller) = Signal<U,E>.create()
        
//: Again we just observe and transform values appropriately
        self.observe(
            next: { value in
                controller.sendNext(transform(value))
            },
//: Again, `sendError` and `sendCompleted` are just passed through
            error: controller.sendError,
            completed: controller.sendCompleted)
        
        return result
    }
}

let (signal, controller) = Signal<Int, ()>.create()
signal
    .filter { $0 % 2 == 0 } // even values only
    .map { $0 * $0 } // square all values
    .observe(next: println, completed: { println("completed") })

for i in 0..<10 {
    controller.sendNext(i)
}
controller.sendCompleted()









