//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenActions
import Adyen
import SafariServices
import XCTest

class AdyenActionComponentTests: XCTestCase {

    let weChatActionResponse = """
    {
      "paymentMethodType" : "wechatpaySDK",
      "paymentData" : "x",
      "type" : "sdk",
      "sdkData" : {
        "timestamp" : "x",
        "partnerid" : "x",
        "noncestr" : "x",
        "packageValue" : "Sign=WXPay",
        "sign" : "x",
        "appid" : "x",
        "prepayid" : "x"
      }
    }
    """

    let threeDSFingerprintAction = """
    {
      "token" : "x",
      "type" : "threeDS2",
      "authorisationToken" : "x",
      "subtype" : "fingerprint"
    }
    """

    func testRedirectToHttpWebLink() {
        let sut = AdyenActionComponent()
        let delegate = ActionComponentDelegateMock()
        sut.delegate = delegate

        delegate.onDidOpenExternalApplication = { _ in
            XCTFail("delegate.didOpenExternalApplication() must not to be called")
        }

        let action = Action.redirect(RedirectAction(url: URL(string: "https://www.adyen.com")!, paymentData: "test_data"))
        sut.perform(action)

        let waitExpectation = expectation(description: "Expect in app browser to be presented and then dismissed")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {

            let topPresentedViewController = UIViewController.findTopPresenter()
            XCTAssertNotNil(topPresentedViewController as? SFSafariViewController)

            sut.dismiss(true) {
                let topPresentedViewController = UIViewController.findTopPresenter()
                XCTAssertNil(topPresentedViewController as? SFSafariViewController)

                waitExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testAwaitAction() {
        let sut = AdyenActionComponent()
        sut.clientKey = "SOME_KLIENT_KEY"
        sut.presentationDelegate = UIViewController.findTopPresenter()

        let action = Action.await(AwaitAction(paymentData: "SOME_DATA", paymentMethodType: .blik))
        sut.perform(action)

        let waitExpectation = expectation(description: "Expect AwaitViewController to be presented")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
            let topPresentedViewController = UIViewController.findTopPresenter()
            XCTAssertNotNil(topPresentedViewController as? AdyenActions.AwaitViewController)

            (sut.presentationDelegate as! UIViewController).dismiss(animated: true) {
                let topPresentedViewController = UIViewController.findTopPresenter()
                XCTAssertNil(topPresentedViewController as? AdyenActions.AwaitViewController)

                waitExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testWeChatAction() {
        let sut = AdyenActionComponent()

        let sdkAction = try! JSONDecoder().decode(SDKAction.self, from: weChatActionResponse.data(using: .utf8)!)
        sut.perform(Action.sdk(sdkAction))

        let waitExpectation = expectation(description: "Expect weChatPaySDKActionComponent to be initiated")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {

            XCTAssertNotNil(sut.weChatPaySDKActionComponent)
            waitExpectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

    func test3DSAction() {
        let sut = AdyenActionComponent()

        let action = try! JSONDecoder().decode(ThreeDS2Action.self, from: threeDSFingerprintAction.data(using: .utf8)!)
        sut.perform(Action.threeDS2(action))

        let waitExpectation = expectation(description: "Expect in app browser to be presented and then dismissed")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
            XCTAssertNotNil(sut.threeDS2Component)
            waitExpectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }
}

extension UIViewController: PresentationDelegate {
    public func present(component: PresentableComponent, disableCloseButton: Bool) {
        self.present(component.viewController, animated: false, completion: nil)
    }
}
