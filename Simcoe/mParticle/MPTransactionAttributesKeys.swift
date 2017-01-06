//
//  MPTransactionAttributesKeys.swift
//  Simcoe
//
//  Created by Michael Campbell on 11/2/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

/// The MPTransactionAttributes keys available.
///
/// - Affiliation: The affiliation.
/// - CouponCode: The coupon code.
/// - Revenue: The revenue amount.
/// - Shipping: The shipping amount.
/// - Tax: The tax amount.
/// - TransactionId: The transaction Id.
public enum MPTransactionAttributesKeys: String, EnumerationListable {

    case affiliation = "affiliation"
    case couponCode = "couponCode"
    case revenue = "revenue"
    case shipping = "shipping"
    case tax = "tax"
    case transactionId = "transactionId"

    static let allKeys: [MPTransactionAttributesKeys] = [.affiliation, .couponCode, .revenue, .shipping, .tax, .transactionId]

}
