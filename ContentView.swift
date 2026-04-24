//
//  ContentView.swift
//  Dodo
//

import SwiftUI

// MARK: - Root Tab Shell

struct ContentView: View {
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var dodoManager: DodoManager
    @State private var selectedTab: AppTab = .today
    @State private var showGreeting = true

    enum AppTab { case today, tasks, growth }

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                TodayView()
                    .tabItem { Label("Today", systemImage: "sun.max.fill") }
                    .tag(AppTab.today)

                TaskListView()
                    .tabItem { Label("Tasks", systemImage: "checklist") }
                    .tag(AppTab.tasks)

                GrowthView()
                    .tabItem { Label("Growth", systemImage: "chart.line.uptrend.xyaxis") }
                    .tag(AppTab.growth)
            }
            .tint(Color.dodoOrange)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                withAnimation(.spring()) { showGreeting = true }
            }

            if showGreeting {
                GreetingSplashView(greeting: currentGreeting, isShowing: $showGreeting)
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
    }

    private var currentGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        default:      return "Good evening"
        }
    }
}

// MARK: - Greeting Splash

struct GreetingSplashView: View {
    let greeting: String
    @Binding var isShowing: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { withAnimation(.spring()) { isShowing = false } }

            VStack(spacing: 12) {
                Text(greeting == "Good morning" ? "🌅" : greeting == "Good afternoon" ? "☀️" : "🌙")
                    .font(.system(size: 60))
                Text(greeting)
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                Text("You've got tasks. The question is whether you'll actually do them.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
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
            .background(Color(.systemGray6).opacity(0.97))
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
    @State private var bannerDismissed = false

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        default:      return "Good evening"
        }
    }
    private var missedYesterday: Bool {
        let cal = Calendar.current
        guard let yesterday = cal.date(byAdding: .day, value: -1, to: Date().startOfDay) else { return false }
        guard taskManager.hasTasks(for: yesterday) else { return false }
        return taskManager.progress(for: yesterday) < 0.5
    }

    private var missedYesterdayCount: Int {
        let cal = Calendar.current
        guard let yesterday = cal.date(byAdding: .day, value: -1, to: Date().startOfDay) else { return 0 }
        return taskManager.tasks(for: yesterday).filter { !$0.isCompleted }.count
    }

    private var shouldShowRecoveryBanner: Bool {
        missedYesterday && !bannerDismissed && completedToday.isEmpty
    }

    private var tagline: String {
        let lines = [
            "You know what you need to do.",
            "Either you do it or you don't.",
            "No one's coming to save you.",
            "Your streak won't keep itself.",
            "The gap between you and your potential is today.",
            "Small wins add up. So do excuses.",
            "Do the thing you've been putting off.",
            "You've been here before. Finish this time.",
            "Stop thinking. Start doing.",
            "Future you is watching.",
            "Discipline is just doing it when you don't feel like it.",
            "You already know what needs to happen.",
        ]
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return lines[dayOfYear % lines.count]
    }

    private var todayTasks: [TodoTask] {
        taskManager.tasks.filter { !$0.isCompleted && Calendar.current.isDateInToday($0.dueDate) }
    }

    private var completedToday: [TodoTask] {
        taskManager.tasks.filter { task in
            guard task.isCompleted, let date = task.completedDate else { return false }
            return Calendar.current.isDateInToday(date)
        }
    }

