//
//  mParticleAnalyticsHandler.swift
//  Simcoe
//
//  Created by Christopher Jones on 2/16/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import mParticle_Apple_SDK

/// Simcoe Analytics handler for the MParticle iOS SDK.
open class mParticle {

    fileprivate static let unknownErrorMessage = "An unknown error occurred."

    /// The name of the tracker.
    open let name = "mParticle"

    /**
     Initializes and starts the SDK with the input key and secret.

     - parameter key:              The key.
     - parameter secret:           The secret.
     - parameter installationType: The installation type.
     - parameter environment:      The environment.
     - parameter proxyAppDelegate: Determines if app delegate proxy should be used.

     - returns: A mParticle instance.
     */
    public init(key: String,
                secret: String,
                installationType: MPInstallationType = .autodetect,
                environment: MPEnvironment = .autoDetect,
                proxyAppDelegate: Bool = true) {
        MParticle.sharedInstance().start(withKey: key,
                                                secret:secret,
                                                installationType: installationType,
                                                environment: environment,
                                                proxyAppDelegate: proxyAppDelegate)
    }

    /// Starts the mParticle SDK with the api_key and api_secret saved in MParticleConfig.plist.
    /// - warning: This may throw an error if the MPartcileConfig.plist file is not found in the main bundle.
    public init() {
        MParticle.sharedInstance().start()
    }

}

// MARK: - CartLogging

extension mParticle: CartLogging {

    /// Logs the addition of a product to the cart.
    ///
    /// - parameter product:         The SimcoeProductConvertible instance.
    /// - parameter eventProperties: The event properties.
    ///
    /// - returns: A tracking result.
    public func logAddToCart<T: SimcoeProductConvertible>(_ product: T, eventProperties: Properties?) -> TrackingResult {
        let mPProduct = MPProduct(product: product)
        let event = MPCommerceEvent(eventType: .addToCart,
                                    products: [mPProduct],
                                    eventProperties: eventProperties)

        MParticle.sharedInstance().logCommerceEvent(event)

        return .success
    }

    /// Logs the removal of a product from the cart.
    ///
    /// - parameter product:         The SimcoeProductConvertible instance.
    /// - parameter eventProperties: The event properties.
    ///
    /// - returns: A tracking result.
    public func logRemoveFromCart<T: SimcoeProductConvertible>(_ product: T, eventProperties: Properties?) -> TrackingResult {
        let mPProduct = MPProduct(product: product)
        let event = MPCommerceEvent(eventType: .removeFromCart,
                                    products: [mPProduct],
                                    eventProperties: eventProperties)

        MParticle.sharedInstance().logCommerceEvent(event)

        return .success
    }
    
}

// MARK: - CheckoutTracking

extension mParticle: CheckoutTracking {

    /// Tracks a checkout event.
    ///
    /// - parameter products:        The products.
    /// - parameter eventProperties: The event properties.
    ///
    /// - returns: A tracking result.
    public func trackCheckoutEvent<T: SimcoeProductConvertible>(_ products: [T], eventProperties: Properties?) -> TrackingResult {
        let mPProducts = products.map { MPProduct(product: $0) }
        let event = MPCommerceEvent(eventType: .checkout,
                                    products: mPProducts,
                                    eventProperties: eventProperties)

        MParticle.sharedInstance().logCommerceEvent(event)

        return .success
    }

}

// MARK: - ErrorLogging

extension mParticle: ErrorLogging {

    /**
     Logs an error through mParticle.

     It is recommended that you use the `Simcoe.eventData()` function in order to generate the properties
     dictionary properly.

     - parameter error:      The error to log.
     - parameter properties: The properties of the event.
     */
    public func log(error: String, withAdditionalProperties properties: Properties? = nil) -> TrackingResult {
        MParticle.sharedInstance().logError(error, eventInfo: properties)

        return .success
    }

}

// MARK: - EventTracking

extension mParticle: EventTracking {

    /**
     Tracks an mParticle event.

     Internally, this generates an MPEvent object based on the properties passed in. The event string
     passed as the first parameter is delineated as the .name of the MPEvent. As a caller, you are
     required to pass in non-nil properties where one of the properties is the MPEventType. Failure
     to do so will cause this function to fail.

     It is recommended that you use the `Simcoe.eventData()` function in order to generate the properties
     dictionary properly.

     - parameter event:      The event name to log.
     - parameter properties: The properties of the event.
     */
    public func track(event: String, withAdditionalProperties properties: Properties?) -> TrackingResult {
        guard var properties = properties else {
            return .error(message: "Cannot track an event without valid properties.")
        }

        properties[MPEventKeys.name.rawValue] = event as AnyObject

        let event: MPEvent
        do {
            event = try MPEvent.toEvent(usingData: properties)
        } catch let error as MPEventGenerationError {
            return .error(message: error.description)
        } catch {
            return .error(message: mParticle.unknownErrorMessage)
        }

        MParticle.sharedInstance().logEvent(event)

        return .success
    }

}

