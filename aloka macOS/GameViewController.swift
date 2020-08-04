//
//  GameViewController.swift
//  aloka macOS
//
//  Created by Sidhant Gandhi on 7/30/20.
//

import AppKit
import RealityKit
import SceneKit
import Combine

class GameViewController: NSViewController {
    
    @IBOutlet var arView: ARView!
    
    
    override func awakeFromNib() {
        let experience = DeskExperience(arView: arView)
        experience.start()
    }
}

