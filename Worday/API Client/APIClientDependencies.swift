import Foundation

extension ContainerType {
    func registerAPIClientDependencies() {
        register(in: .container) { container in
            HTTPClient(sessionFactory: container.resolve(),
                       extendedCache: true)
            as HTTPClientType
        }

        register { _ in URLSessionFactory() as URLSessionFactoryType }
    }
}
