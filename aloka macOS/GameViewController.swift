//
//  GameViewController.swift
//  aloka macOS
//
//  Created by Sidhant Gandhi on 7/30/20.
//

import AppKit
import RealityKit

class GameViewController: NSViewController {
    
    @IBOutlet var arView: ARView!
    
    override func awakeFromNib() {
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
    }
}
