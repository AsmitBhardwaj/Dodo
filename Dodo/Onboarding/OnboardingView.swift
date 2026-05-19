import SwiftUI

struct OnboardingView: View {

    @State private var state = OnboardingState()
    @State private var currentScreen = 0
    @EnvironmentObject var taskManager: TaskManager
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    let totalScreens = 19

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()

            // Progress bar
            GeometryReader { geo in
                Rectangle()
                    .fill(Color.dodoOrange)
                    .frame(width: geo.size.width * progressFraction, height: 3)
                    .animation(.easeInOut(duration: 0.4), value: currentScreen)
            }
            .frame(height: 3)
            .zIndex(1)

            // Current screen
            Group {
                switch currentScreen {
                case 0:  SplashScreen(onNext: advance)
                case 1:  NameScreen(state: state, onNext: advance)
                case 2:  WakeTimeScreen(state: state, onNext: advance)
                case 3:  PrimaryGoalScreen(state: state, onNext: advance)
                case 4...10:
                    QuizScreen(
                        state: state,
                        questionIndex: currentScreen - 4,
                        onNext: advance
                    )
                case 11: TypeRevealScreen(state: state, onNext: advance)
                case 12: ProgramScreen(state: state, onNext: advance)
                case 13: CategoryScreen(category: TodoTask.TaskCategory.allCases[0], isLast: false, onNext: advance)
                case 14: CategoryScreen(category: TodoTask.TaskCategory.allCases[1], isLast: false, onNext: advance)
                case 15: CategoryScreen(category: TodoTask.TaskCategory.allCases[2], isLast: false, onNext: advance)
                case 16: CategoryScreen(category: TodoTask.TaskCategory.allCases[3], isLast: true, onNext: advance)
                case 18: GemUnlockScreen(state: state, onFinish: finish)
                default: SplashScreen(onNext: advance)
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
            ))
            .animation(.easeInOut(duration: 0.35), value: currentScreen)
        }
    }

    // MARK: - Helpers

    private var progressFraction: Double {
        guard totalScreens > 1 else { return 0 }
        return Double(currentScreen) / Double(totalScreens - 1)
    }

    private func advance() {
        guard currentScreen < totalScreens - 1 else { return }
        withAnimation {
            currentScreen += 1
        }
    }

    private func finish() {
        UserDefaults.standard.set(state.name, forKey: "userName")
        UserDefaults.standard.set(state.wakeTime, forKey: "wakeTime")
        UserDefaults.standard.set(state.computedType.rawValue, forKey: "userType")

        if let encoded = try? JSONEncoder().encode(state.computedScores) {
            UserDefaults.standard.set(encoded, forKey: "radarScores")
        }

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

        hasCompletedOnboarding = true
    }
}
