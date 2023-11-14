@testable import Cookie
import XCTest

final class AttributedStringTests: XCTestCase {
    let container = AttributeContainer().backgroundColor(.orange)

    func testNoMatch1() throws {
        let attributedStr = AttributedString("", highlightedString: "")
        XCTAssertEqual(attributedStr, AttributedString(""))
    }

    func testNoMatch2() throws {
        let attributedStr = AttributedString("abcde", highlightedString: "x")
        XCTAssertEqual(attributedStr, AttributedString("abcde"))
    }

    func testNoMatch3() throws {
        let attributedStr = AttributedString("abcde", highlightedString: "")
        XCTAssertEqual(attributedStr, AttributedString("abcde"))
    }

    func testNoMatch4() throws {
        let attributedStr = AttributedString("", highlightedString: "a")
        XCTAssertEqual(attributedStr, AttributedString(""))
    }

    func testSingleMatchBeginning() throws {
        let attributedStr = AttributedString("abcde", highlightedString: "a")
        let expected = AttributedString("a", attributes: container) + AttributedString("bcde")
        XCTAssertEqual(attributedStr, expected)
    }

    func testSingleMatchEnd() throws {
        let attributedStr = AttributedString("abcde", highlightedString: "e")
        let expected = AttributedString("abcd") + AttributedString("e", attributes: container)
        XCTAssertEqual(attributedStr, expected)
    }

    func testSingleMatchMiddle() throws {
        let attributedStr = AttributedString("abcde", highlightedString: "c")
        let expected = AttributedString("ab") + AttributedString("c", attributes: container) + AttributedString("de")
        XCTAssertEqual(attributedStr, expected)
    }

    func testSingleMatchFull() throws {
        let attributedStr = AttributedString("abcde", highlightedString: "aBcDe")
        let expected = AttributedString("abcde", attributes: container)
        XCTAssertEqual(attributedStr, expected)
    }

    func testSingleMatchFull2() throws {
        let attributedStr = AttributedString("aBcDe", highlightedString: "abcde")
        let expected = AttributedString("aBcDe", attributes: container)
        XCTAssertEqual(attributedStr, expected)
    }

    func testMultiMatch() throws {
        let attributedStr = AttributedString("abcda", highlightedString: "a")
        let expected = AttributedString("a", attributes: container) + AttributedString("bcd") + AttributedString("a", attributes: container)
        XCTAssertEqual(attributedStr, expected)
    }

    func testMultiMatch2() throws {
        let attributedStr = AttributedString("aabbabbaa", highlightedString: "a")
        let expected = AttributedString("aa", attributes: container) +
            AttributedString("bb") +
            AttributedString("a", attributes: container) +
            AttributedString("bb") +
            AttributedString("aa", attributes: container)

        XCTAssertEqual(attributedStr, expected)
    }

    func testMultiMatchCaseInsensitive() throws {
        let attributedStr = AttributedString("abcABCaAbA", highlightedString: "a")
        let expected = AttributedString("a", attributes: container) +
            AttributedString("bc") +
            AttributedString("A", attributes: container) +
            AttributedString("BC") +
            AttributedString("aA", attributes: container) +
            AttributedString("b") +
            AttributedString("A", attributes: container)

        XCTAssertEqual(attributedStr, expected)
    }
}
