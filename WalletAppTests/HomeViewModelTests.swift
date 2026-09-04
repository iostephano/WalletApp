//
//  HomeViewModelTests.swift
//  WalletAppTests
//
//  Created by Stephano Portella on 04/09/25.
//

import Testing
import Foundation
@testable import WalletApp

@MainActor
struct HomeViewModelTests {
    @Test("Loads the catalog and the holdings from the repository")
    func loadsAssetsAndHoldings() {
        let vm = HomeViewModel(repo: MockWalletRepository())
        #expect(vm.assets.count == 4)
        #expect(vm.holdings.count == 4)
        #expect(vm.segment == .crypto)
    }

    @Test("totalUSD adds up price times amount for every holding")
    func totalIsSumOfPositions() {
        let vm = HomeViewModel(repo: MockWalletRepository())
        let expected = Decimal(string: "2.1")! * Decimal(string: "26700.00")!
            + Decimal(string: "0.23")! * Decimal(string: "1828.65")!
            + Decimal(string: "20.03")! * Decimal(string: "0.052")!
            + Decimal(string: "10.61")! * Decimal(string: "1.00")!
        #expect(vm.totalUSD == expected)
    }

    @Test("holding(for:) matches by asset id")
    func holdingLookupMatchesByID() {
        let vm = HomeViewModel(repo: MockWalletRepository())
        let btc = vm.assets.first { $0.id == "BTC" }!
        #expect(vm.holding(for: btc)?.amount == Decimal(string: "2.1"))
    }
}
