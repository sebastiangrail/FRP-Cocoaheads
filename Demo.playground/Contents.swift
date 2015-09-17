
func println <T> (x: T) {
    print(x)
}

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
    
    func filter (predicate: T -> Bool) -> Signal<T,E> {
        
        let (result, controller) = Signal<T,E>.create()
        
        self.observe(
            next: { value in
                if predicate(value) {
                    controller.sendNext(value)
                }
            },
            error: controller.sendError,
            completed: controller.sendCompleted)
        
        return result
    }
    
    func map <U> (transform: T -> U) -> Signal<U,E> {
        let (result, controller) = Signal<U,E>.create()
        
        self.observe(
            next: { value in
                controller.sendNext(transform(value))
            },
            error: controller.sendError,
            completed: controller.sendCompleted)
        
        return result
    }
    
}

let (signal, controller) = Signal<Int, ()>.create()
signal
    .filter { $0 % 2 == 0 }
    .map { $0 * $0 }
    .observe(next: println)

for i in 0...10 {
    controller.sendNext(i)
}








