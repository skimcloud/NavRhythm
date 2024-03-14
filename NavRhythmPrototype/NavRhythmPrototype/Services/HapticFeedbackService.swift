//
//  HapticsManager.swift
//  NavRhythmPrototype
//
//  Created by jen galicia on 3/9/24.
//

import UIKit
import Foundation

final class HapticFeedbackService: ObservableObject {
    static let shared = HapticFeedbackService()

    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)

    init() {
        impactFeedback.prepare()
    }

    func sendManeuverFeedback(maneuverType: String, distance: Double) {
        // Determine the frequency of vibrations based on the distance
        // Closer to 0 means more urgent, hence quicker bursts
        let urgency = max(min(1.0, distance / 100.0), 0.1) // Normalize and clamp between 0.1 and 1.0

        if maneuverType.lowercased().contains("left") {
            performLeftTurnFeedback(urgency: urgency)
        } else if maneuverType.lowercased().contains("right") {
            performRightTurnFeedback(urgency: urgency)
        } else {
            impactFeedback.impactOccurred(intensity: 0.5) // Generic feedback for other maneuvers
        }
    }


    private func performLeftTurnFeedback(urgency: Double) {
        // Three short vibrations
        let interval = urgency * 0.2 // Adjust the interval based on urgency
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i)) {
                self.impactFeedback.impactOccurred(intensity: 0.5)
            }
        }
    }

    private func performRightTurnFeedback(urgency: Double) {
        // Two long vibrations
        let interval = urgency * 0.3 // Adjust the interval based on urgency
        for i in 0..<2 {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i)) {
                self.impactFeedback.impactOccurred(intensity: 0.75) // Simulate longer by higher intensity
            }
        }
    }
}

func sendVibrationForManeuver(maneuverType: String, distance: Double) {
    HapticFeedbackService.shared.sendManeuverFeedback(maneuverType: maneuverType, distance: distance)
}

