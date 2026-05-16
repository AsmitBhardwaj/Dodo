//
//  DayView.swift
//  Dodo
//

import SwiftUI

// MARK: - Day View (Tasks Tab)

struct DayView: View {
    @EnvironmentObject var timeBlockManager: TimeBlockManager
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var dodoManager: DodoManager

    @State private var selectedDate: Date = Date().startOfDay
    @State private var showingAddBlock = false
    @State private var selectedHour: Int = Calendar.current.component(.hour, from: Date())
    @State private var selectedBlock: TimeBlock? = nil

    private let hourHeight: CGFloat = 64
    private let startHour = 6
    private let endHour = 24

    var todayBlocks: [TimeBlock] {
        timeBlockManager.blocks(for: selectedDate)
            .sorted { $0.startTime < $1.startTime }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Header
                header

                // Week strip
                WeekStrip(selectedDate: $selectedDate)
                    .padding(.bottom, 8)

                Divider().background(Color.white.opacity(0.06))

                // Timeline
                ScrollViewReader { proxy in
                    ScrollView {
                        ZStack(alignment: .topLeading) {

                            // Hour grid
                            VStack(spacing: 0) {
                                ForEach(startHour..<endHour, id: \.self) { hour in
                                    HourRow(hour: hour, height: hourHeight)
                                        .id(hour)
                                        .onTapGesture {
                                            selectedHour = hour
                                            showingAddBlock = true
                                        }
                                }
                            }

                            // Time blocks
                            ForEach(todayBlocks) { block in
                                TimeBlockView(block: block)
                                    .offset(y: blockOffset(block))
                                    .frame(height: blockHeight(block))
                                    .padding(.leading, 60)
                                    .padding(.trailing, 16)
                                    .onTapGesture { selectedBlock = block }
                                    .gesture(
                                        DragGesture(minimumDistance: 50, coordinateSpace: .local)
                                            .onEnded { value in
                                                if value.translation.width < -50 {
                                                    timeBlockManager.delete(block)
                                                }
                                            }
                                    )
                            }

                            // Current time line — today only
                            if Calendar.current.isDateInToday(selectedDate) {
                                CurrentTimeIndicator(startHour: startHour, hourHeight: hourHeight)
                            }
                        }
                        .padding(.bottom, 32)
                    }
                    .onAppear {
                        let h = Calendar.current.component(.hour, from: Date())
                        proxy.scrollTo(max(startHour, h - 1), anchor: .top)
                    }
                    .onChange(of: selectedDate) { _ in
                        let h = Calendar.current.component(.hour, from: Date())
                        proxy.scrollTo(max(startHour, h - 1), anchor: .top)
                    }
                }
            }
            .background(Color.black)
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddBlock) {
                AddTimeBlockView(defaultHour: selectedHour, selectedDate: selectedDate)
                    .environmentObject(timeBlockManager)
                    .environmentObject(taskManager)
            }
            .sheet(item: $selectedBlock) { block in
                TimeBlockDetailView(block: block)
                    .environmentObject(timeBlockManager)
                    .environmentObject(dodoManager)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(selectedDate, format: .dateTime.weekday(.wide))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.dodoOrange)
                Text(selectedDate, format: .dateTime.month(.wide).day())
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            Spacer()
            Button {
                selectedHour = Calendar.current.component(.hour, from: Date())
                showingAddBlock = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.dodoOrange)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    // MARK: - Layout Helpers

    private func blockOffset(_ block: TimeBlock) -> CGFloat {
        let cal = Calendar.current
        let hour = cal.component(.hour, from: block.startTime)
        let minute = cal.component(.minute, from: block.startTime)
        let totalMinutes = Double((hour - startHour) * 60 + minute)
        return CGFloat(totalMinutes / 60) * hourHeight
    }

    private func blockHeight(_ block: TimeBlock) -> CGFloat {
        let minutes = block.endTime.timeIntervalSince(block.startTime) / 60
        return max(CGFloat(minutes / 60) * hourHeight, 32)
    }
}

