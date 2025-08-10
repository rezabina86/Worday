import Foundation
@testable import Worday

final class SchedulerFactoryMock: SchedulerFactoryType {
    
    enum Call: Equatable {
        case makeMainScheduler
        case makeBackgroundScheduler
    }
    
    func makeMainScheduler() -> AnySchedulerType {
        calls.append(.makeMainScheduler)
        return makeMainSchedulerReturnValue
    }
    
    func makeBackgroundScheduler() -> AnySchedulerType {
        calls.append(.makeBackgroundScheduler)
        return makeBackgroundSchedulerReturnValue
    }
    
    private(set) var calls: [Call] = []
    var makeMainSchedulerReturnValue: AnySchedulerType!
    var makeBackgroundSchedulerReturnValue: AnySchedulerType!
}
