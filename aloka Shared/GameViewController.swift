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
    
    var requests: [AnyCancellable] = []
    
    override func awakeFromNib() {
        // Load the "Box" scene from the "Experience" Reality File
        let deskAnchor = try! Experience.loadDesk()
        
        deskAnchor.actions.touch.onAction = { (entity: Entity?) in
            guard let entity = entity else { return }
            print("entities touched, action for \(entity.name)")

            var url = lightsEndpoint!
            
            switch entity {
            case deskAnchor.barLeft:
                url.appendPathComponent("5")
            case deskAnchor.barRight:
                url.appendPathComponent("6")
            case deskAnchor.barStrip:
                url.appendPathComponent("7")
            default:
                break
            }
            
            var changeRequest = URLRequest(url: url.appendingPathComponent("state"))
            changeRequest.httpMethod = "PUT"
            let state = LightState(bri: 50, hue: Int.random(in: 0...65280))
            changeRequest.httpBody = try! JSONEncoder().encode(state)
            print(changeRequest.debugDescription)
            let changeCancellable = session.dataTaskPublisher(for: changeRequest)
                .eraseToAnyPublisher()
                .sink(receiveCompletion: { (completion) in
                    print("change complete")
                }) { (value) in
                    print((value.response as! HTTPURLResponse).statusCode)
            }
            self.requests.append(changeCancellable)
        }
        
        arView.scene.anchors.append(deskAnchor)
    }
}
