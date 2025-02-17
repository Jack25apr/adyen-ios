//
// Copyright © 2020 Adyen. All rights reserved.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
import XCTest

class IssuerListComponentTests: XCTestCase {

    private var analyticsProviderMock: AnalyticsProviderMock!
    private var context: AdyenContext!
    private var paymentMethod: IssuerListPaymentMethod!
    private var sut: IssuerListComponent!

    override func setUpWithError() throws {
        try super.setUpWithError()
        analyticsProviderMock = AnalyticsProviderMock()
        context = AdyenContext(apiContext: Dummy.apiContext, analyticsProvider: analyticsProviderMock)

        paymentMethod = try! Coder.decode(issuerListDictionary) as IssuerListPaymentMethod
        sut = IssuerListComponent(paymentMethod: paymentMethod, context: context)
    }

    override func tearDownWithError() throws {
        analyticsProviderMock = nil
        context = nil
        paymentMethod = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testStartStopLoading() {
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let listViewController = sut.viewController as? ListViewController
        XCTAssertNotNil(listViewController)
        
        wait(for: .milliseconds(300))
        
        let item = listViewController!.sections[0].items[0]
        let cell = listViewController!.tableView.visibleCells[0] as! ListCell
        XCTAssertFalse(cell.showsActivityIndicator)
        listViewController?.startLoading(for: item)
        XCTAssertTrue(cell.showsActivityIndicator)
        sut.stopLoadingIfNeeded()
        XCTAssertFalse(cell.showsActivityIndicator)
    }

    func testViewWillAppearShouldSendTelemetryEvent() throws {
        // Given
        let mockViewController = UIViewController()

        // When
        sut.viewWillAppear(viewController: mockViewController)

        // Then
        XCTAssertEqual(analyticsProviderMock.sendTelemetryEventCallsCount, 1)
    }
}
