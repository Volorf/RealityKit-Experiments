//
//  StepData.swift
//  RealityKit Experiments
//
//  Created by Oleg Frolov on 22/04/2025.
//

import SwiftUI

struct StepData: Identifiable {
    let id: UUID = UUID()
    let color: Color
    let position: SIMD3<Int>
    let multiplier: Float
    
    func getPosition() -> SIMD3<Float> {
        var p: SIMD3<Float> = .zero
        p.x = Float(position.x) * multiplier
        p.y = Float(position.y) * multiplier
        p.z = Float(position.z) * multiplier
        return p
    }
}
