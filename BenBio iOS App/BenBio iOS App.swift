//
//  BenBio_iOS_AppApp.swift
//  BenBio iOS App
//
//  Created by Gross, Benjamin on 25.02.24.
//

import SwiftUI

@main
struct BenBio_iOS_App: App {
    @Environment(\.scenePhase) private var scenePhase

    init() {
        enableGroupDefaultsAccess()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                Task {
                    await fetchHealthMetricsAndStore()
                }
            }
        }
    }
}
