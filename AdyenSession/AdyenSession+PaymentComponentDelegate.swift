//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenActions)
    @_spi(AdyenInternal) import AdyenActions
#endif
import Foundation

@_spi(AdyenInternal)
extension AdyenSession: PaymentComponentDelegate {
    public func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
        let handler = delegate?.handlerForPayments(in: component, session: self) ?? self
        handler.didSubmit(data, from: component, dropInComponent: nil, session: self)
    }
    
    internal func finish(with resultCode: SessionPaymentResultCode, component: Component) {
        delegate?.didComplete(with: resultCode, component: component, session: self)
    }
    
    internal func finish(with error: Error, component: Component) {
        didFail(with: error, currentComponent: component)
    }

    public func didFail(with error: Error, from component: PaymentComponent) {
        didFail(with: error, currentComponent: component)
    }
    
    internal func didFail(with error: Error, currentComponent: Component) {
        delegate?.didFail(with: error, from: currentComponent, session: self)
    }
}

@_spi(AdyenInternal)
extension AdyenSession: AdyenSessionPaymentsHandler {
    public func didSubmit(_ paymentComponentData: PaymentComponentData,
                          from component: Component,
                          dropInComponent: AnyDropInComponent?,
                          session: AdyenSession) {
        let request = PaymentsRequest(sessionId: sessionContext.identifier,
                                      sessionData: sessionContext.data,
                                      data: paymentComponentData)
        apiClient.perform(request) { [weak self] in
            self?.handle(paymentResponseResult: $0, for: component, in: dropInComponent)
        }
    }
    
    internal func handle(paymentResponseResult: Result<PaymentsResponse, Error>,
                         for currentComponent: Component,
                         in dropInComponent: AnyDropInComponent? = nil) {
        switch paymentResponseResult {
        case let .success(response):
            handle(paymentResponse: response, for: currentComponent, in: dropInComponent)
        case let .failure(error):
            finish(with: error, component: currentComponent)
        }
    }
    
    private func handle(paymentResponse response: PaymentsResponse,
                        for currentComponent: Component,
                        in dropInComponent: AnyDropInComponent?) {
        if let action = response.action {
            handle(action: action, for: currentComponent, in: dropInComponent)
        } else if let order = response.order,
                  let remainingAmount = order.remainingAmount,
                  remainingAmount.value > 0 {
            handle(order: order, for: currentComponent, in: dropInComponent)
        } else {
            finish(with: SessionPaymentResultCode(paymentResultCode: response.resultCode),
                   component: currentComponent)
        }
    }
    
    private func handle(action: Action,
                        for currentComponent: Component,
                        in dropInComponent: AnyDropInComponent?) {
        if let dropInComponent = dropInComponent as? ActionHandlingComponent {
            dropInComponent.handle(action)
        } else {
            actionComponent.handle(action)
        }
    }
    
    private func handle(order: PartialPaymentOrder,
                        for currentComponent: Component,
                        in dropInComponent: AnyDropInComponent?) {
        guard let dropInComponent = dropInComponent else {
            finish(with: PartialPaymentError.notSupportedForComponent,
                   component: currentComponent)
            return
        }
        Self.makeSetupCall(with: configuration,
                           baseAPIClient: apiClient,
                           order: order) { [weak self] result in
            self?.updateContext(with: result, component: currentComponent)
            self?.reload(dropInComponent: dropInComponent,
                         with: order,
                         currentComponent: currentComponent)
        }
    }
    
    private func updateContext(with result: Result<Context, Error>, component: Component) {
        switch result {
        case let .success(context):
            sessionContext = context
        case let .failure(error):
            finish(with: error, component: component)
        }
    }
    
    private func reload(dropInComponent: AnyDropInComponent,
                        with order: PartialPaymentOrder,
                        currentComponent: Component) {
        do {
            try dropInComponent.reload(with: order, sessionContext.paymentMethods)
        } catch {
            finish(with: error, component: currentComponent)
        }
    }
}
