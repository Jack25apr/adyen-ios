//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import AdyenActions
import XCTest

class RedirectDetailsTests: XCTestCase {
    
    func testPayloadExtractionFromURL() {
        let url = URL(string: "url://?param1=abc&payload=some&param2=3")!
        let details = RedirectDetails(returnURL: url)
        let keyValues = details.extractKeyValuesFromURL()!
        
        XCTAssertEqual(keyValues.count, 1)
        XCTAssertEqual(keyValues[0].0, RedirectDetails.CodingKeys.payload)
        XCTAssertEqual(keyValues[0].1, "some")

        XCTAssertNotNil(try? JSONEncoder().encode(details))
    }
    
    func testRedirectResultExtractionFromURL() {
        let url = URL(string: "url://?param1=abc&redirectResult=some&param2=3")!
        let details = RedirectDetails(returnURL: url)
        let keyValues = details.extractKeyValuesFromURL()!
        
        XCTAssertEqual(keyValues.count, 1)
        XCTAssertEqual(keyValues[0].0, RedirectDetails.CodingKeys.redirectResult)
        XCTAssertEqual(keyValues[0].1, "some")

        XCTAssertNotNil(try? JSONEncoder().encode(details))
    }
    
    func testPaResAndMDExtractionFromURL() {
        let url = URL(string: "url://?param1=abc&PaRes=some&MD=lorem")!
        let details = RedirectDetails(returnURL: url)
        let keyValues = details.extractKeyValuesFromURL()!
        
        XCTAssertEqual(keyValues.count, 2)
        // PaRes
        XCTAssertEqual(keyValues[0].0, RedirectDetails.CodingKeys.paymentResponse)
        XCTAssertEqual(keyValues[0].1, "some")
        // MD
        XCTAssertEqual(keyValues[1].0, RedirectDetails.CodingKeys.merchantData)
        XCTAssertEqual(keyValues[1].1, "lorem")

        XCTAssertNotNil(try? JSONEncoder().encode(details))
    }
    
    func testRedirectResultExtractionFromURLWithEncodedParameter() {
        let url = URL(string: "url://?param1=abc&redirectResult=encoded%21%20%40%20%24&param2=3")!
        let details = RedirectDetails(returnURL: url)
        let keyValues = details.extractKeyValuesFromURL()!
        
        XCTAssertEqual(keyValues.count, 1)
        XCTAssertEqual(keyValues[0].0, RedirectDetails.CodingKeys.redirectResult)
        XCTAssertEqual(keyValues[0].1, "encoded! @ $")

        XCTAssertNotNil(try? JSONEncoder().encode(details))
    }

    func testQueryStringExtractionFromURL() {
        let url = URL(string: "url://?param1=abc&pp=H7j5+pwnbNk8uKpS/m67rDp/K+AiJbQ==&param2=3")!
        let details = RedirectDetails(returnURL: url)
        let keyValues = details.extractKeyValuesFromURL()!

        XCTAssertEqual(keyValues.count, 1)
        XCTAssertEqual(keyValues[0].0, RedirectDetails.CodingKeys.queryString)
        XCTAssertEqual(keyValues[0].1, "param1=abc&pp=H7j5+pwnbNk8uKpS/m67rDp/K+AiJbQ==&param2=3")

        XCTAssertNotNil(try? JSONEncoder().encode(details))
    }

    func testExtractionFromURLWithoutQuery() {
        let url = URL(string: "url://")!
        let details = RedirectDetails(returnURL: url)
        
        XCTAssertNil(details.extractKeyValuesFromURL())
        XCTAssertThrowsError(try JSONEncoder().encode(details)) { _ in }
    }

    func testEncoding() {
        let url = URL(string: "badURL")!
        let details = RedirectDetails(returnURL: url)

        XCTAssertThrowsError(try JSONEncoder().encode(details)) { error in
            XCTAssertTrue(error is EncodingError)
            XCTAssertEqual((error as! EncodingError).localizedDescription, "The data couldn’t be written because it isn’t in the correct format.")
        }

    }
}
