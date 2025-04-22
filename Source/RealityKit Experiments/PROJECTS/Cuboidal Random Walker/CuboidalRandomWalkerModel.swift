//
//  CuboidalRandomWalkerModel.swift
//  RealityKit Experiments
//
//  Created by Oleg Frolov on 22/04/2025.
//

import SwiftUI
import RealityKit

@MainActor @Observable
class CuboidalRandomWalkerModel {
    
    let sideSize: Float = 0.01
    let limitBox: SIMD3<Int> = SIMD3<Int>(20, 20, 20)
    var steps: [StepData] = []
    var currentPosition: SIMD3<Int> = SIMD3<Int>(0, 0, 0)
    
    var colors: [Color] = []
    var currentColorIndex: Int = 0
    var oldSteps: Set<SIMD3<Int>> = []
    let numberOfIterations: Int = 600
    var modelEntities: [ModelEntity] = []
    
    func generateColors(num: Int) -> [Color] {
        var colors: [Color] = []
        for i in 0...num {
            let v = Double(i) / Double(num)
            let c = Color(hue: v, saturation: 0.8, brightness: 1)
            colors.append(c)
        }
        return colors
    }
    
    init() {
        colors = generateColors(num: numberOfIterations)
        
        for _ in 0...numberOfIterations {
            
            currentPosition = getNextPosition(curPos: currentPosition)
            if oldSteps.contains(currentPosition) {
                break
            }
               
            oldSteps.insert(currentPosition)
            
            let newStep = StepData(color: getNextColor(), position: currentPosition, multiplier: sideSize)
            
            steps.append(newStep)
            
            let model = ModelEntity(
                mesh: .generateBox(size: sideSize, cornerRadius: sideSize / 12),
                materials: [SimpleMaterial(color: UIColor(newStep.color), isMetallic: false)])
                
            model.position = SIMD3<Float>(x: newStep.getPosition().x, y: newStep.getPosition().y, z: newStep.getPosition().z)
            model.scale = SIMD3<Float>(x: 0.0, y: 0.0, z: 0.0)
            modelEntities.append(model)
        }
    }
    
    func getNextColor() -> Color {
        let index: Int = currentColorIndex % colors.count
        currentColorIndex += 1
        return colors[index]
    }
    
    func getNextPosition(curPos: SIMD3<Int>) -> SIMD3<Int> {
        let newPos: [SIMD3<Int>] = getNextStepPositions(curPos: currentPosition)
        
        for pos in newPos {
            if (!oldSteps.contains(pos) &&
                pos.x <= limitBox.x &&
                pos.x >= -limitBox.x &&
                pos.y <= limitBox.y &&
                pos.y >= -limitBox.y &&
                pos.z <= limitBox.z &&
                pos.z >= -limitBox.z) {
                return pos;
            }
        }
        return curPos
    }
    
    func getNextStepPositions(curPos: SIMD3<Int>) -> [SIMD3<Int>] {
        let nextUp: SIMD3<Int> = curPos &+ SIMD3<Int>(0, 1, 0)
        let nextDown: SIMD3<Int> = curPos &+ SIMD3<Int>(0, -1, 0)
        let nextLeft: SIMD3<Int> = curPos &+ SIMD3<Int>(-1, 0, 0)
        let nextRight: SIMD3<Int> = curPos &+ SIMD3<Int>(1, 0, 0)
        let nextBack: SIMD3<Int> = curPos &+ SIMD3<Int>(0, 0, -1)
        let nextFront: SIMD3<Int> = curPos &+ SIMD3<Int>(0, 0, 1)
        
        let options: [SIMD3<Int>] = [nextUp, nextDown, nextLeft, nextRight, nextBack, nextFront]
        
        return options.shuffled()
    }
}
