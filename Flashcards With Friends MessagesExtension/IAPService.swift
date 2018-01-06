//
//  IAPService.swift
//  Flashcards With Friends MessagesExtension
//
//  Created by Leo Shao on 1/5/18.
//  Copyright © 2018 Leo Shao. All rights reserved.
//

import Foundation
import StoreKit

class IAPService: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    private override init() {}
    static let shared = IAPService()
    
    var products = [SKProduct]()
    let paymentQueue = SKPaymentQueue.default()
    
    func getProducts() {
        let products: Set = [IAPProduct.timed.rawValue]
        let request = SKProductsRequest(productIdentifiers: products)
        request.delegate = self
        request.start()
        paymentQueue.add(self)
    }
    
    func purchase(product: IAPProduct) {
        guard let productToPurchase = products.filter({ $0.productIdentifier == product.rawValue }).first else { return }
        print("works")
        let payment = SKPayment(product: productToPurchase)
        paymentQueue.add(payment)
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print(response.products)
        self.products = response.products
        for product in response.products {
            print(product.localizedTitle)
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            print(transaction.transactionState)
            print(transaction.transactionState.status(), transaction.payment.productIdentifier)
        }
    }
}

extension SKPaymentTransactionState {
    func status() -> String {
        switch self {
        case .deferred: return "deferred"
        case .failed: return "failed"
        case .purchased : return "purchased"
        case .purchasing: return "purchasing"
        case .restored: return "restored"
        }
    }
}
