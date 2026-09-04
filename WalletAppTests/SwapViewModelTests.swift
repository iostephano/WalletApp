//
//  SwapViewModelTests.swift
//  WalletAppTests
//
//  Created by Stephano Portella on 04/09/25.
//

import Testing
import Foundation
@testable import WalletApp

@MainActor
struct SwapViewModelTests {
    private func makeModel() -> (SwapViewModel, MockWalletRepository) {
        let repo = MockWalletRepository()
        let assets = repo.assets()
        let btc = assets.first { $0.id == "BTC" }!
        let eth = assets.first { $0.id == "ETH" }!
        return (SwapViewModel(from: btc, to: eth, repo: repo), repo)
    }

    @Test("Rate is the price ratio between the two assets")
    func rateIsPriceRatio() {
        let (vm, _) = makeModel()
        #expect(vm.rate == Decimal(string: "26700.00")! / Decimal(string: "1828.65")!)
    }

    @Test("Received amount is the entered amount times the rate")
    func receivedAmountFollowsRate() {
        let (vm, _) = makeModel()
        vm.append("2")
        #expect(vm.amountFromValue == 2)
        #expect(vm.amountToValue == 2 * vm.rate)
    }

    @Test("Typing a leading dot is normalized to 0.")
    func leadingDotBecomesZeroDot() {
        let (vm, _) = makeModel()
        vm.append(".")
        #expect(vm.amountFrom == "0.")
    }

    @Test("A second decimal separator is ignored")
    func secondDotIsIgnored() {
        let (vm, _) = makeModel()
        vm.append("1")
        vm.append(".")
        vm.append("5")
        vm.append(".")
        #expect(vm.amountFrom == "1.5")
    }

    @Test("Backspace removes the last character")
    func backspaceRemovesLastCharacter() {
        let (vm, _) = makeModel()
        vm.append("1")
        vm.append("2")
        vm.backspace()
        #expect(vm.amountFrom == "1")
    }

    @Test("canSwap requires a positive amount within the available balance")
    func canSwapRespectsBalance() {
        let (vm, _) = makeModel()
        #expect(vm.canSwap == false)

        vm.append("1")
        #expect(vm.canSwap == true)

        vm.backspace()
        vm.append("9")
        #expect(vm.canSwap == false)
    }

    @Test("Flip swaps the assets and clears the amount")
    func flipSwapsAssetsAndClearsAmount() {
        let (vm, _) = makeModel()
        vm.append("1")
        vm.flip()
        #expect(vm.from.id == "ETH")
        #expect(vm.to.id == "BTC")
        #expect(vm.amountFrom.isEmpty)
    }

    @Test("Confirming a valid swap records it and updates holdings")
    func confirmSwapPersistsTransaction() {
        let (vm, repo) = makeModel()
        let btcBefore = repo.holding(for: "BTC")!.amount

        vm.append("1")
        vm.confirmSwap()

        #expect(vm.didSwap == true)
        #expect(repo.holding(for: "BTC")!.amount == btcBefore - 1)
        #expect(repo.transactions(for: "BTC").contains { $0.kind == .swap && $0.amount == -1 })
        #expect(repo.transactions(for: "ETH").contains { $0.kind == .swap && $0.amount > 0 })
    }

    @Test("Confirming an invalid swap does nothing")
    func confirmSwapIgnoresInvalidAmount() {
        let (vm, repo) = makeModel()
        let btcBefore = repo.holding(for: "BTC")!.amount

        vm.append("5")
        vm.append("0")
        vm.confirmSwap()

        #expect(vm.didSwap == false)
        #expect(repo.holding(for: "BTC")!.amount == btcBefore)
    }
}
