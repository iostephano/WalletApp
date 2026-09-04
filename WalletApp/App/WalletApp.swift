//
//  WalletApp.swift
//  WalletApp
//
//  Created by Stephano Portella on 10/08/25.
//

import SwiftUI

@main
struct WalletApp: App {
    @State private var repo = MockWalletRepository()

    var body: some Scene {
        WindowGroup {
            RouterView(repo: repo)
                .preferredColorScheme(.dark)
        }
    }
}

struct RouterView: View {
    let repo: WalletRepository
    @State private var path: [Route] = []

    enum Route: Hashable {
        case asset(Asset)
        case swap(Asset, Asset)
    }

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(
                vm: HomeViewModel(repo: repo),
                onSelectAsset: { path.append(.asset($0)) },
                onSwap: { openDefaultSwap() }
            )
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .asset(let asset):
                    AssetDetailView(vm: AssetDetailViewModel(asset: asset, repo: repo)) {
                        openSwap(from: asset)
                    }
                case .swap(let from, let to):
                    SwapView(vm: SwapViewModel(from: from, to: to, repo: repo))
                }
            }
        }
        .tint(.white)
        .background(ColorTokens.bg)
    }

    private func openDefaultSwap() {
        let assets = repo.assets()
        guard let from = assets.first(where: { $0.id == "BTC" }) ?? assets.first,
              let to = assets.first(where: { $0.id == "ETH" }) ?? assets.first(where: { $0.id != from.id }) else { return }
        path.append(.swap(from, to))
    }

    private func openSwap(from asset: Asset) {
        guard let to = repo.assets().first(where: { $0.id != asset.id }) else { return }
        path.append(.swap(asset, to))
    }
}
