//
//  GameViewController.swift
//  aloka iOS
//
//  Created by Sidhant Gandhi on 7/30/20.
//

import UIKit
import RealityKit

class GameViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let experience = DeskExperience(arView: arView)
        experience.start()
    }
}
