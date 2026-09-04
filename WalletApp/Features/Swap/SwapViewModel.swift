//
//  SwapViewModel.swift
//  WalletApp
//
//  Created by Stephano Portella on 10/08/25.
//

import Foundation
import Observation

@MainActor
@Observable
final class SwapViewModel {
    private let repo: WalletRepository
    private(set) var from: Asset
    private(set) var to: Asset
    private(set) var amountFrom: String = ""
    private(set) var didSwap = false

    init(from: Asset, to: Asset, repo: WalletRepository) {
        self.from = from
        self.to = to
        self.repo = repo
    }

    var amountFromValue: Decimal { Decimal(keypadText: amountFrom) ?? 0 }

    var rate: Decimal {
        guard to.priceUSD > 0 else { return 0 }
        return from.priceUSD / to.priceUSD
    }

    var amountToValue: Decimal { amountFromValue * rate }

    var canSwap: Bool {
        let available = repo.holding(for: from.id)?.amount ?? 0
        return amountFromValue > 0 && amountFromValue <= available
    }

    func flip() {
        swap(&from, &to)
        amountFrom = ""
    }

    func append(_ character: String) {
        if character == "." && amountFrom.contains(".") { return }
        if character == "." && amountFrom.isEmpty { amountFrom = "0" }
        amountFrom.append(character)
    }

    func backspace() {
        guard !amountFrom.isEmpty else { return }
        amountFrom.removeLast()
    }

    func confirmSwap() {
        guard canSwap else { return }
        repo.recordSwap(from: from, to: to, amountFrom: amountFromValue, amountTo: amountToValue)
        didSwap = true
    }
}
