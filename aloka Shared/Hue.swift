//
//  Hue.swift
//  aloka
//
//  Created by Sidhant Gandhi on 8/4/20.
//

import Foundation
import Combine

class Hue {
    class SelfSignedCertificateDelegate: NSObject, URLSessionDelegate {
        public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            // Trust the certificate even if not valid
            let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, urlCredential)
        }
    }
    
    let api: URL = URL(string: "https://192.168.86.162")!.appendingPathComponent("api") /// DHCP IP reserved on *everythingship*
    let username = "Asd6nrSHZjjd5ZYaYtRWu4kRFApXNZultHiBrYqJ"
    let selfSigned = SelfSignedCertificateDelegate()
    var session: URLSession
    var cancelLightsRequest: AnyCancellable?
    var syncRequests: [AnyCancellable] = []
    var lightsEndpoint: URL
    
    @Published var lights: [Light] = []
    
    public static var shared: Hue = Hue()
    
    private init() {
        self.session = URLSession(configuration: URLSessionConfiguration.default, delegate: selfSigned, delegateQueue: nil)
        self.lightsEndpoint = self.api.appendingPathComponent(username).appendingPathComponent("lights")
    }
    
    public func getLights() {
        var request = URLRequest(url: lightsEndpoint)
        request.httpMethod = "GET"
        self.cancelLightsRequest = self.session.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: [String: Light].self, decoder: JSONDecoder())
            .map({ (dictionary) -> [Light] in
                return dictionary.map({ (key, value) -> Light in
                    var light = value
                    light.id = key
                    return light
                })
            })
            .replaceError(with: [])
            .assign(to: \.lights, on: self)
    }
    
    func sync(light: Light) {
        var request = URLRequest(url: self.lightsEndpoint.appendingPathComponent(light.id).appendingPathComponent("state"))
        request.httpMethod = "PUT"
        request.httpBody = try! JSONEncoder().encode(light.state)
        let c = Hue.shared.session.dataTaskPublisher(for: request)
            .sink(receiveCompletion: {_ in }, receiveValue: {_ in })
        self.syncRequests.append(c)
        
    }
}


struct LightState: Codable {
    var on: Bool = true
    var bri: Int?
    var hue: Int?
    var sat: Int?
    var effect: String?
    var reachable: Bool?
    var transitiontime: Int?
}

struct Light: Codable {
    var id: String!
    var name: String
    var type: String
    var state: LightState
}
