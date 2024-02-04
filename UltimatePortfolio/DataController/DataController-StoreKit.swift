//
//  DataController-StoreKit.swift
//  UltimatePortfolio
//
//  Created by Brandon Johns on 2/2/24.
//

import Foundation
import StoreKit

				
extension DataController {
    /// The product ID for our premium unlock.
    static let unlockPremiumProductID = "BJ914.UltimatePortfolio.premiumUnlock"
    
    
    /// Loads and saves whether our premium unlock has been purchased.
    var fullVersionUnlocked: Bool {
        get {
            defaults.bool(forKey: "fullVersionUnlocked")
        }
        
        set {
            defaults.set(newValue, forKey: "fullVersionUnlocked")
        }
    }
    
    /// Monitors Premium Transactions
    /// checks for previous purchases so it should seemlessly update
    /// checks for future purchases and should unlock once purchased
    func monitorTransactions() async {
        // Check for previous purchases.
        for await entitlement in Transaction.currentEntitlements {
            if case let .verified(transaction) = entitlement {
                await finalize(transaction)
            }
        }
        
        // Watch for future transactions coming in.
        for await update in Transaction.updates {
            if let transaction = try? update.payloadValue {
                await finalize(transaction)
            }
        }
    }
    
    /// The purchase of the product
    /// if its successfully purchased  then send it to finalize
    /// - Parameter product: storekits Product built in purchase 
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()

        if case let .success(validation) = result {
            try await finalize(validation.payloadValue)
        }
    }

    
    @MainActor
    /// Finalizing the core of the inapp purchases
    /// MainActor because its change UI property to avoid making changes on  background tas k
    /// fullVersionUnlocked  boolean checks saying we are making a change
    /// revocationDate has a value that means there is a refund if not then fullversion is avalible
    /// - Parameter transaction: Unlocking the full version
    func finalize(_ transaction: Transaction) async {
        if transaction.productID == Self.unlockPremiumProductID {
            objectWillChange.send()
            //
            fullVersionUnlocked = transaction.revocationDate == nil
            await transaction.finish()
        }
    }
    
    @MainActor
    func loadProducts() async throws {
        guard products.isEmpty else { return }
        
        try await Task.sleep(for: .seconds(0.2))
        products = try await Product.products(for: [Self.unlockPremiumProductID])
    }
    

}