// MARK: - Week Strip

struct WeekStrip: View {
    @Binding var selectedDate: Date
    private let cal = Calendar.current

    private var weekDates: [Date] {
        let today = Date().startOfDay
        let weekday = cal.component(.weekday, from: today)
        let startOfWeek = cal.date(byAdding: .day, value: -(weekday - 1), to: today)!
        return (0..<14).compactMap { cal.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(weekDates, id: \.self) { date in
                    WeekDayCell(date: date, isSelected: cal.isDate(date, inSameDayAs: selectedDate))
                        .onTapGesture { selectedDate = date }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}

struct WeekDayCell: View {
    let date: Date
    let isSelected: Bool
    private let cal = Calendar.current

    private var isToday: Bool { cal.isDateInToday(date) }
    private var dayLetter: String {
        let f = DateFormatter()
        f.dateFormat = "E"
        return String(f.string(from: date).prefix(1))
    }
    private var dayNumber: String { "\(cal.component(.day, from: date))" }

    var body: some View {
        VStack(spacing: 4) {
            Text(dayLetter)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(isSelected ? .black : Color.white.opacity(0.4))
            Text(dayNumber)
                .font(.system(size: 15, weight: isToday ? .bold : .regular, design: .rounded))
                .foregroundColor(isSelected ? .black : isToday ? .dodoOrange : .white)
        }
        .frame(width: 36, height: 52)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isSelected ? Color.dodoOrange : Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isToday && !isSelected ? Color.dodoOrange.opacity(0.4) : Color.clear, lineWidth: 1)
        )
    }
}

// MARK: - Hour Row

struct HourRow: View {
    let hour: Int
    let height: CGFloat

    private var label: String {
        let h = hour % 12 == 0 ? 12 : hour % 12
        return "\(h)\(hour < 12 ? "am" : "pm")"
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(Color.white.opacity(0.25))
                .frame(width: 44, alignment: .trailing)
                .padding(.trailing, 8)
                .offset(y: -8)
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 0.5)
                .frame(maxWidth: .infinity)
        }
        .frame(height: height)
        .contentShape(Rectangle())
    }
}

// MARK: - Time Block View

struct TimeBlockView: View {
    let block: TimeBlock

    private var color: Color {
        switch block.category {
        case .ship:    return Color(red: 0.976, green: 0.451, blue: 0.086)
        case .sharpen: return Color(red: 0.4, green: 0.6, blue: 1.0)
        case .train:   return Color(red: 0.2, green: 0.78, blue: 0.35)
        case .clear:   return Color(red: 0.7, green: 0.4, blue: 0.9)
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 3)

            VStack(alignment: .leading, spacing: 2) {
                Text(block.title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(block.isCompleted ? Color.white.opacity(0.4) : .white)
                    .strikethrough(block.isCompleted)
                    .lineLimit(1)

                Text("\(block.startTime, format: .dateTime.hour().minute()) – \(block.endTime, format: .dateTime.hour().minute())")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.4))
            }
            .padding(.vertical, 6)
            .padding(.trailing, 8)

            Spacer()

            Text(block.category.emoji)
                .font(.system(size: 14))
                .padding(.top, 6)
                .padding(.trailing, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(block.isCompleted ? 0.06 : 0.14))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(0.3), lineWidth: 0.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Current Time Indicator

struct CurrentTimeIndicator: View {
    let startHour: Int
    let hourHeight: CGFloat

    private var offset: CGFloat {
        let cal = Calendar.current
        let now = Date()
        let hour = cal.component(.hour, from: now)
        let minute = cal.component(.minute, from: now)
        let total = Double((hour - startHour) * 60 + minute)
        return CGFloat(total / 60) * hourHeight
    }

