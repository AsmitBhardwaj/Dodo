//
//  TaskListView.swift
//  Dodo - Life Gamification
//

import SwiftUI

// MARK: - Root Tasks Tab

struct TaskListView: View {
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var dodoManager: DodoManager

    @State private var selectedDate: Date? = nil
    @State private var currentPage: Int = 200      // 200 = today's month (anchor)
    @State private var draggingTask: TodoTask? = nil
    @State private var showingAddTask = false

    private let anchor = 200

    private func monthForPage(_ page: Int) -> Date {
        let base = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))!
        return Calendar.current.date(byAdding: .month, value: page - anchor, to: base)!
    }

    private var displayedMonth: Date { monthForPage(currentPage) }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // ── Month title + Today jump ─────────────────────────────
                HStack {
                    Text(displayedMonth, format: .dateTime.month(.wide).year())
                        .font(.system(size: 17, weight: .semibold))
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.2), value: currentPage)
                    Spacer()
                    if currentPage != anchor {
                        Button("Today") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage = anchor
                                selectedDate = nil
                            }
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.dodoOrange)
                        .transition(.opacity)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 2)
                .animation(.easeInOut(duration: 0.2), value: currentPage)

                // ── Swipeable month grid (replaces arrow buttons) ─────────
                TabView(selection: $currentPage) {
                    ForEach(0..<400, id: \.self) { page in
                        MonthGridView(
                            displayedMonth: .constant(monthForPage(page)),
                            selectedDate: $selectedDate,
                            draggingTask: $draggingTask
                        )
                        .environmentObject(taskManager)
                        .environmentObject(dodoManager)
                        .tag(page)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 390)

                if let date = selectedDate {
                    Divider().background(Color.white.opacity(0.08))
                    TaskDayList(selectedDate: date, draggingTask: $draggingTask)
                        .environmentObject(taskManager)
                        .environmentObject(dodoManager)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTask = true }) {
                        Image(systemName: "plus").fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView(defaultDate: selectedDate ?? Date().startOfDay)
                    .environmentObject(taskManager)
            }
        }
    }
}

// MARK: - Month Grid

