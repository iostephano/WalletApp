//
//  MoneyTests.swift
//  WalletAppTests
//
//  Created by Stephano Portella on 04/09/25.
//

import Testing
import Foundation
@testable import WalletApp

struct MoneyTests {
    @Test("USD formatting uses a fixed locale and two decimals")
    func formattedUSDUsesFixedLocale() {
        let value = Decimal(string: "1234.5")!
        #expect(value.formattedUSD() == "$1,234.50")
    }

    @Test("Amount formatting respects the requested fraction length")
    func formattedAmountRespectsFractionLength() {
        let value = Decimal(string: "2.1")!
        #expect(value.formattedAmount() == "2.10")
        #expect(value.formattedAmount(fractionLength: 4) == "2.1000")
    }

    @Test("Keypad text with a comma is parsed as a decimal separator")
    func keypadTextAcceptsComma() {
        #expect(Decimal(keypadText: "1,5") == Decimal(string: "1.5"))
    }

    @Test("Invalid keypad text fails to parse")
    func invalidKeypadTextReturnsNil() {
        #expect(Decimal(keypadText: "abc") == nil)
    }
}