    var body: some View {
        HStack(spacing: 0) {
            Circle()
                .fill(Color.dodoOrange)
                .frame(width: 8, height: 8)
                .padding(.leading, 40)
            Rectangle()
                .fill(Color.dodoOrange)
                .frame(height: 1)
        }
        .offset(y: offset)
    }
}

// MARK: - Add Time Block View

struct AddTimeBlockView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var timeBlockManager: TimeBlockManager
    @EnvironmentObject var taskManager: TaskManager

    let defaultHour: Int
    let selectedDate: Date

    @State private var title = ""
    @State private var selectedCategory: TodoTask.TaskCategory = .ship
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var linkedTask: TodoTask? = nil

    init(defaultHour: Int, selectedDate: Date) {
        self.defaultHour = defaultHour
        self.selectedDate = selectedDate
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
        comps.hour = defaultHour
        comps.minute = 0
        let start = Calendar.current.date(from: comps) ?? Date()
        _startTime = State(initialValue: start)
        _endTime = State(initialValue: start.addingTimeInterval(3600))
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Block Details") {
                    TextField("What are you working on?", text: $title)

                    Picker("Category", selection: $selectedCategory) {
                        ForEach(TodoTask.TaskCategory.allCases, id: \.self) { cat in
                            HStack {
                                Text(cat.emoji)
                                Text(cat.rawValue)
                            }.tag(cat)
                        }
                    }

                    DatePicker("Start", selection: $startTime, displayedComponents: [.hourAndMinute])
                        .tint(.dodoOrange)

                    DatePicker("End", selection: $endTime, displayedComponents: [.hourAndMinute])
                        .tint(.dodoOrange)
                }

                if !taskManager.tasks.filter({ !$0.isCompleted }).isEmpty {
                    Section("Link a task (optional)") {
                        ForEach(taskManager.tasks.filter { !$0.isCompleted }) { task in
                            HStack {
                                Text(task.category.emoji)
                                Text(task.title)
                                    .font(.system(size: 14))
                                Spacer()
                                if linkedTask?.id == task.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.dodoOrange)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if linkedTask?.id == task.id {
                                    linkedTask = nil
                                    title = ""
                                    selectedCategory = .ship
                                } else {
                                    linkedTask = task
                                    title = task.title
                                    selectedCategory = task.category
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Block")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") { addBlock() }
                        .disabled(title.isEmpty || endTime <= startTime)
                        .tint(.dodoOrange)
                }
            }
        }
    }

    private func addBlock() {
        var block = TimeBlock(
            title: title,
            category: selectedCategory,
            startTime: startTime,
            endTime: endTime
        )
        block.linkedTaskId = linkedTask?.id
        timeBlockManager.add(block)
        dismiss()
    }
}

// MARK: - Time Block Detail View

struct TimeBlockDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var timeBlockManager: TimeBlockManager
    @EnvironmentObject var dodoManager: DodoManager

    let block: TimeBlock

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(block.category.emoji + " " + block.category.rawValue)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.dodoOrange)
                    Text(block.title)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("\(block.startTime, format: .dateTime.hour().minute()) – \(block.endTime, format: .dateTime.hour().minute())")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.4))
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                Divider().background(Color.white.opacity(0.08))

                VStack(spacing: 12) {
                    if !block.isCompleted {
                        Button {
                            timeBlockManager.complete(block)
                            dodoManager.taskCompleted(amount: Int(Double(block.durationMinutes) / 60 * 10))
                            dismiss()
                        } label: {
                            Label("Mark as done", systemImage: "checkmark.circle.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.dodoOrange)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    Button {
                        timeBlockManager.delete(block)
                        dismiss()
                    } label: {
                        Label("Delete block", systemImage: "trash")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }
            .background(Color.black)
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    DayView()
        .environmentObject(TimeBlockManager())
        .environmentObject(TaskManager())
        .environmentObject(DodoManager())
        .preferredColorScheme(.dark)
}
