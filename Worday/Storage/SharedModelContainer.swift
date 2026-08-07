import SwiftData

let sharedModelContainer: ModelContainer = {
    do {
        let container = try ModelContainer(
            for: WordStorageEntity.self,
            migrationPlan: WordStorageMigrationPlan.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: false)
        )
        return container
    } catch {
        fatalError("Failed to create ModelContainer: \(error)")
    }
}()
