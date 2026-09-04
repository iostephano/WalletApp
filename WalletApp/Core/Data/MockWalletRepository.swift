//
//  MockWalletRepository.swift
//  WalletApp
//
//  Created by Stephano Portella on 10/08/25.
//

import Foundation

// Datos simulados con estado en memoria: un swap ajusta las tenencias y añade una
// transacción, para que la maqueta reaccione a la acción del usuario dentro de la sesión.
@MainActor
final class MockWalletRepository: WalletRepository {
    private let catalog: [Asset]
    private var holdingsByAsset: [String: Holding]
    private var transactionsByAsset: [String: [Transaction]]

    init() {
        let assets: [Asset] = [
            Asset(id: "BTC", name: "Bitcoin", priceUSD: dec("26700.00"), changePercent: 2.43),
            Asset(id: "ETH", name: "Ethereum", priceUSD: dec("1828.65"), changePercent: -0.42),
            Asset(id: "DOGE", name: "Dogecoin", priceUSD: dec("0.052"), changePercent: 20.38),
            Asset(id: "USDT", name: "Tether", priceUSD: dec("1.00"), changePercent: -1.42)
        ]
        catalog = assets

        holdingsByAsset = [
            "BTC": Holding(assetId: "BTC", amount: dec("2.1")),
            "ETH": Holding(assetId: "ETH", amount: dec("0.23")),
            "DOGE": Holding(assetId: "DOGE", amount: dec("20.03")),
            "USDT": Holding(assetId: "USDT", amount: dec("10.61"))
        ]

        let now = Date()
        func daysAgo(_ n: Double) -> Date { now.addingTimeInterval(-86_400 * n) }
        transactionsByAsset = [
            "BTC": [
                Transaction(date: daysAgo(1), kind: .send, amount: dec("-0.0021"), note: "Para: bc1qxy"),
                Transaction(date: daysAgo(2), kind: .send, amount: dec("-0.05"), note: "Para: bc1qxy"),
                Transaction(date: daysAgo(3), kind: .receive, amount: dec("0.0835"), note: "De: wb2dkxy"),
                Transaction(date: daysAgo(5), kind: .swap, amount: dec("-0.1"), note: "A: USDT")
            ],
            "ETH": [
                Transaction(date: daysAgo(2), kind: .receive, amount: dec("0.12"), note: "De: 0x9f3a"),
                Transaction(date: daysAgo(6), kind: .send, amount: dec("-0.04"), note: "Para: 0x1c2d")
            ],
            "DOGE": [
                Transaction(date: daysAgo(1), kind: .receive, amount: dec("15.0"), note: "De: DQk4rt"),
                Transaction(date: daysAgo(4), kind: .send, amount: dec("-3.5"), note: "Para: D9zz10")
            ],
            "USDT": [
                Transaction(date: daysAgo(3), kind: .receive, amount: dec("10.0"), note: "De: exchange")
            ]
        ]
    }

    func assets() -> [Asset] { catalog }

    func holdings() -> [Holding] {
        catalog.compactMap { holdingsByAsset[$0.id] }
    }

    func holding(for assetId: String) -> Holding? {
        holdingsByAsset[assetId]
    }

    func transactions(for assetId: String) -> [Transaction] {
        (transactionsByAsset[assetId] ?? []).sorted { $0.date > $1.date }
    }

    func recordSwap(from: Asset, to: Asset, amountFrom: Decimal, amountTo: Decimal) {
        guard amountFrom > 0 else { return }

        let currentFrom = holdingsByAsset[from.id]?.amount ?? 0
        holdingsByAsset[from.id] = Holding(assetId: from.id, amount: max(0, currentFrom - amountFrom))

        let currentTo = holdingsByAsset[to.id]?.amount ?? 0
        holdingsByAsset[to.id] = Holding(assetId: to.id, amount: currentTo + amountTo)

        let now = Date()
        transactionsByAsset[from.id, default: []].append(
            Transaction(date: now, kind: .swap, amount: -amountFrom, note: "A: \(to.id)")
        )
        transactionsByAsset[to.id, default: []].append(
            Transaction(date: now, kind: .swap, amount: amountTo, note: "De: \(from.id)")
        )
    }
}

// Los importes se escriben como texto para evitar el error binario de los literales de punto flotante.
private func dec(_ string: String) -> Decimal {
    Decimal(string: string, locale: Locale(identifier: "en_US")) ?? .zero
}
