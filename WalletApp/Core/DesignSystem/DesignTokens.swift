//
//  DesignTokens.swift
//  WalletApp
//
//  Created by Stephano Portella on 10/08/25.
//

import SwiftUI

enum ColorTokens {
    // Gradiente del header.
    static let gTop = Color(hex: 0x39389D)
    static let gMidHi = Color(hex: 0x5755D4)
    static let gMidLo = Color(hex: 0x7F67D4)
    static let gBottom = Color(hex: 0xD9D2ED)

    // Superficies.
    static let bg = Color(hex: 0x0F1216)
    static let surface = Color(hex: 0x1B2027)
    static let surfaceAlt = Color(hex: 0x2B3139)
    static let stroke = Color.white.opacity(0.10)
    static let strokeThin = Color.white.opacity(0.08)

    // Texto.
    static let textPrimary = Color(hex: 0xF5F7FA)
    static let textSecondary = Color(hex: 0xBFC6D1)
    static let textTertiary = Color(hex: 0x8A90A2)

    // Estado.
    static let positive = Color(hex: 0x31D07E)
    static let negative = Color(hex: 0xFF4D5A)
}

enum SpaceTokens {
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let m: CGFloat = 12
    static let l: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
}

enum RadiusTokens {
    static let small: CGFloat = 12
    static let medium: CGFloat = 16
    static let large: CGFloat = 18
    static let card: CGFloat = 28
    static let pill: CGFloat = 20
}

enum TypoTokens {
    static let titleXL = Font.system(size: 44, weight: .bold)
    static let title = Font.system(size: 24, weight: .bold)
    static let body = Font.system(size: 15, weight: .semibold)
    static let caption = Font.system(size: 12, weight: .semibold)
    static let button = Font.system(size: 17, weight: .semibold)
}

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

struct DSCard<Content: View>: View {
    private let corner: CGFloat
    private let content: Content

    init(corner: CGFloat = RadiusTokens.card, @ViewBuilder content: () -> Content) {
        self.corner = corner
        self.content = content()
    }

    var body: some View {
        content
            .background(ColorTokens.surface)
            .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: corner, style: .continuous).stroke(ColorTokens.stroke, lineWidth: 1))
            .shadow(color: .black.opacity(0.35), radius: 24, x: 0, y: 8)
    }
}

struct TopGradientHeader<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: ColorTokens.gTop, location: 0.00),
                .init(color: ColorTokens.gMidHi, location: 0.33),
                .init(color: ColorTokens.gMidLo, location: 0.66),
                .init(color: ColorTokens.gBottom, location: 1.00)
            ]),
            startPoint: .top, endPoint: .bottom
        )
        .overlay(content)
        .clipShape(RoundedRectangle(cornerRadius: RadiusTokens.card, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: RadiusTokens.card, style: .continuous).stroke(ColorTokens.stroke, lineWidth: 1))
        .shadow(color: .black.opacity(0.35), radius: 24, x: 0, y: 8)
    }
}

struct ActionPillTile: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(ColorTokens.textPrimary)
                .frame(width: 80, height: 55)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(ColorTokens.strokeThin, lineWidth: 1))
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

struct SegmentedPill: View {
    @Binding var selection: Int
    let segments: [String]

    private static let chipHeight: CGFloat = 46
    private static let gap: CGFloat = 18
    private static let fontSize: CGFloat = 15
    private static let containerHPad: CGFloat = 12

    var body: some View {
        GeometryReader { proxy in
            let available = proxy.size.width - 2 * Self.containerHPad
            let chipWidth = max(0, floor((available - Self.gap) / 2))

            HStack(spacing: Self.gap) {
                ForEach(segments.indices, id: \.self) { index in
                    Chip(label: segments[index], selected: selection == index)
                        .frame(width: chipWidth, height: Self.chipHeight)
                        .contentShape(Capsule())
                        .onTapGesture {
                            withAnimation(.spring(response: 0.22, dampingFraction: 0.9)) {
                                selection = index
                            }
                        }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, Self.containerHPad)
        }
        .frame(height: Self.chipHeight + 12)
    }

    private struct Chip: View {
        let label: String
        let selected: Bool

        var body: some View {
            ZStack {
                Capsule()
                    .fill(selected ? Color.white : Color.clear)
                    .overlay(Capsule().stroke(selected ? Color.clear : ColorTokens.strokeThin, lineWidth: 1))
                Text(label)
                    .font(.system(size: SegmentedPill.fontSize, weight: .semibold))
                    .foregroundStyle(selected ? .black : ColorTokens.textSecondary)
            }
        }
    }
}

enum TabID: String, CaseIterable {
    case home, wallet, discover, browser
}

struct TabItemModel: Identifiable {
    let id: TabID
    let systemImage: String
    let title: String

    init(_ id: TabID, _ systemImage: String, _ title: String) {
        self.id = id
        self.systemImage = systemImage
        self.title = title
    }
}

// Dock inferior con la pestaña activa "saliendo" en una burbuja.
struct TabDockPop: View {
    @Binding var selection: TabID
    let items: [TabItemModel]

    private let barHeight: CGFloat = 78
    private let topRadius: CGFloat = 14
    private let hPad: CGFloat = 18
    private let dockFill = Color(red: 80 / 255, green: 80 / 255, blue: 80 / 255)

    @Namespace private var namespace

    var body: some View {
        GeometryReader { geo in
            let safe = geo.safeAreaInsets.bottom

            ZStack(alignment: .bottom) {
                let shape = UnevenRoundedRectangle(
                    topLeadingRadius: topRadius,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: topRadius,
                    style: .continuous
                )

                shape
                    .fill(dockFill)
                    .overlay(shape.stroke(ColorTokens.stroke, lineWidth: 1))
                    .frame(height: barHeight + safe)
                    .ignoresSafeArea(edges: .bottom)

                HStack {
                    ForEach(items) { item in
                        DockItem(item: item, selected: selection == item.id, namespace: namespace, tint: dockFill)
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.spring(response: 0.30, dampingFraction: 0.86)) {
                                    selection = item.id
                                }
                            }
                    }
                }
                .padding(.horizontal, hPad)
                .padding(.bottom, max(safe * 0.35, 8))
                .frame(height: barHeight + safe, alignment: .bottom)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }

    private struct DockItem: View {
        let item: TabItemModel
        let selected: Bool
        let namespace: Namespace.ID
        let tint: Color

        private let bubbleDiameter: CGFloat = 54
        private let rise: CGFloat = 4
        private let iconSize: CGFloat = 20

        var body: some View {
            VStack(spacing: 6) {
                ZStack {
                    if selected {
                        ZStack {
                            Circle().fill(Color.white)
                            Circle().stroke(tint, lineWidth: 5)
                        }
                        .frame(width: bubbleDiameter, height: bubbleDiameter)
                        .matchedGeometryEffect(id: "bubble", in: namespace)
                        .offset(y: -rise)
                        .zIndex(1)
                    }

                    Image(systemName: item.systemImage)
                        .font(.system(size: iconSize, weight: .semibold))
                        .foregroundStyle(selected ? .black : ColorTokens.textPrimary)
                        .offset(y: selected ? -rise : -1)
                        .zIndex(2)
                }
                .frame(height: bubbleDiameter)

                Text(item.title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(selected ? .white.opacity(0.95) : ColorTokens.textSecondary)
                    .offset(y: -8)
            }
        }
    }
}
