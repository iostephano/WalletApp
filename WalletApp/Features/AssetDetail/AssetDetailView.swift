//
//  AssetDetailView.swift
//  WalletApp
//
//  Created by Stephano Portella on 10/08/25.
//

import SwiftUI

private enum DetailMetrics {
    static let actionsTopSpacing: CGFloat = 14
    static let listTopSpacing: CGFloat = 14
    static let headerHeight: CGFloat = 140
}

struct AssetDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var vm: AssetDetailViewModel
    let onSwap: () -> Void

    init(vm: AssetDetailViewModel, onSwap: @escaping () -> Void) {
        self.vm = vm
        self.onSwap = onSwap
    }

    var body: some View {
        ZStack {
            ColorTokens.bg.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 0) {
                    header
                    actions
                        .padding(.top, DetailMetrics.actionsTopSpacing)
                    history
                        .padding(.top, DetailMetrics.listTopSpacing)
                    PrimaryCTA("Cambiar \(vm.asset.id)") { onSwap() }
                        .padding(.horizontal, SpaceTokens.xl)
                        .padding(.top, 8)
                }
                .padding(.horizontal, SpaceTokens.xl)
                .padding(.top, 8)
            }
        }
        .navigationBarHidden(true)
    }

    private var header: some View {
        TopGradientHeader {
            VStack(spacing: 0) {
                HStack {
                    CircleButton(icon: "chevron.left") { dismiss() }
                    Spacer()
                    Text(vm.asset.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                    CircleButton(icon: "ellipsis") {}
                }
                .padding(20)

                HStack {
                    HStack(spacing: 10) {
                        AssetIcon(assetID: vm.asset.id, diameter: 36)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(vm.asset.id.uppercased())
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white)
                            Text(vm.asset.name)
                                .font(.system(size: 12))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\((vm.holding?.amount ?? 0).formattedAmount()) \(vm.asset.id.uppercased())")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                        Text(vm.holdingValue.formattedUSD())
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            }
        }
        .frame(height: DetailMetrics.headerHeight)
    }

    private var actions: some View {
        VStack(spacing: 8) {
            HStack(spacing: SpaceTokens.l) {
                ActionPillTile(icon: "arrow.up.forward") {}
                ActionPillTile(icon: "arrow.down.backward") {}
                ActionPillTile(icon: "creditcard") {}
                ActionPillTile(icon: "ellipsis") {}
            }
            HStack(spacing: SpaceTokens.l) {
                ActionTextLabel("Enviar", width: 60)
                ActionTextLabel("Recibir", width: 60)
                ActionTextLabel("Comprar", width: 60)
                ActionTextLabel("Más", width: 60)
            }
        }
    }

    private var history: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(vm.txs) { tx in
                DSCard(corner: RadiusTokens.medium) {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.white.opacity(0.12))
                            .frame(width: 40, height: 40)
                            .overlay(Image(systemName: icon(for: tx.kind)).foregroundStyle(.white))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(title(for: tx.kind))
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white)
                            Text(tx.note)
                                .font(.system(size: 12))
                                .foregroundStyle(ColorTokens.textTertiary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text(tx.amount.formattedAmount(fractionLength: 4))
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(tx.amount >= 0 ? ColorTokens.positive : ColorTokens.textPrimary)
                            Text((tx.amount * vm.asset.priceUSD).formattedUSD())
                                .font(.system(size: 12))
                                .foregroundStyle(ColorTokens.textTertiary)
                        }
                    }
                    .padding(14)
                }
                .frame(height: 72)
            }
        }
    }

    private func icon(for kind: TxKind) -> String {
        switch kind {
        case .send: return "arrow.up.right"
        case .receive: return "arrow.down.left"
        case .swap: return "arrow.left.arrow.right"
        }
    }

    private func title(for kind: TxKind) -> String {
        switch kind {
        case .send: return "Envío"
        case .receive: return "Recepción"
        case .swap: return "Cambio"
        }
    }
}

private struct CircleButton: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(Color.white.opacity(0.18))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

private struct ActionTextLabel: View {
    let text: String
    let width: CGFloat

    init(_ text: String, width: CGFloat) {
        self.text = text
        self.width = width
    }

    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(.white)
            .frame(width: width)
    }
}
