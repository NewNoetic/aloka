//
//  Hue.swift
//  aloka
//
//  Created by Sidhant Gandhi on 8/4/20.
//

import Foundation

class SelfSignedCertificateDelegate: NSObject, URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // Trust the certificate even if not valid
        let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(.useCredential, urlCredential)
    }
}

let selfSigned = SelfSignedCertificateDelegate()
let session = URLSession(configuration: URLSessionConfiguration.default, delegate: selfSigned, delegateQueue: nil)

let api = URL(string: "https://192.168.86.162")?.appendingPathComponent("api") /// DHCP IP reserved on *everythingship*
let username = "Asd6nrSHZjjd5ZYaYtRWu4kRFApXNZultHiBrYqJ"
let lightsEndpoint = api?.appendingPathComponent(username).appendingPathComponent("lights")

var getLights: URLRequest = {
    var request = URLRequest(url: lightsEndpoint!)
    request.httpMethod = "GET"
    return request
}()

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
