//
//  DitherCalculatorApp.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/22/25.
//

import Models
import SwiftUI

// TODO: Handle errors
// TODO: Handle iCloud states

@main
struct DitherCalculatorApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ConfigCalculationView()
            }
        }
    }
}
