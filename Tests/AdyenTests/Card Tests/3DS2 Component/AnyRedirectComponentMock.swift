//
//  AnyRedirectComponentMock.swift
//  AdyenTests
//
//  Created by Mohamed Eldoheiri on 11/4/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

@_spi(AdyenInternal) @testable import AdyenActions
@testable @_spi(AdyenInternal) import AdyenCard
import Foundation

final class AnyRedirectComponentMock: AnyRedirectComponent {
    
    let apiContext = Dummy.apiContext

    var context: AdyenContext {
        return .init(apiContext: apiContext)
    }

    var delegate: ActionComponentDelegate?

    var onHandle: ((_ action: RedirectAction) -> Void)?

    func handle(_ action: RedirectAction) {
        onHandle?(action)
    }
}
