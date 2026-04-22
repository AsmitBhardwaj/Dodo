//
//  TaskListView.swift
//  Dodo - Life Gamification
//

import SwiftUI

// MARK: - Main Task List (Tasks Tab)

struct TaskListView: View {
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var dodoManager: DodoManager
    @State private var selectedDate: Date = Date().startOfDay
    @State private var showingAddTask = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Horizontal week calendar
                WeekCalendarView(selectedDate: $selectedDate)
                    .padding(.top, 8)

                Divider()
                    .background(Color.white.opacity(0.08))

                // Task list for selected date
                let dayTasks = taskManager.tasks(for: selectedDate)

                if dayTasks.isEmpty {
                    EmptyDayView(date: selectedDate)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 10) {
                            // Pending first
                            ForEach(taskManager.pendingTasks(for: selectedDate)) { task in
                                TaskCard(task: task)
                                    .environmentObject(taskManager)
                                    .environmentObject(dodoManager)
                            }
                            // Completed below, slightly dimmed
                            let done = taskManager.completedTasks(for: selectedDate)
                            if !done.isEmpty {
                                HStack {
                                    Text("Completed")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(done.count)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal)
                                .padding(.top, 8)

                                ForEach(done) { task in
                                    TaskCard(task: task)
                                        .environmentObject(taskManager)
                                        .environmentObject(dodoManager)
                                        .opacity(0.5)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Tasks")
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
                AddTaskView(defaultDate: selectedDate)
                    .environmentObject(taskManager)
            }
        }
    }
}

// MARK: - Week Calendar Header

struct WeekCalendarView: View {
    @Binding var selectedDate: Date
    @EnvironmentObject var taskManager: TaskManager

    /// 14-day window: 7 days back, today, 6 days forward
    private var dates: [Date] {
        let cal = Calendar.current
        return (-7...6).compactMap { offset in
            cal.date(byAdding: .day, value: offset, to: Date().startOfDay)
        }
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(dates, id: \.self) { date in
                        DateCell(
                            date: date,
                            isSelected: date.isSameDay(as: selectedDate),
                            progress: taskManager.progress(for: date),
                            hasTasks: taskManager.hasTasks(for: date)
                        )
                        .id(date)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                selectedDate = date
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            .onAppear {
                proxy.scrollTo(Date().startOfDay, anchor: .center)
            }
        }
    }
}

// MARK: - Individual Date Cell with Progress Ring

struct DateCell: View {
    let date: Date
    let isSelected: Bool
    let progress: Double
    let hasTasks: Bool

    private var dayLetter: String {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return String(f.string(from: date).prefix(3))
    }

    private var dayNumber: String {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f.string(from: date)
    }

    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    var body: some View {
        VStack(spacing: 6) {
            Text(dayLetter)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(isSelected ? .dodoOrange : .secondary)

            ZStack {
                // Background ring track
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 3)
                    .frame(width: 40, height: 40)

                // Progress ring — only show if there are tasks
                if hasTasks {
                    Circle()
                        .trim(from: 0, to: CGFloat(progress))
                        .stroke(
                            isSelected ? Color.dodoOrange : Color.dodoOrange.opacity(0.5),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 40, height: 40)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.4), value: progress)
                }

                // Fill for selected / today
                Circle()
                    .fill(
                        isSelected
                            ? Color.dodoOrange
                            : (isToday ? Color.dodoOrange.opacity(0.15) : Color.clear)
                    )
                    .frame(width: 34, height: 34)

                Text(dayNumber)
                    .font(.system(size: 15, weight: isSelected || isToday ? .bold : .regular))
                    .foregroundColor(isSelected ? .black : (isToday ? .dodoOrange : .primary))
            }
        }
        .frame(width: 44)
    }
}

// MARK: - Task Card

struct TaskCard: View {
    let task: TodoTask
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var dodoManager: DodoManager
    @State private var showConfetti = false

    private var cardColor: Color {
        switch task.category.color {
        case "orange": return Color(red: 0.45, green: 0.12, blue: 0.03)
        case "green":  return Color(red: 0.03, green: 0.25, blue: 0.10)
        case "purple": return Color(red: 0.18, green: 0.06, blue: 0.30)
        case "blue":   return Color(red: 0.03, green: 0.15, blue: 0.35)
        default:       return Color(.secondarySystemBackground)
        }
    }

    private var accentColor: Color {
        switch task.category.color {
        case "orange": return .dodoOrange
        case "green":  return .green
        case "purple": return .purple
        case "blue":   return .blue
        default:       return .gray
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            // Category icon badge
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.2))
                    .frame(width: 42, height: 42)
                Text(task.category.emoji)
                    .font(.system(size: 20))
            }

            // Task info
            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                    .strikethrough(task.isCompleted)

                Text(task.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Complete button
            if !task.isCompleted {
                Button(action: completeTask) {
                    ZStack {
                        Circle()
                            .stroke(accentColor, lineWidth: 2)
                            .frame(width: 36, height: 36)
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(accentColor)
                    }
                }
                .buttonStyle(.plain)
            } else {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(accentColor.opacity(0.5))
                    .font(.system(size: 22))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(cardColor)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(accentColor.opacity(0.25), lineWidth: 1)
        )
        .overlay(
            Group {
                if showConfetti { ConfettiView() }
            }
        )
    }

    private func completeTask() {
        withAnimation(.spring()) {
            taskManager.completeTask(task)
            if task.category == .health {
                dodoManager.completeHealthTask(amount: task.rewardValue)
            } else {
                dodoManager.feedDodo(amount: task.rewardValue)
            }
            showConfetti = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showConfetti = false
            }
        }
    }
}

// MARK: - Empty State

struct EmptyDayView: View {
    let date: Date

    private var isFuture: Bool {
        date > Date().startOfDay
    }

    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(isFuture ? "🗓️" : (isToday ? "✅" : "💤"))
                .font(.system(size: 52))

            Text(isFuture
                 ? "A clean slate for Dodo."
                 : (isToday ? "Nothing due today." : "Nothing was logged here."))
                .font(.title3.bold())
                .multilineTextAlignment(.center)

            Text(isFuture
                 ? "Add a task to stay ahead."
                 : (isToday ? "Add a task to keep Dodo happy." : "Past days are read-only."))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

// MARK: - Confetti (reused from original)

struct ConfettiView: View {
    var body: some View {
        ZStack {
            ForEach(0..<15, id: \.self) { _ in
                Circle()
                    .fill(Color.random)
                    .frame(width: 8, height: 8)
                    .modifier(ParticleModifier())
            }
        }
    }
}

struct ParticleModifier: ViewModifier {
    @State private var offset: CGSize = .zero
    @State private var opacity: Double = 1

    func body(content: Content) -> some View {
        content
            .offset(offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 1.5)) {
                    offset = CGSize(
                        width: CGFloat.random(in: -100...100),
                        height: CGFloat.random(in: -150...(-50))
                    )
                    opacity = 0
                }
            }
    }
}

extension Color {
    static var random: Color {
        Color(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1))
    }
}

#Preview {
    TaskListView()
        .environmentObject(TaskManager())
        .environmentObject(DodoManager())
        .preferredColorScheme(.dark)
}
