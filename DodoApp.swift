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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(taskManager)
                .environmentObject(dodoManager)
        }
    }
}