    // Weekly completion % for the mini stat
    private var weeklyPercent: Int {
        let cal = Calendar.current
        var total: Double = 0
        var validDays = 0
        for i in 0..<7 {
            guard let date = cal.date(byAdding: .day, value: -i, to: Date().startOfDay) else { continue }
            guard taskManager.hasTasks(for: date) else { continue }
            total += taskManager.progress(for: date)
            validDays += 1
        }
        guard validDays > 0 else { return 0 }
        return Int((total / Double(validDays)) * 100)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text(greeting)
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text(tagline)
                            .font(.largeTitle.bold())
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Recovery banner
                    if shouldShowRecoveryBanner {
                        RecoveryBannerCard(missedCount: missedYesterdayCount) {
                            withAnimation(.spring(response: 0.4)) {
                                bannerDismissed = true
                            }
                            UserDefaults.standard.set(Date(), forKey: "recoveryBannerDismissedDate")
                        }
                        .padding(.horizontal)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    // Mini stats row
                    UserStatsRow(
                        streak: dodoManager.stats.currentStreak,
                        doneToday: completedToday.count,
                        totalToday: completedToday.count + todayTasks.count,
                        weeklyPercent: weeklyPercent
                    )
                    .padding(.horizontal)

                    // Progress bar
                    if !completedToday.isEmpty || !todayTasks.isEmpty {
                        ProgressSummaryCard(
                            completed: completedToday.count,
                            total: completedToday.count + todayTasks.count
                        )
                        .padding(.horizontal)
                    }

                    // Task list
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
                                Button("See all \(todayTasks.count) tasks →") { }
                                    .font(.subheadline)
                                    .foregroundColor(.dodoOrange)
                                    .padding(.horizontal)
                            }
                        }
                    }

                    Spacer(minLength: 40)
                }
            }
            .onAppear {
                if let date = UserDefaults.standard.object(forKey: "recoveryBannerDismissedDate") as? Date,
                   Calendar.current.isDateInToday(date) {
                    bannerDismissed = true
                }
                if missedYesterday {
                    dodoManager.resetStreak()
                }
            }
            .animation(.spring(response: 0.4), value: shouldShowRecoveryBanner)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTask = true }) {
                        Image(systemName: "plus").fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView().environmentObject(taskManager)
            }
        }
    }
}

// MARK: - User Stats Row (replaces DodoStatusCard)

struct UserStatsRow: View {
    let streak: Int
    let doneToday: Int
    let totalToday: Int
    let weeklyPercent: Int

    var body: some View {
        HStack(spacing: 10) {
            MiniStatCard(value: "\(streak)", label: "day streak", icon: "flame.fill", color: .dodoOrange)
            MiniStatCard(
                value: "\(doneToday)/\(totalToday)",
                label: "done today",
                icon: "checkmark.circle.fill",
                color: .green
            )
            MiniStatCard(value: "\(weeklyPercent)%", label: "this week", icon: "chart.bar.fill", color: .blue)
        }
    }
}

struct MiniStatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Progress Summary Card

struct ProgressSummaryCard: View {
    let completed: Int
    let total: Int

    private var progress: Double { total == 0 ? 0 : Double(completed) / Double(total) }

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
            Text("🎉").font(.system(size: 36))
            VStack(alignment: .leading, spacing: 2) {
                Text("All done!")
                    .font(.headline)
                Text("Done. That's what showing up looks like")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.dodoOrange.opacity(0.08))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.dodoOrange.opacity(0.2), lineWidth: 1))
        .cornerRadius(12)
    }
}

// MARK: - Growth View (replaces DodoView)

struct GrowthView: View {
    @EnvironmentObject var dodoManager: DodoManager
    @EnvironmentObject var taskManager: TaskManager

    private var thisWeek: [Date] {
        let cal = Calendar.current
        var result: [Date] = []
        for i in stride(from: 6, through: 0, by: -1) {
            if let d = cal.date(byAdding: .day, value: -i, to: Date().startOfDay) {
                result.append(d)
            }
        }
        return result
    }

    private var categoryBreakdown: [(TodoTask.TaskCategory, Int)] {
        var result: [(TodoTask.TaskCategory, Int)] = []
        for cat in TodoTask.TaskCategory.allCases {
            let count = taskManager.tasks.filter { $0.category == cat && $0.isCompleted }.count
            result.append((cat, count))
        }
        return result.sorted { $0.1 > $1.1 }
    }

