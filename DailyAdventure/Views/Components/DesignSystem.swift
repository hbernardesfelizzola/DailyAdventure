//
//  DesignSystem.swift
//  DailyAdventure
//
//  Peças visuais compartilhadas entre as telas (introduzidas no redesign da Today).
//  Cores ficam em `Theme`; aqui ficam raios, tipografia e componentes.
//

import SwiftUI

extension Theme {
    enum Radius {
        /// Cards principais (aventura do dia, feedback, seções).
        static let card: CGFloat = 24
        /// Listas e linhas agrupadas.
        static let list: CGFloat = 20
        /// Botões grandes e campos de texto.
        static let control: CGFloat = 16
        /// Campos dentro de cards.
        static let inset: CGFloat = 14
    }
}

// MARK: - Tipografia
//
// Duas famílias, cada uma com um papel:
// - New York (serifada) é a "voz da aventura": títulos de tela, saudação, a aventura do dia e momentos emocionais.
// - SF Pro é a parte funcional: seções, listas, botões, rótulos e textos de apoio.
// As telas usam os papéis abaixo em vez de estilos soltos. Menor tamanho no app: `caption` (`caption2` só em widgets).

extension Font {
    /// Serifada do sistema (New York). Respeita Dynamic Type.
    static func serif(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        .system(style, design: .serif, weight: weight)
    }

    // Serifada — voz da aventura

    /// Título principal de uma tela ("Qual é a aventura de hoje?", "Dia completo.").
    static let screenTitle = serif(.largeTitle, weight: .bold)
    /// Título de tela quando divide espaço com outro elemento (ex.: ao lado do anel de progresso).
    static let screenTitleCompact = serif(.title, weight: .bold)
    /// Saudação acima do título ("Bom dia, Henrique.").
    static let greeting = serif(.title3)
    /// Título de card ou de página do onboarding ("Como foi esse dia?").
    static let cardTitle = serif(.title3, weight: .bold)
    /// Texto da aventura do dia em destaque.
    static let questTitle = serif(.title2, weight: .semibold)
    /// Texto da aventura do dia em tamanho reduzido (card concluído) e no campo de digitação.
    static let questTitleSmall = serif(.title3, weight: .semibold)
    static let questInput = serif(.title3)

    // SF Pro — parte funcional

    /// Título de seção ("Missões secundárias").
    static let sectionTitle = Font.title3.weight(.bold)
    /// Texto de linha de lista e campos comuns.
    static let rowText = Font.body
    /// Texto de apoio e subtítulos.
    static let supporting = Font.subheadline
    /// Rótulos pequenos em destaque (caixa alta, botões secundários).
    static let label = Font.footnote.weight(.semibold)
    /// Etiquetas curtas (categoria de uma quest).
    static let tag = Font.caption.weight(.semibold)
    /// Botões de ação principais.
    static let action = Font.headline
}

// MARK: - Superfícies

extension View {
    /// Fundo sólido de card (branco no light, azul-marinho no dark).
    func cardSurface(cornerRadius: CGFloat = Theme.Radius.card, shadow: Bool = false) -> some View {
        self
            .background(Theme.cardBackground, in: RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: shadow ? Theme.ink.opacity(0.06) : .clear, radius: 12, y: 6)
    }
}

// MARK: - Texto

/// Rótulo de seção em caixa alta (data, "Sugestões", "Categoria"…).
struct SectionLabel: View {
    let title: Text
    var color: Color = Theme.inkSecondary

    init(_ key: LocalizedStringKey, color: Color = Theme.inkSecondary) {
        self.title = Text(key)
        self.color = color
    }

    init(verbatim string: String, color: Color = Theme.inkSecondary) {
        self.title = Text(verbatim: string)
        self.color = color
    }

    var body: some View {
        title
            .font(.label)
            .textCase(.uppercase)
            .tracking(0.8)
            .foregroundStyle(color)
    }
}

// MARK: - Botões

/// Botão principal: preenchido com `accent`, largura total.
struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.action)
            .foregroundStyle(Theme.onAccent)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(
                Theme.accent.opacity(isEnabled ? (configuration.isPressed ? 0.85 : 1) : 0.4),
                in: RoundedRectangle(cornerRadius: Theme.Radius.control + 2)
            )
    }
}

/// Botão de adicionar com borda tracejada, para estados vazios.
struct DashedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.action)
            .foregroundStyle(Theme.accent)
            .frame(maxWidth: .infinity, minHeight: 52)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.control)
                    .strokeBorder(Theme.accent.opacity(0.45), style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
            )
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

/// Botão circular de 44pt sobre uma superfície de card (ex.: "+" de adicionar).
struct CircleIconButton: View {
    let systemImage: String
    let accessibilityLabel: LocalizedStringKey
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.body.weight(.semibold))
                .foregroundStyle(Theme.accent)
                .frame(width: 44, height: 44)
                .background(Theme.cardBackground, in: Circle())
        }
        .accessibilityLabel(accessibilityLabel)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

extension ButtonStyle where Self == DashedButtonStyle {
    static var dashed: DashedButtonStyle { DashedButtonStyle() }
}
