//
//  ContentView.swift
//  Dodo - Life Gamification
//

import SwiftUI

// MARK: - Root Tab Shell


struct ContentView: View {
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var dodoManager: DodoManager
    @State private var selectedTab: AppTab = .today
    @State private var showGreeting = true          // ADD T

    enum AppTab{case today, tasks, dodo}

    var body: some View {
        ZStack {                                     // WRAP IN ZSTACK
            TabView(selection: $selectedTab) {
                TodayView()
                    .tabItem { Label("Today", systemImage: "sun.max.fill") }
                    .tag(AppTab.today)

                TaskListView()
                    .tabItem { Label("Tasks", systemImage: "checklist") }
                    .tag(AppTab.tasks)

                DodoView()
                    .tabItem { Label("Dodo", systemImage: "bird.fill") }
                    .tag(AppTab.dodo)
            }
            .tint(Color.dodoOrange)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                dodoManager.recalculateDecayOnForeground()
                withAnimation(.spring()) { showGreeting = true }  // ADD THIS
            }

            if showGreeting {                        // ADD THIS BLOCK
                GreetingSplashView(greeting: currentGreeting, isShowing: $showGreeting)
                    .transition(AnyTransition.opacity)
                    .zIndex(1)
            }
        }
    }

    private var currentGreeting: String {           // ADD THIS
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        default:      return "Good evening"
        }
    }
}
struct GreetingSplashView: View {
    let greeting: String
    @Binding var isShowing: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { withAnimation(.spring()) { isShowing = false } }

            VStack(spacing: 12) {
                Text(greeting == "Good morning" ? "🌅" : greeting == "Good afternoon" ? "☀️" : "🌙")
                    .font(.system(size: 60))
                Text(greeting)
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                Text("Ready to level up today?")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                Button("Let's go →") {
                    withAnimation(.spring()) { isShowing = false }
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
                .background(Color.dodoOrange)
                .foregroundColor(.white)
                .cornerRadius(25)
                .padding(.top, 8)
            }
            .padding(32)
            .background(Color(.systemGray6).opacity(0.95))
            .cornerRadius(24)
            .padding(40)
        }
    }
}

// MARK: - Today Dashboard

struct TodayView: View {
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var dodoManager: DodoManager
    @State private var showingAddTask = false

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        default:      return "Good evening"
        }
    }

    private var todayTasks: [TodoTask] {
        taskManager.tasks.filter { !$0.isCompleted }
    }
    
    private var tagline: String {
        let lines: [String] = [
            "Welcome back.",
            "Back at it.",
            "Let's get things done.",
            "Your streak won't keep itself.",
            "One task at a time.",
            "Make today count.",
            "Dodo's counting on you.",
            "Stay locked in.",
            "Small wins add up.",
            "You showed up. That's half of it.",
            "Let's build something today.",
            "No days off.",
        ]
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return lines[dayOfYear % lines.count]
    }

    private var completedToday: [TodoTask] {
        taskManager.tasks.filter { task in
            guard task.isCompleted, let date = task.completedDate else { return false }
            return Calendar.current.isDateInToday(date)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // --- Header ---
                    VStack(alignment: .leading, spacing: 4) {
                        Text(greeting)
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text(tagline)
                            .font(.largeTitle.bold())
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // --- Dodo Status Card ---
                    DodoStatusCard()
                        .padding(.horizontal)

                    // --- Progress Summary ---
                    if !completedToday.isEmpty || !todayTasks.isEmpty {
                        ProgressSummaryCard(
                            completed: completedToday.count,
                            total: completedToday.count + todayTasks.count
                        )
                        .padding(.horizontal)
                    }

                    // --- Remaining Tasks ---
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Remaining")
                                .font(.headline)
                            Spacer()
                            Text("\(todayTasks.count) left")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)

                        if todayTasks.isEmpty {
                            AllDoneCard()
                                .padding(.horizontal)
                        } else {
                            // Reuse TaskRowView from TaskListView.swift
                            VStack(spacing: 0) {
                                ForEach(todayTasks.prefix(5)) { task in
                                    TaskCard(task: task)
                                        .padding(.horizontal)
                                        .padding(.vertical, 8)
                                    if task.id != todayTasks.prefix(5).last?.id {
                                        Divider().padding(.horizontal)
                                    }
                                }
                            }
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)

                            if todayTasks.count > 5 {
                                Button("See all \(todayTasks.count) tasks →") {
                                    // Switch to Tasks tab
                                }
                                .font(.subheadline)
                                .foregroundColor(.dodoOrange)
                                .padding(.horizontal)
                            }
                        }
                    }

                    Spacer(minLength: 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTask = true }) {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView()
                    .environmentObject(taskManager)
            }
        }
    }
}

