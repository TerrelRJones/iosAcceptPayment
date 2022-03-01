//
//  AcceptPaymentApp.swift
//  AcceptPayment
//
//  Created by Terrel Jones on 2/28/22.
//

import SwiftUI
import Stripe

//let BackendUrl = "http://localhost:5000/runner-app-c0fab/us-central1/"
let BackendUrl = "http://localhost:4001/"

@main
struct AcceptPaymentApp: App {
    init() {
        let url = URL(string: BackendUrl + "config")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) in
            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 200,
                  let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data,
                      options: []) as? [String: Any],
                  let publishiablekey = json["publishablekey"] as? String
            else {
                print("Failed to retrieve publishable key")
                return
            }
            print("Fetched publishable key \(publishiablekey)")
            StripeAPI.defaultPublishableKey = publishiablekey
        })
        task.resume()
    }

    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

