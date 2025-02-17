//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
import XCTest

class AtomeComponentTests: XCTestCase {

    private var analyticsProviderMock: AnalyticsProviderMock!
    private var context: AdyenContext!
    private var paymentMethod: PaymentMethod!
    private var style: FormComponentStyle!
    private var sut: AtomeComponent!

    override func setUpWithError() throws {
        paymentMethod = AtomePaymentMethod(type: .atome, name: "Atome")
        analyticsProviderMock = AnalyticsProviderMock()
        context = AdyenContext(apiContext: Dummy.apiContext, analyticsProvider: analyticsProviderMock)
        style = FormComponentStyle()
        sut = AtomeComponent(paymentMethod: paymentMethod,
                             context: context,
                             configuration: AtomeComponent.Configuration(style: style))
    }

    override func tearDownWithError() throws {
        analyticsProviderMock = nil
        context = nil
        paymentMethod = nil
        style = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testComponent_ShouldPaymentMethodTypeBeAtome() throws {
        // Given
        let expectedPaymentMethodType: PaymentMethodType = .atome
        
        // Action
        let paymentMethodType = sut.paymentMethod.type
        
        // Assert
        XCTAssertEqual(paymentMethodType, expectedPaymentMethodType)
    }
    
    func testComponent_ShouldRequireModalPresentation() throws {
        // Assert
        XCTAssertTrue(sut.requiresModalPresentation)
    }
    
    func testCreatePaymentDetails() throws {
        // Given
        let expectedBillingAddress = PostalAddressMocks.singaporePostalAddress
        sut.firstNameItem?.value = "John"
        sut.lastNameItem?.value = "smith"
        sut.phoneItem?.value = "6787860987"
        sut.addressItem?.value = expectedBillingAddress
        
        // Action
        let paymentDetails = try sut.createPaymentDetails()

        let shopperInformation = try XCTUnwrap(paymentDetails as? ShopperInformation)
        let firstName = try XCTUnwrap(shopperInformation.shopperName?.firstName)
        let lastName = try XCTUnwrap(shopperInformation.shopperName?.lastName)
        let phoneNumber = try XCTUnwrap(shopperInformation.telephoneNumber)
        let billingAddress = try XCTUnwrap(shopperInformation.billingAddress)

        // Assert
        XCTAssertEqual(firstName, "John")
        XCTAssertEqual(lastName, "smith")
        XCTAssertEqual(billingAddress, expectedBillingAddress)
        XCTAssertEqual(phoneNumber, "6787860987")
    }
    
    func testGetPhoneExtensions_ShouldReturnNonEmptyPhoneExtensionList() throws {
        // Action
        let phoneExtensions = sut.phoneExtensions()
        
        // Assert
        XCTAssertFalse(phoneExtensions.isEmpty)
    }

}
