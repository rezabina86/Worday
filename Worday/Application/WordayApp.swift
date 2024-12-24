//
//  WordayApp.swift
//  Worday
//
//  Created by Reza Bina on 23.12.24.
//

import SwiftUI

@main
struct WordayApp: App {
    
    init(container: ContainerType) {
        self.container = container
        configureDependencies(container)
    }
    
    init() {
        self.init(container: Container())
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    // MARK: - Privates
    private let container: ContainerType
    private var configureDependencies = injectDependencies
}
