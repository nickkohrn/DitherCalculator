//
//  DitherCalculatorApp.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/22/25.
//

import CloudKit
import Models
import SwiftUI
import Syncing

// TODO: Handle errors
// TODO: Handle iCloud states
// TODO: Handle logging

@main
struct DitherCalculatorApp: App {
    @State private var cloudService = CloudService(
        container: CKContainer.default(),
        database: CKContainer.default().privateCloudDatabase
    )

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ConfigCalculationView()
                    .environment(cloudService)
            }
        }
    }
}