// MARK: - LifetimeValueIncreasing

extension mParticle: LifetimeValueIncreasing {

    /**
     Increases the lifetime value of the key by the specified amount.

     - parameter amount:     The amount to increase that lifetime value for.
     - parameter item:       The optional item to extend.
     - parameter properties: The optional additional properties.

     - returns: A tracking result.
     */
    public func increaseLifetimeValue(byAmount amount: Double, forItem item: String?,
                                               withAdditionalProperties properties: Properties?) -> TrackingResult {
        MParticle.sharedInstance().logLTVIncrease(amount, eventName: (item ?? ""), eventInfo: properties)

        return .success
    }
    
}

// MARK: - LocationTracking

extension mParticle: LocationTracking {

    /**
     Tracks the user's location.

     Internally, this generates an MPEvent object based on the properties passed in. As a result, it is
     required that the properties dictionary not be nil and contains keys for .name and .eventType. The latitude
     and longitude of the location object passed in will automatically be added to the info dictionary of the MPEvent
     object; it is recommended not to include them manually unless there are other properties required to use them.

     It is recommended that you use the `Simcoe.eventData()` function in order to generate the properties
     dictionary properly.

     - parameter location:   The location data being tracked.
     - parameter properties: The properties for the MPEvent.
     */
    public func track(location: CLLocation, withAdditionalProperties properties: Properties?) -> TrackingResult {
        var eventProperties = properties ?? [String: AnyObject]() // TODO: Handle Error
        eventProperties["latitude"] = location.coordinate.latitude as AnyObject
        eventProperties["longitude"] = location.coordinate.longitude as AnyObject

        let event: MPEvent
        do {
            event = try MPEvent.toEvent(usingData: eventProperties)
        } catch let error as MPEventGenerationError {
            return .error(message: error.description)
        } catch {
            return .error(message: mParticle.unknownErrorMessage)
        }

        MParticle.sharedInstance().logEvent(event)

        return .success
    }

}

// MARK: - PageViewTracking

extension mParticle: PageViewTracking {

    /**
     Tracks the page view.

     - parameter pageView: The page view to track.

     - returns: A tracking result.
     */
    public func track(pageView: String, withAdditionalProperties properties: Properties?) -> TrackingResult {
        MParticle.sharedInstance().logScreen(pageView, eventInfo: properties)

        return .success
    }
    
}

// MARK: - PurchaseTracking

extension mParticle: PurchaseTracking {

    /// Tracks a purchase event.
    ///
    /// - parameter products:        The products.
    /// - parameter eventProperties: The event properties.
    ///
    /// - returns: A tracking result.
    public func trackPurchaseEvent<T : SimcoeProductConvertible>(_ products: [T], eventProperties: Properties?) -> TrackingResult {
        let mPProducts = products.map { MPProduct(product: $0) }
        let event = MPCommerceEvent(eventType: .purchase,
                                    products: mPProducts,
                                    eventProperties: eventProperties)

        MParticle.sharedInstance().logCommerceEvent(event)

        return .success
    }
    
}


// MARK: - UserAttributeTracking

extension mParticle: UserAttributeTracking {
    
    /**
     Sets the User Attribute through mParticle.
     
     - parameter key:   The key of the user attribute
     - parameter value: the value of the user attribute
     */
    public func setUserAttribute(_ key: String, value: AnyObject) -> TrackingResult {
        MParticle.sharedInstance().setUserAttribute(key, value: value)

        return .success
    }
    
}

// MARK: - ViewDetailLogging

extension mParticle: ViewDetailLogging {

    /// Logs the action of viewing a product's details.
    ///
    /// - parameter product: The SimcoeProductConvertible instance.
    /// - parameter eventProperties: The event properties.
    ///
    /// - returns: A tracking result.
    public func logViewDetail<T: SimcoeProductConvertible>(_ product: T, eventProperties: Properties?) -> TrackingResult {
        let mPProduct = MPProduct(product: product)
        let event = MPCommerceEvent(eventType: .viewDetail,
                                    products: [mPProduct],
                                    eventProperties: eventProperties)

        MParticle.sharedInstance().logCommerceEvent(event)

        return .success
    }
    
}
