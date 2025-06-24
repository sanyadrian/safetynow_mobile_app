//
//  SafetyNowAppApp.swift
//  SafetyNowApp
//
//  Created by Oleksandr Adrianov on 5/6/25.
//

import SwiftUI

@main
struct SafetyNowAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                MainView()
            } else {
                OnboardingView()
            }
        }
    }
}
