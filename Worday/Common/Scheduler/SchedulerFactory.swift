import Foundation

protocol SchedulerFactoryType {
    func makeMainScheduler() -> AnySchedulerType
    func makeBackgroundScheduler() -> AnySchedulerType
}

struct SchedulerFactory: SchedulerFactoryType {
    func makeMainScheduler() -> AnySchedulerType {
        AnySchedulerType(DispatchQueue.main)
    }
    
    func makeBackgroundScheduler() -> AnySchedulerType {
        AnySchedulerType(DispatchQueue.global(qos: .background))
    }
}
