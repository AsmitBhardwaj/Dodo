//
//  TaskListView.swift
//  Dodo - Life Gamification
//

import SwiftUI

struct TaskListView: View {
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var dodoManager: DodoManager
    
    var incompleteTasks: [TodoTask] {
        taskManager.tasks.filter { !$0.isCompleted }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Today's Tasks")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 8)
            
            if incompleteTasks.isEmpty {
                VStack(spacing: 16) {
                    Text("🎉")
                        .font(.system(size: 60))
                    Text("No tasks left!")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    Text("Add some tasks to keep Dodo happy")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                List {
                    ForEach(incompleteTasks) { task in
                        TaskRowView(task: task)
                            .environmentObject(taskManager)
                            .environmentObject(dodoManager)
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}

struct TaskRowView: View {
    let task: TodoTask
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var dodoManager: DodoManager
    @State private var showingConfetti = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion Button
            Button(action: {
                completeTask()
            }) {
                ZStack {
                    Circle()
                        .stroke(categoryColor, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .foregroundColor(categoryColor)
                            .font(.system(size: 14, weight: .bold))
                    }
                }
            }
            .buttonStyle(.plain)
            
            // Task Info
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body)
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                
                HStack(spacing: 8) {
                    Text(task.category.emoji)
                    Text(task.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("+\(task.rewardValue)")
                        .font(.caption)
                        .foregroundColor(categoryColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(categoryColor.opacity(0.1))
                        .cornerRadius(4)
                }
            }
        }
        .padding(.vertical, 4)
        .overlay(
            Group {
                if showingConfetti {
                    ConfettiView()
                }
            }
        )
    }
    
    private var categoryColor: Color {
        switch task.category.color {
        case "blue": return .blue
        case "green": return .green
        case "purple": return .purple
        case "orange": return .orange
        default: return .gray
        }
    }
    
    private func completeTask() {
        withAnimation(.spring()) {
            taskManager.completeTask(task)
            
            // Feed Dodo based on task category
            if task.category == .health {
                dodoManager.completeHealthTask(amount: task.rewardValue)
            } else {
                dodoManager.feedDodo(amount: task.rewardValue)
            }
            
            // Show celebration
            showingConfetti = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showingConfetti = false
            }
        }
    }
}

struct ConfettiView: View {
    var body: some View {
        ZStack {
            ForEach(0..<15) { _ in
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
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}

#Preview {
    TaskListView()
        .environmentObject(TaskManager())
        .environmentObject(DodoManager())
        .preferredColorScheme(.dark)
}