struct MonthGridView: View {
    @Binding var displayedMonth: Date
    @Binding var selectedDate: Date?
    @Binding var draggingTask: TodoTask?
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var dodoManager: DodoManager

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 1), count: 7)
    private let dayLetters = ["S","M","T","W","T","F","S"]

    private var daysInGrid: [Date?] {
        let cal = Calendar.current
        guard
            let monthStart = cal.date(from: cal.dateComponents([.year, .month], from: displayedMonth)),
            let range = cal.range(of: .day, in: .month, for: monthStart)
        else { return [] }

        let offset = cal.component(.weekday, from: monthStart) - 1
        var days: [Date?] = Array(repeating: nil, count: offset)
        for i in 0..<range.count {
            if let d = cal.date(byAdding: .day, value: i, to: monthStart) { days.append(d) }
        }
        while days.count % 7 != 0 { days.append(nil) }
        return days
    }

    private var maxTasksThisMonth: Int {
        daysInGrid.compactMap { $0 }
            .map { taskManager.tasks(for: $0).count }
            .max() ?? 1
    }

    var body: some View {
        VStack(spacing: 0) {
            // Day-of-week labels
            HStack(spacing: 0) {
                ForEach(Array(dayLetters.enumerated()), id: \.offset) { _, l in
                    Text(l)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 5)

            // Fixed-height scroll so bottom list always has room
            ScrollView {
                LazyVGrid(columns: columns, spacing: 1) {
                    ForEach(Array(daysInGrid.enumerated()), id: \.offset) { _, date in
                        if let date = date {
                            ChipDayCell(
                                date: date,
                                isSelected: selectedDate.map { date.isSameDay(as: $0) } ?? false,
                                tasks: taskManager.tasks(for: date),
                                maxTasks: maxTasksThisMonth
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedDate = selectedDate?.isSameDay(as: date) == true ? nil : date
                                }
                            }
                            .onDrop(of: ["public.text"], isTargeted: nil) { _ in
                                reschedule(to: date); return true
                            }
                        } else {
                            Color.clear.frame(height: 86)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            .frame(height: 340)
        }
    }

    private func reschedule(to date: Date) {
        guard var task = draggingTask else { return }
        taskManager.deleteTask(task)
        task.dueDate = date.startOfDay
        taskManager.addTask(task)
        draggingTask = nil
        if date.isSameDay(as: Date()) { dodoManager.feedDodo(amount: 2) }
    }
}

// MARK: - Day Cell with Chips + Heatmap

struct ChipDayCell: View {
    let date: Date
    let isSelected: Bool
    let tasks: [TodoTask]
    let maxTasks: Int

    private var isToday: Bool { Calendar.current.isDateInToday(date) }
    private var isPast:  Bool { date < Date().startOfDay }

    // Show up to 3 pills; rest become "+N more"
    private var visibleTasks: [TodoTask] { Array(tasks.prefix(3)) }
    private var overflow: Int { max(0, tasks.count - 3) }

    private var dayNumber: String {
        DateFormatter().apply { $0.dateFormat = "d" }.string(from: date)
    }

    // Heatmap: scale 0→0.28 based on this day vs busiest day this month
    private var heatOpacity: Double {
        guard maxTasks > 0, tasks.count > 0 else { return 0 }
        return Double(tasks.count) / Double(maxTasks) * 0.28
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Heatmap background
            Rectangle()
                .fill(Color.dodoOrange.opacity(heatOpacity))

            // Selection tint
            if isSelected {
                Rectangle().fill(Color.dodoOrange.opacity(0.10))
            }

            VStack(alignment: .leading, spacing: 2) {
                // Date number
                HStack {
                    ZStack {
                        if isSelected || isToday {
                            Circle()
                                .fill(Color.dodoOrange)
                                .frame(width: 22, height: 22)
                        }
                        Text(dayNumber)
                            .font(.system(size: 11,
                                         weight: isToday || isSelected ? .bold : .regular))
                            .foregroundColor(
                                isSelected || isToday ? .black :
                                (isPast ? .secondary : .primary)
                            )
                    }
                    Spacer()
                }
                .padding(.top, 3)
                .padding(.leading, 3)

                // Task pills
                ForEach(visibleTasks) { task in
                    MiniChip(task: task)
                }

                // Overflow
                if overflow > 0 {
                    Text("+\(overflow)")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.leading, 3)
                }

                Spacer(minLength: 0)
            }
        }
        .frame(height: 86)
        .clipShape(Rectangle())
        .overlay(Rectangle().stroke(Color.white.opacity(0.05), lineWidth: 0.5))
    }
}

// MARK: - Mini Chip (inside calendar cell)

struct MiniChip: View {
    let task: TodoTask

    private var chipColor: Color {
        switch task.category.color {
        case "orange": return .dodoOrange
        case "green":  return Color(red: 0.13, green: 0.60, blue: 0.33)
        case "purple": return Color(red: 0.55, green: 0.25, blue: 0.80)
        case "blue":   return Color(red: 0.20, green: 0.45, blue: 0.85)
        default:       return .gray
        }
    }

    var body: some View {
        Text(task.title)
            .font(.system(size: 9, weight: .medium))
            .foregroundColor(.white)
            .lineLimit(1)
            .truncationMode(.tail)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(chipColor.opacity(task.isCompleted ? 0.35 : 0.85))
            .cornerRadius(3)
            .padding(.horizontal, 2)
            .opacity(task.isCompleted ? 0.55 : 1.0)
    }
}

// MARK: - Day Task List (bottom panel)

struct TaskDayList: View {
    let selectedDate: Date
    @Binding var draggingTask: TodoTask?
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var dodoManager: DodoManager

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateFormat = Calendar.current.isDateInToday(selectedDate) ? "'Today'" : "EEEE, MMM d"
        return f.string(from: selectedDate)
    }

    var body: some View {
        let pending = taskManager.pendingTasks(for: selectedDate)
        let done    = taskManager.completedTasks(for: selectedDate)

        VStack(alignment: .leading, spacing: 0) {
            // Selected date label
            Text(formattedDate)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.dodoOrange)
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 6)

            if pending.isEmpty && done.isEmpty {
                EmptyDayView(date: selectedDate)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(pending) { task in
                            DraggableTaskCard(task: task, draggingTask: $draggingTask)
                                .environmentObject(taskManager)
                                .environmentObject(dodoManager)
                        }

                        if !done.isEmpty {
                            HStack {
                                Text("Completed").font(.caption).foregroundColor(.secondary)
                                Spacer()
                                Text("\(done.count)").font(.caption).foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                            .padding(.top, 4)

                            ForEach(done) { task in
                                TaskCard(task: task)
                                    .environmentObject(taskManager)
                                    .environmentObject(dodoManager)
                                    .opacity(0.5)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

// MARK: - Draggable Task Card

struct DraggableTaskCard: View {
    let task: TodoTask
    @Binding var draggingTask: TodoTask?
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var dodoManager: DodoManager

    @State private var isDragging = false
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        TaskCard(task: task)
            .environmentObject(taskManager)
            .environmentObject(dodoManager)
            .scaleEffect(isDragging ? 1.04 : 1.0)
            .shadow(color: isDragging ? Color.dodoOrange.opacity(0.4) : .clear, radius: 16)
            .offset(dragOffset)
            .zIndex(isDragging ? 10 : 0)
            .gesture(
                LongPressGesture(minimumDuration: 0.4)
                    .onEnded { _ in
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        withAnimation(.spring(response: 0.3)) {
                            isDragging = true
                            draggingTask = task
                        }
                    }
                    .sequenced(before: DragGesture())
                    .onEnded { _ in
                        withAnimation(.spring()) { isDragging = false; dragOffset = .zero }
                    }
            )
            .simultaneousGesture(
                DragGesture()
                    .onChanged { v in if isDragging { dragOffset = v.translation } }
                    .onEnded { _ in
                        withAnimation(.spring()) {
                            isDragging = false; dragOffset = .zero; draggingTask = nil
                        }
                    }
            )
            .animation(.spring(response: 0.3), value: isDragging)
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
            ZStack {
                Circle().fill(accentColor.opacity(0.2)).frame(width: 42, height: 42)
                Text(task.category.emoji).font(.system(size: 20))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                    .strikethrough(task.isCompleted)
                Text(task.category.rawValue)
                    .font(.caption).foregroundColor(.secondary)
            }

            Spacer()

            if !task.isCompleted {
                Button(action: completeTask) {
                    ZStack {
                        Circle().stroke(accentColor, lineWidth: 2).frame(width: 36, height: 36)
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
        .padding(.horizontal, 16).padding(.vertical, 14)
        .background(cardColor)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(accentColor.opacity(0.25), lineWidth: 1))
        .overlay(Group { if showConfetti { ConfettiView() } })
    }

    private func completeTask() {
        withAnimation(.spring()) {
            taskManager.completeTask(task)
            task.category == .health
                ? dodoManager.completeHealthTask(amount: task.rewardValue)
                : dodoManager.feedDodo(amount: task.rewardValue)
            showConfetti = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { showConfetti = false }
        }
    }
}

// MARK: - Empty State

struct EmptyDayView: View {
    let date: Date
    private var isFuture: Bool { date > Date().startOfDay }
    private var isToday:  Bool { Calendar.current.isDateInToday(date) }

    var body: some View {
        VStack(spacing: 12) {
            Text(isFuture ? "🗓️" : (isToday ? "✅" : "💤")).font(.system(size: 44))
            Text(isFuture ? "A clean slate for Dodo." : (isToday ? "Nothing due today." : "Nothing here."))
                .font(.headline).multilineTextAlignment(.center)
            Text(isFuture ? "Add a task to stay ahead." : (isToday ? "Tap + to add a task." : "Past days are read-only."))
                .font(.subheadline).foregroundColor(.secondary).multilineTextAlignment(.center)
        }
        .padding(32)
    }
}

// MARK: - Confetti

struct ConfettiView: View {
    var body: some View {
        ZStack {
            ForEach(0..<15, id: \.self) { _ in
                Circle().fill(Color.random).frame(width: 8, height: 8)
                    .modifier(ParticleModifier())
            }
        }
    }
}

struct ParticleModifier: ViewModifier {
    @State private var offset: CGSize = .zero
    @State private var opacity: Double = 1
    func body(content: Content) -> some View {
        content.offset(offset).opacity(opacity).onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                offset = CGSize(width: .random(in: -100...100), height: .random(in: -150...(-50)))
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

extension DateFormatter {
    @discardableResult
    func apply(_ block: (DateFormatter) -> Void) -> DateFormatter { block(self); return self }
}

#Preview {
    TaskListView()
        .environmentObject(TaskManager())
        .environmentObject(DodoManager())
        .preferredColorScheme(.dark)
}
