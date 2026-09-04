//
//  SwapView.swift
//  WalletApp
//
//  Created by Stephano Portella on 10/08/25.
//

import SwiftUI

struct SwapView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var vm: SwapViewModel

    init(vm: SwapViewModel) { self.vm = vm }

    var body: some View {
        ZStack {
            ColorTokens.bg.ignoresSafeArea()
            VStack(spacing: 12) {
                appBar
                amountCard(title: "Entregas", asset: vm.from, value: displayFrom)
                flipButton
                amountCard(title: "Recibes", asset: vm.to, value: vm.amountToValue.formattedAmount())
                keypad
                PrimaryCTA("Cambiar", enabled: vm.canSwap) { vm.confirmSwap() }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
            }
        }
        .navigationBarHidden(true)
        .onChange(of: vm.didSwap) { _, didSwap in
            if didSwap { dismiss() }
        }
    }

    private var displayFrom: String {
        vm.amountFrom.isEmpty ? "0" : vm.amountFrom
    }

    private var appBar: some View {
        TopGradientHeader {
            HStack {
                CircleButton(icon: "chevron.left") { dismiss() }
                Spacer()
                Text("Cambiar")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
                CircleButton(icon: "ellipsis") {}
            }
            .padding(20)
        }
        .frame(height: 96)
    }

    private func amountCard(title: String, asset: Asset, value: String) -> some View {
        DSCard {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(TypoTokens.caption)
                        .foregroundStyle(ColorTokens.textTertiary)

                    HStack(spacing: 10) {
                        AssetIcon(assetID: asset.id, diameter: 36)
                        Text(asset.name)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                        Spacer()
                    }
                }

                Text(value)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .padding(14)
        }
        .frame(height: 88)
        .padding(.horizontal, 20)
    }

    private var flipButton: some View {
        Button { vm.flip() } label: {
            Image(systemName: "arrow.up.arrow.down.circle.fill")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(ColorTokens.gTop)
                .padding(10)
        }
        .accessibilityLabel("Invertir activos")
    }

    private var keypad: some View {
        VStack(spacing: 12) {
            ForEach([["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"], [".", "0", "⌫"]], id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { key in
                        Button {
                            if key == "⌫" { vm.backspace() } else { vm.append(key) }
                        } label: {
                            Text(key)
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, minHeight: 64)
                                .background(ColorTokens.surfaceAlt)
                                .clipShape(RoundedRectangle(cornerRadius: RadiusTokens.medium, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: RadiusTokens.medium, style: .continuous)
                                        .stroke(ColorTokens.stroke, lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.top, 6)
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
                .frame(width: 34, height: 34)
                .background(Color.white.opacity(0.15))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}
