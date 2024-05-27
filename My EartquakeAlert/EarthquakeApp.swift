//
//  EarthquakeApp.swift
//  My EartquakeAlert
//
//  Created by Амангелди Мадина on 08.05.2024.
//

//import Foundation
//import SwiftUI
//@main
//struct EarthquakeApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//        .onAppear {
//            // Register for push notifications
//            UIApplication.shared.registerForRemoteNotifications()
//        }
//    }
//}
//
//// Implement push notification handling
//extension AppDelegate: UNUserNotificationCenterDelegate {
//    // Handle incoming push notifications when app is in foreground
//    func userNotificationCenter(
//        _ center: UNUserNotificationCenter,
//        willPresent notification: UNNotification,
//        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
//    ) {
//        // Handle notification presentation
//        completionHandler([.banner, .sound, .badge])
//    }
//
//    // Handle tap on push notification
//    func userNotificationCenter(
//        _ center: UNUserNotificationCenter,
//        didReceive response: UNNotificationResponse,
//        withCompletionHandler completionHandler: @escaping () -> Void
//    ) {
//        // Handle notification tap
//        completionHandler()
//    }
//}
