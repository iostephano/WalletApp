//
//  HomeViewModel.swift
//  WalletApp
//
//  Created by Stephano Portella on 10/08/25.
//

import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    enum Segment: Int { case crypto = 0, nfts = 1 }

    private let repo: WalletRepository
    var segment: Segment = .crypto
    var hideBalance = false
    var dismissDepositBanner = false

    private(set) var assets: [Asset] = []
    private(set) var holdings: [Holding] = []

    init(repo: WalletRepository) {
        self.repo = repo
        load()
    }

    func load() {
        assets = repo.assets()
        holdings = repo.holdings()
    }

    func holding(for asset: Asset) -> Holding? {
        holdings.first { $0.assetId == asset.id }
    }

    var totalUSD: Decimal {
        assets.reduce(Decimal.zero) { acc, asset in
            let amount = holding(for: asset)?.amount ?? 0
            return acc + asset.priceUSD * amount
        }
    }
}
