//  Created by Oleg Frolov on 29/01/2026.

import SwiftUI
import RealityKit
import simd

struct ArrowsAttractor: View {
    @State private var root: Entity = .init()
    @State private var arrows: [Entity] = []
    @State private var attractionPoint: ModelEntity = ModelEntity()
    @State private var wasPressed: Bool = false
    @State private var dragStartPosition: SIMD3<Float> = .zero

    let blackMat = SimpleMaterial(color: .black, isMetallic: false)
    let redMat = SimpleMaterial(color: .red, isMetallic: false)

    @State private var arrowRoot: Entity = Entity()

    init() {
        ArrowAttractorComponent.registerComponent()
        ArrowAttractorSystem.registerSystem()
    }

    var body: some View {
        RealityView { content in
            arrowRoot = ModelEntity(
                mesh: .generateCone(height: 0.04, radius: 0.02),
                materials: [blackMat])

            let arrowStyle = HoverEffectComponent.HighlightHoverEffectStyle(color: .white, strength: 5.0)
            let off: Float = 0.1

            let positions: [SIMD3<Float>] = [
                .init(0, -off, 0),
                .init(0,  off, 0),
                .init( off, 0, 0),
                .init(-off, 0, 0),
                .init(0, 0,  off),
                .init(0, 0, -off)
            ]

            for position in positions {
                let arrow = arrowRoot.clone(recursive: true)
                arrow.components.set(HoverEffectComponent(.highlight(arrowStyle)))
                arrow.components.set(ArrowAttractorComponent(
                    mass: 1,
                    velocity: .zero,
                    position: position,
                    rotation: .init(),
                    targetPoint: .zero
                ))
                root.addChild(arrow)
                arrows.append(arrow)
            }

            let rA: Float = 0.02
            attractionPoint = ModelEntity(
                mesh: .generateSphere(radius: rA),
                materials: [redMat])

            attractionPoint.components.set(
                CollisionComponent(shapes: [.generateSphere(radius: rA)])
            )
            attractionPoint.components.set(InputTargetComponent())

            let style = HoverEffectComponent.HighlightHoverEffectStyle(color: .red, strength: 5.0)
            attractionPoint.components.set(HoverEffectComponent(.highlight(style)))

            root.addChild(attractionPoint)
            content.add(root)

            root.position = SIMD3<Float>(0, 1.2, -1)
        }
        .gesture(tap)
    }

    var tap: some Gesture {
        DragGesture(minimumDistance: 0)
            .targetedToEntity(attractionPoint)
            .onChanged { value in
                let e = value.entity

                if !wasPressed {
                    wasPressed = true
                    dragStartPosition = e.position
                }

                let deltaParent = value.convert(value.translation3D, from: .local, to: root)
                let newTargetPosition = dragStartPosition + deltaParent
                attractionPoint.position = newTargetPosition

                for arrow in arrows {
                    arrow.components[ArrowAttractorComponent.self] =
                        arrow.components[ArrowAttractorComponent.self]?.updated(targetPoint: newTargetPosition)
                }
            }
            .onEnded { value in
                let deltaParent = value.convert(value.translation3D, from: .local, to: root)
                let newTargetPosition = dragStartPosition + deltaParent
                attractionPoint.position = newTargetPosition

                for arrow in arrows {
                    arrow.components[ArrowAttractorComponent.self] =
                        arrow.components[ArrowAttractorComponent.self]?.updated(targetPoint: newTargetPosition)
                }

                wasPressed = false
            }
    }
}

struct ArrowAttractorComponent: Component {
    let mass: Float
    let position: SIMD3<Float>
    let velocity: SIMD3<Float>
    let targetPoint: SIMD3<Float>
    let forceFactor: Float = 0.005
    let rotation: simd_quatf
    let rotationSpeed: Float = 0.05
    let maxSpeed: Float = 0.275
    let speed: Float = 3.0

    init(mass: Float, velocity: SIMD3<Float>, position: SIMD3<Float>, rotation: simd_quatf, targetPoint: SIMD3<Float>) {
        self.mass = mass
        self.velocity = velocity
        self.position = position
        self.rotation = rotation
        self.targetPoint = targetPoint
    }

    func getDistanceFromAttractor() -> Float {
        simd_distance(self.position, self.targetPoint)
    }

    func updated(deltaTime: Double) -> ArrowAttractorComponent {
        let direction = simd_normalize(self.targetPoint - self.position)
        let force = direction * self.forceFactor
        let acceleration = force / self.mass

        var velocity = self.velocity + acceleration
        if simd_length(velocity) > maxSpeed {
            velocity = simd_normalize(velocity) * maxSpeed
        }

        let position = self.position + velocity * Float(deltaTime) * self.speed

        let targetRotation = simd_quatf(from: SIMD3<Float>(0, 1, 0), to: direction)
        let smoothRotation = simd_slerp(self.rotation, targetRotation, self.rotationSpeed)

        return ArrowAttractorComponent(
            mass: self.mass,
            velocity: velocity,
            position: position,
            rotation: smoothRotation,
            targetPoint: self.targetPoint
        )
    }

    func updated(targetPoint: SIMD3<Float>) -> ArrowAttractorComponent {
        ArrowAttractorComponent(
            mass: self.mass,
            velocity: self.velocity,
            position: self.position,
            rotation: self.rotation,
            targetPoint: targetPoint
        )
    }
}

class ArrowAttractorSystem: System {
    private static let query = EntityQuery(where: .has(ArrowAttractorComponent.self))

    required init(scene: RealityFoundation.Scene) {}

    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard let comp = entity.components[ArrowAttractorComponent.self] else { continue }

            let newComp = comp.updated(deltaTime: context.deltaTime)
            entity.position = newComp.position
            entity.orientation = newComp.rotation
            entity.components[ArrowAttractorComponent.self] = newComp
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ArrowsAttractor()
}
