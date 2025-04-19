//
//  RotatorComponent.swift
//  RealityKit Experiments
//
//  Created by Oleg Frolov on 19/04/2025.
//


import RealityKit

struct RotatorComponent: Component {
    let speed: Float
    let axis: RotatorAxis
    
    init(speed: Float = 0.1, axis: RotatorAxis = .y) {
        self.speed = speed
        self.axis = axis
    }
}
