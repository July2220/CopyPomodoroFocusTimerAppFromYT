//
//  HomeView-ViewModel.swift
//  CopyPomodoroFocusTimerAppFromYT
//
//  Created by july on 2023/4/25.
//

import Foundation
import SwiftUI
import UserNotifications

class ViewModel:NSObject,ObservableObject,UNUserNotificationCenterDelegate {
    //MARK: Timer properties
    @Published var progress:CGFloat = 1
    @Published var timeStringValue: String = "00:00"
    @Published var isStarted: Bool = false
    @Published var addNewTimer: Bool = false
    
    @Published var hour:Int = 0
    @Published var minute: Int = 0
    @Published var seconds: Int = 0
    
    @Published var totalSeconds:Int = 0
    @Published var staticTotalSeconds: Int = 0
    @Published var isFinished = false
    
    override init() {
        super.init()
        self.authorizeNotification()
    }
    
    // MARK: - ask for permission
    func  authorizeNotification() {
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { setting in
            if setting.authorizationStatus != .authorized {
                center.requestAuthorization(options:[.sound,.alert,.badge]) { success, error in
                    

                    if let error = error {
                        print("Error requesting notification permission: \(error)")
                    }
                }
            }
        }
        
        // MARK: - to show in app notification
        center.delegate = self
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound,.banner])
    }

    
    //MARK: - starting timer
    func startTimer() {
        withAnimation(.easeInOut(duration: 0.25)){isStarted = true}
        timeStringValue = "\(hour==0 ? "" : "\(hour)"):\(minute>=10 ? "\(minute)":"0\(minute)"):\(seconds>=10 ? "\(seconds)":"0\(seconds)")"
        totalSeconds = (hour*3600) + (minute*60) + (seconds)
        staticTotalSeconds = totalSeconds
        addNewTimer = false
        addNotification()
    }
    
    // MARK: - stopping timer
    func stopTimer() {
        withAnimation(.easeInOut(duration: 0.25)){
            isStarted = false
            hour = 0
            minute = 0
            seconds = 0
            progress = 1
        }
        totalSeconds = 0
        staticTotalSeconds = 0
        timeStringValue = "00:00"
    }
    
    // MARK: - update timer
    func updateTimer() {
        totalSeconds -= 1
        progress = CGFloat(totalSeconds)/CGFloat(staticTotalSeconds)
        progress = ( progress < 0 ? 0 : progress)
        hour = totalSeconds / 3600
        minute = (totalSeconds/60) % 60
        seconds = totalSeconds % 60
        timeStringValue = "\(hour==0 ? "" : "\(hour)"):\(minute>=10 ? "\(minute)":"0\(minute)"):\(seconds>=10 ? "\(seconds)":"0\(seconds)")"
        if hour == 0 && minute == 0 && seconds == 0 {
            isStarted  = false
            print("finished")
            isFinished = true
        }
    }
    
    func addNotification() {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Pomodoro Timer"
        content.subtitle = "Congratulations you did it hooray❤️"
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(staticTotalSeconds), repeats: false))
        
        center.add(request)
    }
}
