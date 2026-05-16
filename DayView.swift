//
//  DayView.swift
//  Dodo
//
//  Created by Asmit Bhardwaj on 16/05/26.
//


//
//  DayView.swift
//  Dodo
//

import SwiftUI

// MARK: - Day View

struct DayView: View {
    @EnvironmentObject var timeBlockManager: TimeBlockManager
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var dodoManager: DodoManager

    @State private var showingAddBlock = false
    @State private var selectedHour: Int = Calendar.current.component(.hour, from: Date())
    @State private var selectedBlock: TimeBlock? = nil

    private let hourHeight: CGFloat = 64
    private let startHour = 6
    private let endHour = 24

    var todayBlocks: [TimeBlock] {
        timeBlockManager.blocks(for: Date())
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Header
                dayHeader

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
                                    .onTapGesture {
                                        selectedBlock = block
                                    }
                            }

                            // Current time indicator
                            CurrentTimeIndicator(startHour: startHour, hourHeight: hourHeight)
                        }
                        .padding(.bottom, 32)
                    }
                    .onAppear {
                        let currentHour = Calendar.current.component(.hour, from: Date())
                        proxy.scrollTo(max(startHour, currentHour - 1), anchor: .top)
                    }
                }
            }
            .background(Color.black)
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddBlock) {
                AddTimeBlockView(defaultHour: selectedHour)
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

    private var dayHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(Date(), format: .dateTime.weekday(.wide))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.dodoOrange)
                Text(Date(), format: .dateTime.month(.wide).day())
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
        return max(CGFloat(minutes / 60) * hourHeight, 28)
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

    @State private var title = ""
    @State private var selectedCategory: TodoTask.TaskCategory = .ship
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var linkingTask = false
    @State private var linkedTask: TodoTask? = nil

    init(defaultHour: Int) {
        self.defaultHour = defaultHour
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
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