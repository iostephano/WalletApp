//
//  AssetIcon.swift
//  WalletApp
//
//  Created by Stephano Portella on 04/09/25.
//

import SwiftUI
import UIKit

// Icono de un activo dentro de un círculo translúcido.
// Un único componente para Home, AssetDetail y Swap (antes había tres copias casi idénticas).
struct AssetIcon: View {
    let assetID: String
    var diameter: CGFloat = 48

    var body: some View {
        Circle()
            .fill(Color.white.opacity(0.12))
            .frame(width: diameter, height: diameter)
            .overlay(symbol)
    }

    @ViewBuilder
    private var symbol: some View {
        if let imageName = Self.catalogImageName(for: assetID) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .padding(diameter * 0.16)
        } else if let systemName = Self.systemSymbolName(for: assetID) {
            Image(systemName: systemName)
                .font(.system(size: diameter * 0.5, weight: .semibold))
                .foregroundStyle(.white)
        } else {
            Text(assetID.prefix(1))
                .font(.system(size: diameter * 0.42, weight: .bold))
                .foregroundStyle(.white)
        }
    }

    // Busca una imagen en el catálogo de assets probando variantes de mayúsculas del ticker.
    static func catalogImageName(for assetID: String) -> String? {
        let candidates = [assetID, assetID.uppercased(), assetID.lowercased()]
        return candidates.first { UIImage(named: $0) != nil }
    }

    // Respaldo con SF Symbols cuando no hay imagen del ticker.
    static func systemSymbolName(for assetID: String) -> String? {
        switch assetID.uppercased() {
        case "BTC", "XBT": return "bitcoinsign.circle.fill"
        case "ETH": return "diamond.fill"
        default: return nil
        }
    }
}
