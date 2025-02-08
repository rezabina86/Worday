import Combine

final class TestableSubscriber<Input, Failure: Error>: Subscriber {
    
    private(set) var receivedValues: [Input] = []
    private(set) var receivedCompletion: Subscribers.Completion<Failure>?
    
    func receive(subscription: Subscription) {
        self.subscription = subscription
        subscription.request(.unlimited)
    }
    
    func receive(_ input: Input) -> Subscribers.Demand {
        receivedValues.append(input)
        return .unlimited
    }
    
    func receive(completion: Subscribers.Completion<Failure>) {
        receivedCompletion = completion
    }
    
    func cancel() {
        subscription?.cancel()
    }
    
    // MARK: - Privates
    private var subscription: Subscription?
}
