import UserNotifications

/// Schedules the gentle "time's up" nudge after a timeboxed session in a gated app.
enum SessionNudge {
    static func schedule(minutes: Int, appName: String) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = "Your \(minutes) minutes are up"
            content.body = "That's the time you gave \(appName). Come back to what matters?"
            content.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: TimeInterval(minutes * 60),
                repeats: false
            )
            center.add(UNNotificationRequest(
                identifier: "session-\(UUID().uuidString)",
                content: content,
                trigger: trigger
            ))
        }
    }
}
