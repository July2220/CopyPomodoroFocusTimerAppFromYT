//
//  CopyPomodoroFocusTimerAppFromYTApp.swift
//  CopyPomodoroFocusTimerAppFromYT
//
//  Created by july on 2023/4/25.
//

import SwiftUI

@main
struct CopyPomodoroFocusTimerAppFromYTApp: App {
    //MARK: since we are doing background fetching initializing here
    @StateObject var viewModel: ViewModel = .init()
    // MARK: - scene phase
    @Environment(\.scenePhase) var phase
    // MARK: - storing last time stamp
    @State var lastActiveTimeStamp: Date = Date()


    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
        .onChange(of: phase) { newValue in
            if viewModel.isStarted {
                if newValue == .background {
                    lastActiveTimeStamp = Date()
                    
                }
                if newValue  == .active {
                    let currentTimeStampDiff = Date().timeIntervalSince(lastActiveTimeStamp)
                    if viewModel.totalSeconds - Int(currentTimeStampDiff) <= 0 {
                        viewModel.isStarted = false
                        viewModel.totalSeconds = 0
                        viewModel.isFinished = true
                    }
                }
            }
        }
    }
}
