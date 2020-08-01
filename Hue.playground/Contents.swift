import PlaygroundSupport
import Foundation
import Combine

PlaygroundPage.current.needsIndefiniteExecution = true

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
    var on: Bool
    var bri: Int
    var hue: Int
    var sat: Int
    var effect: String
    var reachable: Bool
    var transitiontime: Int?
}

struct Light: Codable {
    var id: String!
    var name: String
    var type: String
    var state: LightState
}

let cancellable = session.dataTaskPublisher(for: getLights)
    .sink { completion in
        switch completion {
        case .failure(let error):
            print(error)
        case .finished:
            print("Success")
        }
    } receiveValue: { value in
        let lightsDictionary = (try? JSONDecoder().decode([String: Light].self, from: value.data))
        let lights = lightsDictionary?.map({ (key, value) -> Light in
            var light = value
            light.id = key
            return light
        })
        lights?.forEach({ light in
            print(light)
        })
    }

