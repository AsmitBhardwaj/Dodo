//
//  RootView.swift
//  Dodo
//
//  Created by Asmit Bhardwaj on 17/05/26.
//

import SwiftUI

struct RootView: View {

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        let _ = print("hasCompletedOnboarding: \(hasCompletedOnboarding)")
        OnboardingView()
    }
}
