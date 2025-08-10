import Foundation
import Combine

public struct AnySchedulerType {
    public var now: DispatchQueue.SchedulerTimeType {
        _now()
    }
    
    public var minimumTolerance: DispatchQueue.SchedulerTimeType.Stride {
        _minimumTolerance()
    }
    
    private let _now: () -> DispatchQueue.SchedulerTimeType
    private let _minimumTolerance: () -> DispatchQueue.SchedulerTimeType.Stride
    private let _schedule: (DispatchQueue.SchedulerOptions?, @escaping () -> Void) -> Void
    private let _scheduleAfter: (DispatchQueue.SchedulerTimeType, DispatchQueue.SchedulerTimeType.Stride, DispatchQueue.SchedulerOptions?, @escaping () -> Void) -> Void
    private let _scheduleAfterInterval: (DispatchQueue.SchedulerTimeType, DispatchQueue.SchedulerTimeType.Stride, DispatchQueue.SchedulerTimeType.Stride, DispatchQueue.SchedulerOptions?, @escaping () -> Void) -> Cancellable
    
    public init<S: Scheduler>(_ scheduler: S) where
        S.SchedulerTimeType == DispatchQueue.SchedulerTimeType,
        S.SchedulerOptions == DispatchQueue.SchedulerOptions {
        
        _now = { scheduler.now }
        _minimumTolerance = { scheduler.minimumTolerance }
        _schedule = scheduler.schedule(options:_:)
        _scheduleAfter = scheduler.schedule(after:tolerance:options:_:)
        _scheduleAfterInterval = scheduler.schedule(after:interval:tolerance:options:_:)
    }
}

extension AnySchedulerType: Scheduler {
    public typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
    public typealias SchedulerOptions = DispatchQueue.SchedulerOptions
    
    public func schedule(options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) {
        _schedule(options, action)
    }
    
    public func schedule(after date: DispatchQueue.SchedulerTimeType, tolerance: DispatchQueue.SchedulerTimeType.Stride, options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) {
        _scheduleAfter(date, tolerance, options, action)
    }
    
    public func schedule(after date: DispatchQueue.SchedulerTimeType, interval: DispatchQueue.SchedulerTimeType.Stride, tolerance: DispatchQueue.SchedulerTimeType.Stride, options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
        _scheduleAfterInterval(date, interval, tolerance, options, action)
    }
}
