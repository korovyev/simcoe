//
//  WishListLogging.swift
//  Simcoe
//
//  Created by Michael Campbell on 9/9/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

/**
 *  Defines functionality for logging wish list actions.
 */
public protocol WishListLogging: AnalyticsTracking {

    func logAddToWishlist(productName: String,
                          sku: String,
                          quantity: Int,
                          price: NSNumber?,
                          additionalProperties: Properties?) -> TrackingResult

    func logRemoveFromWishList(productName: String,
                               sku: String,
                               quantity: Int,
                               price: NSNumber?,
                               additionalProperties: Properties?) -> TrackingResult
    
}
