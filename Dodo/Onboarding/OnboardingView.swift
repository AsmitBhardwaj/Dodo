//
//  OnboardingView.swift
//  Dodo
//
//  Created by Asmit Bhardwaj on 17/05/26.
//


import SwiftUI

struct OnboardingView: View {

    @State private var state = OnboardingState()
    @State private var currentScreen = 0
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var dodoManager: DodoManager

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    let totalScreens = 19

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()

            // Progress bar
            GeometryReader { geo in
                Rectangle()
                    .fill(Color.dodoOrange)
                    .frame(
                        width: geo.size.width * progressFraction,
                        height: 3
                    )
                    .animation(.easeInOut(duration: 0.4), value: currentScreen)
            }
            .frame(height: 3)
            .zIndex(1)

            // Screens
            TabView(selection: $currentScreen) {
                // 1 - Splash
                SplashScreen(onNext: advance)
                    .tag(0)

                // 2 - Name
                NameScreen(state: state, onNext: advance)
                    .tag(1)

                // 3 - Wake time
                WakeTimeScreen(state: state, onNext: advance)
                    .tag(2)

                // 4 - Primary goal
                PrimaryGoalScreen(state: state, onNext: advance)
                    .tag(3)

                // 5-11 - Quiz questions
                ForEach(0..<7, id: \.self) { index in
                    QuizScreen(
                        state: state,
                        questionIndex: index,
                        onNext: advance
                    )
                    .tag(4 + index)
                }

                // 12 - Type reveal
                TypeRevealScreen(state: state, onNext: advance)
                    .tag(11)

                // 13 - Your program
                ProgramScreen(state: state, onNext: advance)
                    .tag(12)

                // 14-17 - Category cards
                ForEach(0..<TodoTask.TaskCategory.allCases.count, id: \.self) { index in
                    CategoryScreen(
                        category: TodoTask.TaskCategory.allCases[index],
                        isLast: index == TodoTask.TaskCategory.allCases.count - 1,
                        onNext: advance
                    )
                    .tag(13 + index)
                }

                // 18 - First task
                FirstTaskScreen(state: state, onNext: advance)
                    .tag(17)

                // 19 - Gem unlock
                GemUnlockScreen(state: state, onFinish: finish)
                    .tag(18)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.45), value: currentScreen)
            .ignoresSafeArea()
        }
    }

    // MARK: - Helpers

    private var progressFraction: Double {
        guard totalScreens > 1 else {
            return 0
        }
        return Double(currentScreen) / Double(totalScreens - 1)
    }

    private func advance() {
        guard currentScreen < totalScreens - 1 else {
            return
        }
        withAnimation {
            currentScreen += 1
        }
    }

    private func finish() {
        // Save user name and wake time
        UserDefaults.standard.set(state.name, forKey: "userName")
        UserDefaults.standard.set(state.wakeTime, forKey: "wakeTime")

        // Save type and scores
        UserDefaults.standard.set(state.computedType.rawValue, forKey: "userType")
        if let encoded = try? JSONEncoder().encode(state.computedScores) {
            UserDefaults.standard.set(encoded, forKey: "radarScores")
        }

        // Add first task
        if let category = state.firstTaskCategory {
            let task = TodoTask(
                title: state.firstTaskTitle,
                category: category,
                rewardValue: 10,
                dueDate: Date().startOfDay,
                duration: state.firstTaskDuration
            )
            taskManager.addTask(task)
        }

        // Mark onboarding complete — RootView will switch to main app
        hasCompletedOnboarding = true
    }
}