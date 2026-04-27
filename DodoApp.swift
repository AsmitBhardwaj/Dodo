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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(taskManager)
                .environmentObject(dodoManager)
                .environmentObject(stats)
                .preferredColorScheme(.dark)
        }
    }
}
