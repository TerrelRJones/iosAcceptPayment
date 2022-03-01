//
//  BackendModel.swift
//  AcceptPayment
//
//  Created by Terrel Jones on 2/28/22.
//

import Foundation
import Stripe

class BackendModel : ObservableObject {
    @Published var paymentStatus: STPPaymentHandlerActionStatus?
    @Published var paymentIntentParams: STPPaymentIntentParams?
    @Published var lastPaymentError: NSError?
    var paymentMethodType: String?
    var currency: String?
    
    func preparePaymentIntent(paymentMethodType: String, currency: String){
        self.paymentMethodType = paymentMethodType
        self.currency = currency
        
        let url = URL(string: BackendUrl + "api/v1/createPaymentIntent")!
        var request = URLRequest(url: url)
        
        let json: [String: Any] = [
            "paymentMethodType": paymentMethodType,
            "currency": currency
        ]
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: json)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) in
            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 200,
                  let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data,
                      options: []) as? [String: Any],
                  let clientSecret = json["clientSecret"] as? String else {
                      let message = error?.localizedDescription ?? "Failed to decode response from server"
                      print(message)
                      return
                  }
            
                print("Created PaymentIntent \(clientSecret)")
            DispatchQueue.main.async {
                self.paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
            }
        })
        task.resume()
    }
    
    func onCompletion(status: STPPaymentHandlerActionStatus, pi: STPPaymentIntent?, error: NSError?) {
        self.paymentStatus = status
        self.lastPaymentError = error
        
        if status == .succeeded {
            self.paymentIntentParams = nil
            preparePaymentIntent(paymentMethodType: self.paymentMethodType!, currency: self.currency!)
            
           
        }
    }
}
