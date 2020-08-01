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

//typealias DataTaskValue = (data: Data, response: URLResponse)
//typealias DataTaskPublisher = AnyPublisher<DataTaskValue, URLError>

let c = session.dataTaskPublisher(for: getLights)
    .flatMap { (value) -> Publishers.Zip3<URLSession.DataTaskPublisher, URLSession.DataTaskPublisher, URLSession.DataTaskPublisher> in
        let lightsDictionary = (try? JSONDecoder().decode([String: Light].self, from: value.data))
        let lights = lightsDictionary?.map({ (key, value) -> Light in
            var light = value
            light.id = key
            return light
        })
        let lightChangePublishers = lights!.map({ (light) -> URLSession.DataTaskPublisher in
            var redRequest = URLRequest(url: (lightsEndpoint!.appendingPathComponent(light.id).appendingPathComponent("state")))
            redRequest.httpMethod = "PUT"
            let state = LightState(bri: 100, hue: 56100)
            redRequest.httpBody = try! JSONEncoder().encode(state)
//            print(redRequest)
            return session.dataTaskPublisher(for: redRequest)
        })
        return lightChangePublishers[0].zip(lightChangePublishers[1], lightChangePublishers[2])
}
.sink(receiveCompletion: { (completion) in
    
}) { (value) in
    print(try! JSONSerialization.jsonObject(with: value.0.data, options: []))
    print(try! JSONSerialization.jsonObject(with: value.1.data, options: []))
    print(try! JSONSerialization.jsonObject(with: value.2.data, options: []))
}
//    .sink(receiveCompletion: { (completion) in
//        switch completion {
//        case .failure(let error):
//            print(error)
//        case .finished:
//            print("Success")
//        }
//    }) { (value) in
//        try! JSONSerialization.jsonObject(with: value.0.data, options: [])
//        try! JSONSerialization.jsonObject(with: value.1.data, options: [])
//}
