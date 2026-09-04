//
//  AssetDetailViewModelTests.swift
//  WalletAppTests
//
//  Created by Stephano Portella on 04/09/25.
//

import Testing
import Foundation
@testable import WalletApp

@MainActor
struct AssetDetailViewModelTests {
    private func asset(_ id: String, in repo: MockWalletRepository) -> Asset {
        repo.assets().first { $0.id == id }!
    }

    @Test("holdingValue is the held amount times the asset price")
    func holdingValueUsesPrice() {
        let repo = MockWalletRepository()
        let vm = AssetDetailViewModel(asset: asset("BTC", in: repo), repo: repo)
        #expect(vm.holding?.amount == Decimal(string: "2.1"))
        #expect(vm.holdingValue == Decimal(string: "2.1")! * Decimal(string: "26700.00")!)
    }

    @Test("Transactions come sorted from newest to oldest")
    func transactionsAreSortedDescending() {
        let repo = MockWalletRepository()
        let vm = AssetDetailViewModel(asset: asset("BTC", in: repo), repo: repo)
        #expect(vm.txs.count >= 2)
        #expect(vm.txs == vm.txs.sorted { $0.date > $1.date })
    }

    @Test("Reloading picks up a swap recorded after initialization")
    func reloadReflectsNewTransaction() {
        let repo = MockWalletRepository()
        let btc = asset("BTC", in: repo)
        let vm = AssetDetailViewModel(asset: btc, repo: repo)
        let countBefore = vm.txs.count

        repo.recordSwap(from: btc, to: asset("ETH", in: repo), amountFrom: 1, amountTo: 5)
        vm.load()

        #expect(vm.txs.count == countBefore + 1)
    }
}