    private var maxCategoryCount: Int {
        categoryBreakdown.map(\.1).max() ?? 1
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // streak
                    StreakHeaderCard()
                        .padding(.horizontal)

                    // Activity heatmap
                    ActivityHeatmapView()
                        .environmentObject(taskManager)
                        .padding(.horizontal)

                    // Personal stats
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your stats")
                            .font(.headline)
                            .padding(.horizontal)

                        VStack(spacing: 10) {
                            PersonalStatRow(
                                icon: "bolt.fill",
                                label: "Focus",
                                value: dodoManager.focus(from: taskManager),
                                color: .dodoOrange,
                                tip: "Drops when you go quiet. Stay active."
                            )
                            PersonalStatRow(
                                icon: "heart.fill",
                                label: "Mood",
                                value: dodoManager.mood(from: taskManager),
                                color: .pink,
                                tip: "Do something. Anything. It compounds."
                            )
                            PersonalStatRow(
                                icon: "arrow.triangle.2.circlepath",
                                label: "Consistency",
                                value: dodoManager.consistency(from: taskManager),
                                color: .green,
                                tip: "Health tasks build the base. Don't skip them."
                            )
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 16)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // Category breakdown
                    VStack(alignment: .leading, spacing: 12) {
                        Text("By category")
                            .font(.headline)
                            .padding(.horizontal)

                        VStack(spacing: 10) {
                            ForEach(categoryBreakdown, id: \.0) { cat, count in
                                CategoryRow(category: cat, count: count, maxCount: maxCategoryCount)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 16)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // XP progress to next level
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Level \(dodoManager.stats.level)")
                                .font(.subheadline.bold())
                            Spacer()
                            Text("\(dodoManager.stats.xpToNextLevel) XP to next level")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        ProgressView(value: Double(dodoManager.stats.totalTasksCompleted % 10), total: 10)
                            .tint(.dodoOrange)
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                    }
                    .padding(16)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    Spacer(minLength: 40)
                }
                .padding(.top, 8)
            }
            .navigationTitle("Your Growth")
        }
    }
}

// MARK: - Growth Sub-components

struct GrowthStatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon).foregroundColor(color).font(.system(size: 16))
            Text(value).font(.title2.bold()).foregroundColor(.primary)
            Text(label).font(.caption2).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct WeekDayBar: View {
    let date: Date
    let progress: Double
    let hasTasks: Bool

    private var isToday: Bool { Calendar.current.isDateInToday(date) }
    private var dayLetter: String {
        let f = DateFormatter(); f.dateFormat = "EEE"; return String(f.string(from: date).prefix(1))
    }

    var body: some View {
        VStack(spacing: 4) {
            GeometryReader { geo in
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: geo.size.height)
                    if hasTasks {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(isToday ? Color.dodoOrange : Color.dodoOrange.opacity(0.6))
                            .frame(height: max(4, geo.size.height * progress))
                    }
                }
            }
            .frame(height: 60)

            Text(dayLetter)
                .font(.system(size: 10, weight: isToday ? .bold : .regular))
                .foregroundColor(isToday ? .dodoOrange : .secondary)

            if hasTasks {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            } else {
                Text("–")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary.opacity(0.4))
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct PersonalStatRow: View {
    let icon: String
    let label: String
    let value: Double
    let color: Color
    let tip: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon).foregroundColor(color)
                Text(label).font(.subheadline.bold())
                Spacer()
                Text("\(Int(value))%").font(.subheadline.bold()).foregroundColor(color)
            }
            ProgressView(value: value, total: 100).tint(color).scaleEffect(x: 1, y: 2, anchor: .center)
            Text(tip).font(.caption).foregroundColor(.secondary)
        }
        .padding(14)
        .background(color.opacity(0.06))
        .cornerRadius(12)
    }
}

struct CategoryRow: View {
    let category: TodoTask.TaskCategory
    let count: Int
    let maxCount: Int

    private var barWidth: Double {
        maxCount == 0 ? 0 : Double(count) / Double(maxCount)
    }

    private var color: Color {
        switch category {
        case .school:   return .dodoOrange
        case .health:   return .green
        case .personal: return Color(red: 0.4, green: 0.6, blue: 1.0)
        case .social:   return Color(red: 0.9, green: 0.4, blue: 0.7)
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(category.emoji).font(.system(size: 18)).frame(width: 24)
            Text(category.rawValue)
                .font(.subheadline)
                .frame(width: 70, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(color.opacity(0.12)).frame(height: 8)
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * barWidth, height: 8)
                }
            }
            .frame(height: 8)