// MARK: - Dodo Status Card

struct DodoStatusCard: View {
    @EnvironmentObject var dodoManager: DodoManager

    var body: some View {
        HStack(spacing: 16) {
            // Mood emoji
            Text(dodoManager.stats.moodEmoji)
                .font(.system(size: 52))

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Level \(dodoManager.stats.level)")
                        .font(.headline)
                    Text("• \(dodoManager.stats.statusMessage)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                MiniStatBar(label: "Hunger",    value: dodoManager.stats.hunger,    color: .dodoOrange)
                MiniStatBar(label: "Happiness", value: dodoManager.stats.happiness, color: .blue)
                MiniStatBar(label: "Health",    value: dodoManager.stats.health,    color: .green)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

struct MiniStatBar: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
                .frame(width: 58, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(color.opacity(0.15))
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(value / 100))
                }
            }
            .frame(height: 6)

            Text("\(Int(value))%")
                .font(.caption2)
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .trailing)
        }
    }
}

// MARK: - Progress Summary Card

struct ProgressSummaryCard: View {
    let completed: Int
    let total: Int

    private var progress: Double {
        total == 0 ? 0 : Double(completed) / Double(total)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("\(completed) of \(total) tasks done today")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.subheadline.bold())
                    .foregroundColor(.dodoOrange)
            }

            ProgressView(value: progress)
                .tint(.dodoOrange)
                .scaleEffect(x: 1, y: 1.5, anchor: .center)
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - All Done Card

struct AllDoneCard: View {
    var body: some View {
        HStack(spacing: 16) {
            Text("🎉")
                .font(.system(size: 36))
            VStack(alignment: .leading, spacing: 2) {
                Text("All done!")
                    .font(.headline)
                Text("Dodo is happy. Add more tasks to keep growing.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.dodoOrange.opacity(0.08))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.dodoOrange.opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

// MARK: - Dodo Detail View

struct DodoView: View {
    @EnvironmentObject var dodoManager: DodoManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Big mood display
                    VStack(spacing: 8) {
                        Text(dodoManager.stats.moodEmoji)
                            .font(.system(size: 100))
                        Text(dodoManager.stats.statusMessage)
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Text("Level \(dodoManager.stats.level) Dodo")
                            .font(.headline)
                    }
                    .padding(.top, 20)

                    // Stats
                    VStack(spacing: 14) {
                        StatDetailRow(
                            icon: "fork.knife",
                            label: "Hunger",
                            value: dodoManager.stats.hunger,
                            color: .dodoOrange,
                            tip: "Complete tasks to feed Dodo"
                        )
                        StatDetailRow(
                            icon: "heart.fill",
                            label: "Happiness",
                            value: dodoManager.stats.happiness,
                            color: .blue,
                            tip: "Complete any task to boost happiness"
                        )
                        StatDetailRow(
                            icon: "bolt.fill",
                            label: "Health",
                            value: dodoManager.stats.health,
                            color: .green,
                            tip: "Complete Health tasks to boost health"
                        )
                    }
                    .padding(.horizontal)

                    // Lifetime stats
                    HStack(spacing: 12) {
                        LifetimeStatCard(
                            value: "\(dodoManager.stats.totalTasksCompleted)",
                            label: "Tasks\ncompleted"
                        )
                        LifetimeStatCard(
                            value: "\(dodoManager.stats.level)",
                            label: "Current\nlevel"
                        )
                        LifetimeStatCard(
                            value: "\(dodoManager.stats.level * 10)",
                            label: "XP to next\nlevel"
                        )
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Your Dodo")
        }
    }
}

struct StatDetailRow: View {
    let icon: String
    let label: String
    let value: Double
    let color: Color
    let tip: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(label)
                    .font(.subheadline.bold())
                Spacer()
                Text("\(Int(value))%")
                    .font(.subheadline.bold())
                    .foregroundColor(color)
            }

            ProgressView(value: value, total: 100)
                .tint(color)
                .scaleEffect(x: 1, y: 2, anchor: .center)

            Text(tip)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(14)
        .background(color.opacity(0.06))
        .cornerRadius(12)
    }
}

struct LifetimeStatCard: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .foregroundColor(.dodoOrange)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Design Tokens

extension Color {
    static let dodoOrange = Color(red: 0.976, green: 0.451, blue: 0.086) // #F97316
}

#Preview {
    ContentView()
        .environmentObject(TaskManager())
        .environmentObject(DodoManager())
        .preferredColorScheme(.dark)
}
