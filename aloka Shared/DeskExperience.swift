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

    var collisionStarted: Cancellable?
    var collisionUpdated: Cancellable?
    var collisionEnded: Cancellable?
    
    init(arView: ARView) {
        self.arView = arView
    }
    
    func start() {
        // Load the "Desk" scene from the "Experience" Reality File
        let deskAnchor = try! Experience.loadDesk()

        deskAnchor.red?.generateCollisionShapes(recursive: true)
        deskAnchor.barLeft?.generateCollisionShapes(recursive: true)
        deskAnchor.barRight?.generateCollisionShapes(recursive: true)
        deskAnchor.barStrip?.generateCollisionShapes(recursive: true)
        
        print(deskAnchor.red!)
        print(deskAnchor.barLeft!)
        print(deskAnchor.barRight!)
        print(deskAnchor.barStrip!)
        
        collisionStarted = arView.scene.subscribe(to: CollisionEvents.Began.self) { (event) in
            print("began \(event)")
        }

        collisionUpdated = arView.scene.subscribe(to: CollisionEvents.Updated.self) { (event) in
            print("updated")
        }
        
        collisionEnded = arView.scene.subscribe(to: CollisionEvents.Ended.self) { (event) in
            print("ended \(event)")
        }
        
        
        
//        deskAnchor.actions.touch.onAction = { (entity: Entity?) in
//            guard let entity = entity else { return }
//            print("entities touched, action for \(entity.name)")
//
//            var url = lightsEndpoint!
//
//            switch entity {
//            case deskAnchor.barLeft:
//                url.appendPathComponent("5")
//            case deskAnchor.barRight:
//                url.appendPathComponent("6")
//            case deskAnchor.barStrip:
//                url.appendPathComponent("7")
//            default:
//                break
//            }
//
//            var changeRequest = URLRequest(url: url.appendingPathComponent("state"))
//            changeRequest.httpMethod = "PUT"
//            let state = LightState(bri: 50, hue: Int.random(in: 0...65280))
//            changeRequest.httpBody = try! JSONEncoder().encode(state)
//            print(changeRequest.debugDescription)
//            let changeCancellable = session.dataTaskPublisher(for: changeRequest)
//                .eraseToAnyPublisher()
//                .sink(receiveCompletion: { (completion) in
//                    print("change complete")
//                }) { (value) in
//                    print((value.response as! HTTPURLResponse).statusCode)
//            }
//            self.requests.append(changeCancellable)
//        }
        
        arView.scene.anchors.append(deskAnchor)
    }
}