//
//  Money.swift
//  WalletApp
//
//  Created by Stephano Portella on 04/09/25.
//

import Foundation

extension Decimal {
    // Formateo monetario homogéneo para toda la app: siempre USD con locale fijo,
    // así la maqueta se ve igual sin importar la región del dispositivo.
    func formattedUSD(fractionLength: Int = 2) -> String {
        formatted(
            .currency(code: "USD")
            .locale(Locale(identifier: "en_US"))
            .precision(.fractionLength(fractionLength))
        )
    }

    // Cantidad de un activo (no es dinero, no lleva símbolo de moneda).
    func formattedAmount(fractionLength: Int = 2) -> String {
        formatted(
            .number
            .locale(Locale(identifier: "en_US"))
            .precision(.fractionLength(fractionLength))
        )
    }

    // Conversión desde el texto del keypad del swap, tolerante a coma decimal.
    init?(keypadText: String) {
        let normalized = keypadText.replacingOccurrences(of: ",", with: ".")
        guard let value = Decimal(string: normalized, locale: Locale(identifier: "en_US")) else { return nil }
        self = value
    }
}
