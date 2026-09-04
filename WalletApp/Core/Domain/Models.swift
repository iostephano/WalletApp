//
//  Models.swift
//  WalletApp
//
//  Created by Stephano Portella on 10/08/25.
//

import Foundation

struct Asset: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    // Precio de referencia en USD. Decimal para no arrastrar error binario en los cálculos de cartera.
    var priceUSD: Decimal
    // Variación diaria en porcentaje: es un indicador de display, no un importe monetario.
    var changePercent: Double

    init(id: String, name: String, priceUSD: Decimal, changePercent: Double) {
        self.id = id
        self.name = name
        self.priceUSD = priceUSD
        self.changePercent = changePercent
    }
}

struct Holding: Identifiable, Hashable, Sendable {
    var id: String { assetId }
    let assetId: String
    var amount: Decimal

    init(assetId: String, amount: Decimal) {
        self.assetId = assetId
        self.amount = amount
    }
}

enum TxKind: Sendable {
    case send, receive, swap
}

struct Transaction: Identifiable, Hashable, Sendable {
    let id: UUID
    let date: Date
    let kind: TxKind
    // Cantidad del activo movida (con signo). Decimal por el mismo motivo que el precio.
    let amount: Decimal
    let note: String

    init(id: UUID = UUID(), date: Date, kind: TxKind, amount: Decimal, note: String) {
        self.id = id
        self.date = date
        self.kind = kind
        self.amount = amount
        self.note = note
    }
}

// El repositorio se consume siempre desde la UI, por eso queda aislado en MainActor.
@MainActor
protocol WalletRepository {
    func assets() -> [Asset]
    func holdings() -> [Holding]
    func holding(for assetId: String) -> Holding?
    func transactions(for assetId: String) -> [Transaction]
    func recordSwap(from: Asset, to: Asset, amountFrom: Decimal, amountTo: Decimal)
}
