import Combine
import Foundation

final class SchedulerMock: Scheduler {
    
    func schedule(
        after date: SchedulerTimeType,
        interval: SchedulerTimeType.Stride,
        tolerance: SchedulerTimeType.Stride,
        options: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) -> any Cancellable {
        action()
        return AnyCancellable {}
    }
    
    func schedule(
        after date: SchedulerTimeType,
        tolerance: SchedulerTimeType.Stride,
        options: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) {
        action()
    }
    
    func schedule(
        options: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) {
        action()
    }
    
    private(set) var now: DispatchQueue.SchedulerTimeType = .init(.init(uptimeNanoseconds: 0))
    let minimumTolerance: DispatchQueue.SchedulerTimeType.Stride = .nanoseconds(0)
    
    
    typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
    typealias SchedulerOptions = DispatchQueue.SchedulerOptions
}
