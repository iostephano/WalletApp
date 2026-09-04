//
//  PrimaryCTA.swift
//  WalletApp
//
//  Created by Stephano Portella on 10/08/25.
//

import SwiftUI

struct PrimaryCTA: View {
    private let title: String
    private let enabled: Bool
    private let action: () -> Void

    init(_ title: String, enabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.enabled = enabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .opacity(enabled ? 1 : 0.5)
        }
        .disabled(!enabled)
        .buttonStyle(.plain)
    }
}
