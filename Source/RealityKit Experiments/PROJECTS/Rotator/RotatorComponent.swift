//
//  RotatorComponent.swift
//  RealityKit Experiments
//
//  Created by Oleg Frolov on 19/04/2025.
//


import RealityKit

struct RotatorComponent: Component {
    let speed: Float
    let axis: RotatorAxis = .y
    
    init(speed: Float = 0.1, axis: RotatorAxis = .y) {
        self.speed = speed
    }
}
