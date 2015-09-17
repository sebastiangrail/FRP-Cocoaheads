//: A simple signal class

//: Signal only has the type of the value as a parameter, we will handle errors and completed later.
class Signal <T> {
//: Observers are just functions
    typealias Observer = T -> Void
    
    private var observers = [Observer]()
    
    func observe (observer: Observer) {
        observers.append(observer)
    }
    
    func sendNext (value: T) {
        observers.forEach { $0(value) }
    }
}

let signal = Signal<Int>()
signal.observe(println)

for i in 0...10 {
    signal.sendNext(i)
}

/*:
 The problem here is that the signal can be controlled by everyone.
 We need to be able to pass a signal around without receiver being able to send new values on it.
 See [the next page](@next) on how to achieve this
 */
