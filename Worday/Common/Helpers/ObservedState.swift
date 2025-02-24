import Combine
import SwiftUI

@propertyWrapper
public struct ObservedState<State>: DynamicProperty {
    // MARK: Lifecycle
    
    public init(wrappedValue: State) {
        observable = Observable(initialState: wrappedValue)
    }
    
    // MARK: Public
    
    public var wrappedValue: State {
        get { observable.state }
        nonmutating set { observable.state = newValue }
    }
    
    public mutating func update() {
        _observable.update()
    }
    
    // MARK: Private
    
    private final class Observable: ObservableObject {
        // MARK: Lifecycle
        
        init(initialState: State) {
            state = initialState
        }
        
        // MARK: Internal
        
        @Published var state: State
        
        func update() {
            objectWillChange.send()
        }
    }
    
    @ObservedObject private var observable: Observable
}
