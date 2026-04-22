//
//  CalendarView.swift
//  Dodo - Life Gamification
//
//  Month calendar with swipe-based month navigation (no arrow buttons).
//  Uses a TabView pager so the user swipes left/right to move between months.
//

import SwiftUI

// MARK: - Root Calendar Tab

struct CalendarView: View {
    @EnvironmentObject var taskManager: TaskManager

    /// Central "page" index. 0 = today's month. Negative = past, positive = future.
    /// We keep a wide window so the user can swipe far in either direction.
    private let pageRange = -24...24          // 4 years back / forward
    private let anchorIndex = 24             // offset that maps to index 0

    @State private var currentPage: Int = 24  // starts at today's month
    @State private var selectedDate: Date = Date().startOfDay

    private var displayedMonth: Date {
        monthOffset(currentPage - anchorIndex)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Month / year header — updates as pages change
                monthHeader

                // Weekday labels
                weekdayRow

                Divider()
                    .background(Color.white.opacity(0.06))

                // Swipeable month pages
                TabView(selection: $currentPage) {
                    ForEach(pageRange, id: \.self) { page in
                        CalendarMonthGrid(
                            month: monthOffset(page - anchorIndex),
                            selectedDate: $selectedDate
                        )
                        .environmentObject(taskManager)
                        .tag(page)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)

                Divider()
                    .background(Color.white.opacity(0.06))

                // Tasks for selected date
                SelectedDayTaskList(date: selectedDate)
                    .environmentObject(taskManager)
            }
            .background(Color.black)
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }

    // MARK: - Header

    private var monthHeader: some View {
        HStack {
            Text(displayedMonth, format: .dateTime.month(.wide).year())
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.25), value: currentPage)

            Spacer()

            // "Today" jump button
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentPage = anchorIndex
                    selectedDate = Date().startOfDay
                }
            } label: {
                Text("Today")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color.dodoOrange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.dodoOrange.opacity(0.15))
                    .clipShape(Capsule())
            }
            .opacity(currentPage == anchorIndex ? 0 : 1)
            .animation(.easeInOut(duration: 0.2), value: currentPage)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    // MARK: - Weekday Row

    private var weekdayRow: some View {
        HStack(spacing: 0) {
            ForEach(["S","M","T","W","T","F","S"], id: \.self) { day in
                Text(day)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.35))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 6)
    }

    // MARK: - Helper

    private func monthOffset(_ offset: Int) -> Date {
        Calendar.current.date(
            byAdding: .month, value: offset,
            to: Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))!
        )!
    }
}

// MARK: - Month Grid

struct CalendarMonthGrid: View {
    let month: Date
    @Binding var selectedDate: Date
    @EnvironmentObject var taskManager: TaskManager

    private let cal = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    /// All day cells (including leading/trailing padding days shown as blank)
    private var daySlots: [Date?] {
        guard let range = cal.range(of: .day, in: .month, for: month),
              let firstDay = cal.date(from: cal.dateComponents([.year, .month], from: month))
        else { return [] }

        let weekdayOffset = cal.component(.weekday, from: firstDay) - 1  // Sun=1 → offset=0
        let blanks: [Date?] = Array(repeating: nil, count: weekdayOffset)
        let days: [Date?] = range.map { day -> Date? in
            cal.date(byAdding: .day, value: day - 1, to: firstDay)
        }
        // Pad end to complete the last row
        let total = blanks.count + days.count
        let trailing = total % 7 == 0 ? 0 : 7 - (total % 7)
        return blanks + days + Array(repeating: nil, count: trailing)
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(Array(daySlots.enumerated()), id: \.offset) { _, date in
                if let date {
                    DayCell(date: date, selectedDate: $selectedDate)
                        .environmentObject(taskManager)
                } else {
                    Color.clear
                        .frame(height: 56)
                }
            }
        }
        .padding(.horizontal, 8)
    }
}

// MARK: - Day Cell

struct DayCell: View {
    let date: Date
    @Binding var selectedDate: Date
    @EnvironmentObject var taskManager: TaskManager

    private let cal = Calendar.current

    private var isToday: Bool       { cal.isDateInToday(date) }
    private var isSelected: Bool    { cal.isDate(date, inSameDayAs: selectedDate) }
    private var isCurrentMonth: Bool { true }  // grid only shows current month days

