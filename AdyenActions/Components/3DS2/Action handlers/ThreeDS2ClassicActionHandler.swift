//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Adyen3DS2
import Foundation

/// Handles the 3D Secure 2 fingerprint and challenge actions separately.
internal class ThreeDS2ClassicActionHandler: AnyThreeDS2ActionHandler, ComponentWrapper {
    
    internal let context: AdyenContext

    internal var wrappedComponent: Component { coreActionHandler }

    internal let coreActionHandler: ThreeDS2CoreActionHandler

    internal var transaction: AnyADYTransaction? {
        get {
            coreActionHandler.transaction
        }

        set {
            coreActionHandler.transaction = newValue
        }
    }
    
    /// `threeDSRequestorAppURL` for protocol version 2.2.0 OOB challenges
    internal var threeDSRequestorAppURL: URL? {
        get {
            coreActionHandler.threeDSRequestorAppURL
        }
        
        set {
            coreActionHandler.threeDSRequestorAppURL = newValue
        }
    }

    /// Initializes the 3D Secure 2 action handler.
    ///
    /// - Parameter apiContext: The API context.
    /// - Parameter service: The 3DS2 Service.
    /// - Parameter appearanceConfiguration: The appearance configuration of the 3D Secure 2 challenge UI.
    internal convenience init(context: AdyenContext,
                              service: AnyADYService,
                              appearanceConfiguration: ADYAppearanceConfiguration = ADYAppearanceConfiguration()) {
        self.init(context: context,
                  appearanceConfiguration: appearanceConfiguration)
        self.coreActionHandler.service = service
    }

    /// Initializes the 3D Secure 2 action handler.
    internal init(context: AdyenContext,
                  appearanceConfiguration: ADYAppearanceConfiguration) {
        self.context = context
        self.coreActionHandler = ThreeDS2CoreActionHandler(context: context,
                                                           appearanceConfiguration: appearanceConfiguration)
    }

    // MARK: - Fingerprint

    /// Handles the 3D Secure 2 fingerprint action.
    ///
    /// - Parameter fingerprintAction: The fingerprint action as received from the Checkout API.
    /// - Parameter completionHandler: The completion closure.
    internal func handle(_ fingerprintAction: ThreeDS2FingerprintAction,
                         completionHandler: @escaping (Result<ThreeDSActionHandlerResult, Error>) -> Void) {
        let event = Analytics.Event(
            component: fingerprintEventName,
            flavor: _isDropIn ? .dropin : .components,
            environment: context.apiContext.environment
        )
        coreActionHandler.handle(fingerprintAction, event: event) { result in
            switch result {
            case let .success(encodedFingerprint):
                let additionalDetails = ThreeDS2Details.fingerprint(encodedFingerprint)
                let result = ThreeDSActionHandlerResult.details(additionalDetails)
                completionHandler(.success(result))
            case let .failure(error):
                completionHandler(.failure(error))
            }
        }
    }

    // MARK: - Challenge

    /// Handles the 3D Secure 2 challenge action.
    ///
    /// - Parameter challengeAction: The challenge action as received from the Checkout API.
    /// - Parameter completionHandler: The completion closure.
    internal func handle(_ challengeAction: ThreeDS2ChallengeAction,
                         completionHandler: @escaping (Result<ThreeDSActionHandlerResult, Error>) -> Void) {
        let event = Analytics.Event(
            component: challengeEventName,
            flavor: _isDropIn ? .dropin : .components,
            environment: context.apiContext.environment
        )
        coreActionHandler.handle(challengeAction, event: event) { [weak self] result in
            switch result {
            case let .success(result):
                self?.handle(result, completionHandler: completionHandler)
            case let .failure(error):
                completionHandler(.failure(error))
            }
        }
    }

    private func handle(_ threeDSResult: ThreeDSResult,
                        completionHandler: @escaping (Result<ThreeDSActionHandlerResult, Error>) -> Void) {
        let additionalDetails = ThreeDS2Details.challengeResult(threeDSResult)
        completionHandler(.success(.details(additionalDetails)))
    }

    // MARK: - Private

    private let fingerprintEventName = "3ds2fingerprint"

    private let challengeEventName = "3ds2challenge"

}
