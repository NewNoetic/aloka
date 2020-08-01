//
//  GameViewController.swift
//  aloka macOS
//
//  Created by Sidhant Gandhi on 7/30/20.
//

import AppKit
import RealityKit
import SceneKit

class GameViewController: NSViewController {
    
    @IBOutlet var arView: ARView!
    
    override func awakeFromNib() {
        // Load the "Box" scene from the "Experience" Reality File
        let deskAnchor = try! Experience.loadDesk()
        
        deskAnchor.actions.touch.onAction = { (entity: Entity?) in
            guard let entity = entity else { return }
            guard let left = entity.findEntity(named: "barLeft") else { return }
            guard let right = entity.findEntity(named: "barRight") else { return }
            print(left.name)
            print(right.name)
//            left.components.set(ModelComponent(mesh: (left.components[ModelComponent] as! ModelComponent).mesh, materials: [SimpleMaterial(color: .systemRed, isMetallic: false)]))
//            right.components.set(ModelComponent(mesh: (left.components[ModelComponent] as! ModelComponent).mesh, materials: [SimpleMaterial(color: .systemRed, isMetallic: false)]))
            
        }
        
        // Add the box anchor to the scene
//        arView.scene.anchors.append(deskAnchor)
    }
}
