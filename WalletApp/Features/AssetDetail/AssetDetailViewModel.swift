//
//  AssetDetailViewModel.swift
//  WalletApp
//
//  Created by Stephano Portella on 10/08/25.
//

import Foundation
import Observation

@MainActor
@Observable
final class AssetDetailViewModel {
    let asset: Asset
    private let repo: WalletRepository
    private(set) var txs: [Transaction] = []
    private(set) var holding: Holding?

    init(asset: Asset, repo: WalletRepository) {
        self.asset = asset
        self.repo = repo
        load()
    }

    func load() {
        holding = repo.holding(for: asset.id)
        txs = repo.transactions(for: asset.id)
    }

    var holdingValue: Decimal {
        (holding?.amount ?? 0) * asset.priceUSD
    }
}