            Text("\(count)")
                .font(.subheadline.bold())
                .foregroundColor(color)
                .frame(width: 28, alignment: .trailing)
        }
    }
}

// MARK: - Design Tokens

extension Color {
    static let dodoOrange = Color(red: 0.976, green: 0.451, blue: 0.086)
}

// MARK: - Recovery Banner

struct RecoveryBannerCard: View {
    let missedCount: Int
    let onDismiss: () -> Void

    private var headline: String {
        let options = [
            "Yesterday's gone.",
            "You missed yesterday.",
            "Streak reset."
        ]
        return options[Calendar.current.component(.day, from: Date()) % options.count]
    }

    private var subtext: String {
        let task = missedCount == 1 ? "task" : "tasks"
        let options = [
            "You had \(missedCount) \(task) sitting there. Not today.",
            "\(missedCount) \(task) undone. That's done. Today isn't.",
            "\(missedCount) \(task) left behind yesterday. Build again from now."
        ]
        return options[Calendar.current.component(.day, from: Date()) % options.count]
    }

    var body: some View {
        HStack(spacing: 0) {
            // Orange left accent bar
            Rectangle()
                .fill(Color.dodoOrange)
                .frame(width: 3)
                .clipShape(RoundedRectangle(cornerRadius: 2))

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(headline)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary)
                    Text(subtext)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(6)
                        .background(Color(.tertiarySystemBackground))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
        .background(Color.dodoOrange.opacity(0.07))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.dodoOrange.opacity(0.2), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
// MARK: - Streak Header Card (Duolingo-style)

struct StreakHeaderCard: View {
    @EnvironmentObject var dodoManager: DodoManager
    @EnvironmentObject var taskManager: TaskManager

    private var weekDays: [(letter: String, completed: Bool, isToday: Bool, isFuture: Bool)] {
        let cal = Calendar.current
        let today = Date().startOfDay
        let weekday = cal.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        guard let monday = cal.date(byAdding: .day, value: -daysFromMonday, to: today) else { return [] }

        return (0..<7).map { i in
            guard let date = cal.date(byAdding: .day, value: i, to: monday) else {
                return (letter: "-", completed: false, isToday: false, isFuture: false)
            }
            let isFuture = date > today
            let isToday  = cal.isDateInToday(date)
            let done     = !isFuture
                        && taskManager.hasTasks(for: date)
                        && taskManager.progress(for: date) >= 0.5
            return (letter: ["M","T","W","T","F","S","S"][i],
                    completed: done,
                    isToday: isToday,
                    isFuture: isFuture)
        }
    }

    var body: some View {
        VStack(spacing: 16) {

            // Flame + number
            HStack(spacing: 14) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.dodoOrange)

                VStack(alignment: .leading, spacing: 0) {
                    Text("\(dodoManager.stats.currentStreak)")
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundColor(.dodoOrange)
                    Text("day streak")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                Spacer()
            }

            // Week header row
            HStack {
                Text("This week")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                Spacer()
                Text("Keep it going →")
                    .font(.system(size: 11))
                    .foregroundColor(.dodoOrange)
            }

            // 7 day circles
            HStack(spacing: 0) {
                ForEach(Array(weekDays.enumerated()), id: \.offset) { _, day in
                    VStack(spacing: 5) {
                        ZStack {
                            Circle()
                                .fill(day.completed
                                      ? Color.dodoOrange
                                      : Color.white.opacity(0.06))
                                .frame(width: 34, height: 34)

                            if day.isToday && !day.completed {
                                Circle()
                                    .stroke(Color.dodoOrange, lineWidth: 1.5)
                                    .frame(width: 34, height: 34)
                            }

                            if day.completed {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.black)
                            }
                        }

                        Text(day.letter)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(day.completed
                                             ? .dodoOrange
                                             : Color.white.opacity(0.25))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(18)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// MARK: - Activity Heatmap

struct ActivityHeatmapView: View {
    @EnvironmentObject var taskManager: TaskManager

    private let totalWeeks = 13

    private var columns: [[Date?]] {
        let cal = Calendar.current
        let today = Date().startOfDay
        let weekday = cal.component(.weekday, from: today)
        let daysFromSunday = weekday - 1
        guard let thisSunday = cal.date(
            byAdding: .day, value: -daysFromSunday, to: today) else { return [] }

        return (0..<totalWeeks).map { w in
            let weekOffset = w - (totalWeeks - 1)
            return (0..<7).map { d -> Date? in
                guard let date = cal.date(
                    byAdding: .day,
                    value: weekOffset * 7 + d,
                    to: thisSunday) else { return nil }
                return date > today ? nil : date
            }
        }
    }

    private func cellColor(for date: Date?) -> Color {
        guard let date else {
            return Color.clear
        }
        
        guard taskManager.hasTasks(for: date) else {
            return Color.white.opacity(0.07)
        }
        let p = taskManager.progress(for: date)
        switch p {
        case 0.75...1.0: return Color(red: 0.976, green: 0.451, blue: 0.086)
        case 0.25..<0.75: return Color(red: 0.769, green: 0.306, blue: 0.0)
        default:          return Color(red: 0.478, green: 0.180, blue: 0.0)
        }
    }

    // Month label: (name, column index) where month first appears
    private var monthLabels: [(String, Int)] {
        let cal = Calendar.current
        var labels: [(String, Int)] = []
        var lastMonth = -1
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"

        for (colIdx, col) in columns.enumerated() {
            let firstDate = col.compactMap { $0 }.first
            guard let date = firstDate else { continue }
            let month = cal.component(.month, from: date)
            if month != lastMonth {
                labels.append((formatter.string(from: date), colIdx))
                lastMonth = month
            }
        }
        return labels
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Activity — last 3 months")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
                .tracking(0.5)
                .textCase(.uppercase)
                .padding(.bottom, 8)

            // Month labels row
            GeometryReader { geo in
                let totalGaps = CGFloat(totalWeeks - 1) * 3
                let colWidth = (geo.size.width - totalGaps) / CGFloat(totalWeeks)

                ZStack(alignment: .topLeading) {
                    ForEach(monthLabels, id: \.1) { name, col in
                        Text(name)
                            .font(.system(size: 9))
                            .foregroundColor(Color.white.opacity(0.4))
                            .offset(x: CGFloat(col) * (colWidth + 3))
                    }
                }
            }
            .frame(height: 14)

            // Grid
            GeometryReader { geo in
                let totalGaps = CGFloat(totalWeeks - 1) * 3
                let colWidth = (geo.size.width - totalGaps) / CGFloat(totalWeeks)

                HStack(spacing: 3) {
                    ForEach(Array(columns.enumerated()), id: \.offset) { _, col in
                        VStack(spacing: 3) {
                            ForEach(Array(col.enumerated()), id: \.offset) { _, date in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(date == nil ? Color.clear : cellColor(for: date))
                                    .frame(width: colWidth, height: colWidth)
                            }
                        }
                    }
                }
            }
            .aspectRatio(CGFloat(totalWeeks) / 7, contentMode: .fit)

            // Legend
            HStack(spacing: 6) {
                Spacer()
                Text("less")
                    .font(.system(size: 9))
                    .foregroundColor(Color.white.opacity(0.3))
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 11, height: 11)
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(red: 0.478, green: 0.180, blue: 0.0))
                    .frame(width: 11, height: 11)
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(red: 0.769, green: 0.306, blue: 0.0))
                    .frame(width: 11, height: 11)
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(red: 0.976, green: 0.451, blue: 0.086))
                    .frame(width: 11, height: 11)
                Text("more")
                    .font(.system(size: 9))
                    .foregroundColor(Color.white.opacity(0.3))
            }
            .padding(.top, 8)
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

#Preview {
    ContentView()
        .environmentObject(TaskManager())
        .environmentObject(DodoManager())
        .preferredColorScheme(.dark)
}
