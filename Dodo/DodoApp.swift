//
//  DodoApp.swift
//  Dodo - Life Gamification
//

import SwiftUI
import Combine

@main
struct DodoApp: App {
    @StateObject private var taskManager = TaskManager()
    @StateObject private var dodoManager = DodoManager()
    @StateObject private var stats = StatsManager()
    @StateObject private var timeBlockManager = TimeBlockManager()

    var body: some Scene {
        WindowGroup {
            let _ = print("🟠 App launched")
            RootView()
                .environmentObject(taskManager)
                .environmentObject(dodoManager)
                .environmentObject(stats)
                .environmentObject(timeBlockManager)
                .preferredColorScheme(.dark)
        }
    }
}