    private var tasks: [TodoTask] {
        taskManager.tasks.filter { cal.isDate($0.dueDate, inSameDayAs: date) }
    }
    private var completedCount: Int { tasks.filter(\.isCompleted).count }
    private var totalCount: Int     { tasks.count }
    private var progress: Double    { totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0 }

    var body: some View {
        Button(action: { selectedDate = date.startOfDay }) {
            VStack(spacing: 3) {
                ZStack {
                    // Selection ring
                    if isSelected && !isToday {
                        Circle()
                            .stroke(Color.dodoOrange, lineWidth: 1.5)
                            .frame(width: 32, height: 32)
                    }

                    // Today fill
                    if isToday {
                        Circle()
                            .fill(Color.dodoOrange)
                            .frame(width: 32, height: 32)
                    }

                    // Progress ring (behind number, only if tasks exist)
                    if totalCount > 0 && !isToday {
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(Color.dodoOrange.opacity(0.75),
                                    style: StrokeStyle(lineWidth: 2, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .frame(width: 34, height: 34)

                        Circle()
                            .stroke(Color.white.opacity(0.08), lineWidth: 2)
                            .frame(width: 34, height: 34)
                    }

                    Text("\(cal.component(.day, from: date))")
                        .font(.system(size: 15, weight: isToday ? .bold : .regular, design: .rounded))
                        .foregroundColor(isToday ? .black : .white)
                }

                // Task event pills (max 3 shown)
                if totalCount > 0 {
                    HStack(spacing: 2) {
                        ForEach(Array(tasks.prefix(3).enumerated()), id: \.offset) { index, task in
                            RoundedRectangle(cornerRadius: 1)
                                .fill(task.isCompleted
                                      ? Color.white.opacity(0.25)
                                      : categoryColor(task.category))
                                .frame(width: 5, height: 3)
                        }
                        if tasks.count > 3 {
                            Text("+\(tasks.count - 3)")
                                .font(.system(size: 7, weight: .bold))
                                .foregroundColor(Color.white.opacity(0.4))
                        }
                    }
                    .frame(height: 6)
                } else {
                    Color.clear.frame(height: 6)
                }
            }
            .frame(height: 56)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func categoryColor(_ category: TodoTask.TaskCategory) -> Color {
        switch category {
        case .school:   return Color(red: 0.976, green: 0.451, blue: 0.086)
        case .health:   return Color(red: 0.2, green: 0.78, blue: 0.35)
        case .personal: return Color(red: 0.4, green: 0.6, blue: 1.0)
        case .social:   return Color(red: 0.9, green: 0.4, blue: 0.7)
        }
    }
}

// MARK: - Selected Day Task List

struct SelectedDayTaskList: View {
    let date: Date
    @EnvironmentObject var taskManager: TaskManager

    private let cal = Calendar.current

    private var tasks: [TodoTask] {
        taskManager.tasks.filter { cal.isDate($0.dueDate, inSameDayAs: date) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header
            HStack {
                Text(date, format: .dateTime.weekday(.wide).month().day())
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.5))
                    .textCase(.uppercase)
                    .tracking(0.8)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.2), value: date)

                Spacer()

                if !tasks.isEmpty {
                    Text("\(tasks.filter(\.isCompleted).count)/\(tasks.count) done")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Color.dodoOrange.opacity(0.8))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            if tasks.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 6) {
                        Text("🗓️")
                            .font(.system(size: 28))
                        Text("No tasks this day")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.3))
                    }
                    .padding(.vertical, 20)
                    Spacer()
                }
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(tasks) { task in
                            CalendarTaskRow(task: task)
                                .environmentObject(taskManager)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
        }
        .frame(maxHeight: 220)
        .background(Color.white.opacity(0.03))
    }
}

// MARK: - Compact Task Row

struct CalendarTaskRow: View {
    let task: TodoTask
    @EnvironmentObject var taskManager: TaskManager

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(task.isCompleted ? Color.white.opacity(0.15) : Color.dodoOrange.opacity(0.8))
                .frame(width: 8, height: 8)

            Text(task.title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(task.isCompleted ? Color.white.opacity(0.35) : .white)
                .strikethrough(task.isCompleted, color: Color.white.opacity(0.3))
                .lineLimit(1)

            Spacer()

            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 18))
                .foregroundColor(task.isCompleted ? Color.dodoOrange : Color.white.opacity(0.25))
                .onTapGesture {
                    if !task.isCompleted {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            taskManager.completeTask(task)
                        }
                    }
                }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    CalendarView()
        .environmentObject(TaskManager())
        .preferredColorScheme(.dark)
}
