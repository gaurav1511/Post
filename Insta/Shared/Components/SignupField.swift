import SwiftUI

/// A labeled input field with a leading icon and optional trailing accessory,
/// matching the auth form field styling.
struct SignupField<Trailing: View>: View {
    let label: String
    let systemIcon: String
    var placeholder: String = ""
    @Binding var text: String
    var borderColor: Color = .grainBorder
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    @ViewBuilder var trailing: () -> Trailing

    init(
        label: String,
        systemIcon: String,
        placeholder: String = "",
        text: Binding<String>,
        borderColor: Color = .grainBorder,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default,
        @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }
    ) {
        self.label = label
        self.systemIcon = systemIcon
        self.placeholder = placeholder
        self._text = text
        self.borderColor = borderColor
        self.isSecure = isSecure
        self.keyboardType = keyboardType
        self.trailing = trailing
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.grainLabel)

            HStack(spacing: 12) {
                Image(systemName: systemIcon)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.grainTextMuted)
                    .frame(width: 20)

                Group {
                    if isSecure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .font(.system(size: 14))
                .foregroundStyle(Color.grainTextPrimary)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(keyboardType)

                trailing()
            }
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(Color.grainField, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(borderColor, lineWidth: 1)
            )
        }
    }
}
