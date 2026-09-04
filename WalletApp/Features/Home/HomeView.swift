//
//  HomeView.swift
//  WalletApp
//
//  Created by Stephano Portella on 10/08/25.
//

import SwiftUI

// Ajustes de layout del header, agrupados para no repartir números mágicos por el archivo.
private enum HeaderMetrics {
    static let height: CGFloat = 360
    static let topBarExtraOffset: CGFloat = 65
    static let bottomLabelsInset: CGFloat = 10
    static let pillsBottomInset: CGFloat = 14
    static let centerLift: CGFloat = 26
}

struct HomeView: View {
    @Bindable var vm: HomeViewModel
    let onSelectAsset: (Asset) -> Void
    let onSwap: () -> Void

    @State private var selectedTab: TabID = .home

    init(vm: HomeViewModel, onSelectAsset: @escaping (Asset) -> Void, onSwap: @escaping () -> Void) {
        self.vm = vm
        self.onSelectAsset = onSelectAsset
        self.onSwap = onSwap
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ColorTokens.bg.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    header

                    if !vm.dismissDepositBanner {
                        depositBanner
                    }

                    assetBlock

                    Spacer(minLength: 200)
                }
            }
            .ignoresSafeArea(edges: .top)

            TabDockPop(
                selection: $selectedTab,
                items: [
                    TabItemModel(.home, "house.fill", "Inicio"),
                    TabItemModel(.wallet, "wallet.bifold.fill", "Cartera"),
                    TabItemModel(.discover, "square.grid.2x2", "Descubrir"),
                    TabItemModel(.browser, "globe", "Navegador")
                ]
            )
            .ignoresSafeArea(edges: .bottom)
            .zIndex(50)
        }
        .navigationBarHidden(true)
    }

    private var header: some View {
        GeometryReader { proxy in
            let safeTop = proxy.safeAreaInsets.top

            let shape = RoundedRectangle(cornerRadius: RadiusTokens.card, style: .continuous)

            ZStack(alignment: .top) {
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: ColorTokens.gTop, location: 0.00),
                        .init(color: ColorTokens.gMidHi, location: 0.33),
                        .init(color: ColorTokens.gMidLo, location: 0.66),
                        .init(color: ColorTokens.gBottom, location: 1.00)
                    ]),
                    startPoint: .top, endPoint: .bottom
                )
                .frame(height: HeaderMetrics.height + safeTop)
                .ignoresSafeArea(edges: .top)

                headerContent
                    .padding(.top, safeTop + HeaderMetrics.topBarExtraOffset)
            }
            .mask(shape)
            .overlay(shape.stroke(ColorTokens.stroke, lineWidth: 1))
            .shadow(color: .black.opacity(0.35), radius: 24, x: 0, y: 8)
        }
        .frame(height: HeaderMetrics.height)
    }

    private var headerContent: some View {
        ZStack {
            topBar
            balanceBlock
            quickActions
        }
    }

    private var topBar: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                if UIImage(named: "BrandMark") != nil {
                    Image("BrandMark")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 35)
                }
                Spacer()
                HStack(spacing: 10) {
                    GlassCircleButton(icon: "magnifyingglass", frameSize: 40) {}
                    GlassCircleButton(icon: "bell", frameSize: 40) {}
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    private var balanceBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Cartera principal")
                .font(.system(size: 11, weight: .semibold))
                .tracking(0.2)
                .foregroundStyle(.white.opacity(0.9))
            HStack(alignment: .top, spacing: 8) {
                Text(vm.hideBalance ? "$ •••••••" : vm.totalUSD.formattedUSD())
                    .font(TypoTokens.titleXL)
                    .tracking(1)
                    .kerning(-0.5)
                    .foregroundStyle(ColorTokens.textPrimary)

                Spacer(minLength: 0)

                GlassCircleButton(
                    icon: vm.hideBalance ? "eye.slash" : "eye",
                    transparent: true,
                    iconSize: 24
                ) { vm.hideBalance.toggle() }
            }
        }
        .padding(.horizontal, 20)
        .offset(y: -HeaderMetrics.centerLift)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    private var quickActions: some View {
        VStack(spacing: 6) {
            Spacer()
            HStack {
                Spacer(minLength: 0)
                ActionPillTile(icon: "arrow.up.forward") {}
                Spacer()
                ActionPillTile(icon: "arrow.down.backward") {}
                Spacer()
                ActionPillTile(icon: "creditcard") {}
                Spacer()
                ActionPillTile(icon: "arrow.left.arrow.right") { onSwap() }
                Spacer(minLength: 0)
            }
            HStack(spacing: 0) {
                Spacer(minLength: 0)
                ActionLabel("Enviar", width: 76, color: labelColor)
                Spacer()
                ActionLabel("Recibir", width: 76, color: labelColor)
                Spacer()
                ActionLabel("Comprar", width: 76, color: labelColor)
                Spacer()
                ActionLabel("Cambiar", width: 76, color: labelColor)
                Spacer(minLength: 0)
            }
            .padding(.bottom, HeaderMetrics.bottomLabelsInset)
        }
        .padding(.bottom, HeaderMetrics.pillsBottomInset)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    private let labelColor = Color(red: 60 / 255, green: 60 / 255, blue: 60 / 255)

    private var depositBanner: some View {
        DSCard(corner: RadiusTokens.medium) {
            HStack(spacing: 12) {
                WalletAddIcon().frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Añade fondos desde un exchange")
                        .font(.system(size: 13, weight: .semibold))
                        .tracking(0.2)
                        .foregroundStyle(.white)
                    HStack(spacing: 6) {
                        Text("Depositar ahora")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(ColorTokens.positive)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(ColorTokens.positive)
                    }
                }

                Spacer()

                Button { vm.dismissDepositBanner = true } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(width: 18, height: 18)
                        .background(Color.white)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(ColorTokens.strokeThin, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .frame(height: 64)
    }

    private var assetBlock: some View {
        DSCard(corner: RadiusTokens.card) {
            VStack(spacing: 10) {
                let segmentBinding = Binding<Int>(
                    get: { vm.segment.rawValue },
                    set: { vm.segment = HomeViewModel.Segment(rawValue: $0) ?? .crypto }
                )
                SegmentedPill(selection: segmentBinding, segments: ["Cripto", "NFTs"])
                    .padding(.horizontal, 8)
                    .padding(.top, 10)

                if vm.segment == .crypto {
                    VStack(spacing: 0) {
                        ForEach(vm.assets) { asset in
                            Button { onSelectAsset(asset) } label: {
                                AssetRowCell(asset: asset, holding: vm.holding(for: asset))
                            }
                            .buttonStyle(.plain)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 10)
                } else {
                    Text("Todavía no tienes NFTs")
                        .font(TypoTokens.body)
                        .foregroundStyle(ColorTokens.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(24)
                }
            }
            .padding(.vertical, 6)
        }
        .frame(minHeight: 500)
    }
}

private struct AssetRowCell: View {
    let asset: Asset
    let holding: Holding?

    private var amount: Decimal { holding?.amount ?? 0 }

    var body: some View {
        HStack(spacing: 12) {
            AssetIcon(assetID: asset.id)

            VStack(alignment: .leading, spacing: 4) {
                Text(asset.id)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)

                HStack(spacing: 6) {
                    Text(asset.priceUSD.formattedUSD())
                        .font(.system(size: 13))
                        .foregroundStyle(ColorTokens.textTertiary)

                    Text(String(format: "%@%.2f%%", asset.changePercent >= 0 ? "+" : "-", abs(asset.changePercent)))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(asset.changePercent >= 0 ? ColorTokens.positive : ColorTokens.negative)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(amount.formattedAmount())
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)

                Text((asset.priceUSD * amount).formattedUSD())
                    .font(.system(size: 12))
                    .foregroundStyle(ColorTokens.textTertiary)
            }
        }
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

private struct GlassCircleButton: View {
    let icon: String
    var transparent: Bool = false
    var iconSize: CGFloat = 20
    var frameSize: CGFloat = 32
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if !transparent {
                    Circle().fill(.ultraThinMaterial)
                }
                Image(systemName: icon)
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: frameSize, height: frameSize)
        }
        .buttonStyle(.plain)
    }
}

private struct ActionLabel: View {
    let text: String
    let width: CGFloat
    let color: Color

    init(_ text: String, width: CGFloat, color: Color) {
        self.text = text
        self.width = width
        self.color = color
    }

    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(color)
            .frame(width: width)
    }
}

private struct WalletAddIcon: View {
    var body: some View {
        ZStack {
            Circle().fill(Color.white.opacity(0.15))
            Image(systemName: "creditcard")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white.opacity(0.9))
        }
        .frame(width: 45, height: 45)
    }
}
