//
//  DeskExperience.swift
//  aloka
//
//  Created by Sidhant Gandhi on 8/4/20.
//

import Foundation
import SceneKit
import RealityKit
import Combine

class DeskExperience {
    var arView: ARView
    var requests: [AnyCancellable] = []
    var collisionUpdates: [Cancellable] = []
    var originalModels: [String:ModelComponent] = [:]
    
    init(arView: ARView) {
        self.arView = arView
    }
    
    func start() {
        Hue.shared.getLights()

        let deskAnchor = try! Experience.loadDesk()
        
        let actualEntities = deskAnchor.children[0].children[0].children.compactMap { (composerEntity) -> Entity? in
            guard composerEntity.name.contains("light") || composerEntity.name.contains("field") else { return nil }
            let child = composerEntity.children.first
            child?.name = composerEntity.name
            return child
        }
        actualEntities.forEach { (entity) in
            entity.generateCollisionShapes(recursive: true)
        }
        
        let began = self.arView.scene.subscribe(to: CollisionEvents.Began.self) { event in
            let light = event.entityA
            guard light.name.contains("light") else { return }
            print("Light collision began\n\(event)")
            
            let originalModel: ModelComponent = light.components[ModelComponent]!.self
            self.originalModels[light.name] = originalModel
            
            var redModel = originalModel
            redModel.materials = [SimpleMaterial(color: .red, isMetallic: true)]
            light.components.set(redModel)
            
            if var hueLight = Hue.shared.lights.filter({ light.name.contains($0.name) }).first {
                var newState = LightState()
                newState.bri = 20
                hueLight.state = newState
                Hue.shared.sync(light: hueLight)
            }
        }
        let ended = self.arView.scene.subscribe(to: CollisionEvents.Ended.self) { event in
            let light = event.entityA
            guard light.name.contains("light") else { return }
            print("Light collision ended\n\(event)")
            
            light.components.set(self.originalModels[light.name]!)
            
            if var hueLight = Hue.shared.lights.filter({ light.name.contains($0.name) }).first {
                var newState = LightState()
                newState.bri = 100
                hueLight.state = newState
                Hue.shared.sync(light: hueLight)
            }
        }
        
        self.collisionUpdates.append(contentsOf: [began, ended])
        
        arView.scene.anchors.append(deskAnchor)
    }
}
