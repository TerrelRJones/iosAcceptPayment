//
//  ContentView.swift
//  AcceptPayment
//
//  Created by Terrel Jones on 2/28/22.
//

import SwiftUI
import Stripe

struct ContentView: View {
    @ObservedObject var model = BackendModel()
    @State var loading = false
    @State var paymentMethodParams: STPPaymentMethodParams?
    
    
    var body: some View {
        VStack {
            // Card Input
            STPPaymentCardTextField.Representable(paymentMethodParams: $paymentMethodParams).padding()
            
            if let paymentIntent =
                model.paymentIntentParams {
                Button("Confirm Payment"){
                    paymentIntent.paymentMethodParams = paymentMethodParams
                    loading = true
                }.paymentConfirmationSheet(isConfirmingPayment: $loading, paymentIntentParams: paymentIntent, onCompletion: model.onCompletion)
                    .disabled(loading)
                
            } else {
                Text("Loading")
            }
        }.onAppear{
            model.preparePaymentIntent(paymentMethodType: "card", currency: "usd")
        }
        
        if let paymentStatus = model.paymentStatus {
            HStack {
                switch paymentStatus {
                case .succeeded:
                    Text("Payment complete!")
                    // run code to postGig
                case .canceled:
                    Text("Payment cancled")
                case .failed:
                    Text("Payment failed!")
                @unknown default:
                    Text("Uknown status")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
