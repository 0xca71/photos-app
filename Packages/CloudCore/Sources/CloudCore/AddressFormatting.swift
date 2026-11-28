import Foundation

/// Formats a server-provided detailed address for the location section of the viewer.
public enum AddressFormatting {
    /// Removes only the country, state and city parts already shown by the panel, in order.
    /// Matching stops at the first differing part so a repeated place name in the street text is kept.
    public static func detailedAddressRemainder(
        country: String?,
        state: String?,
        city: String?,
        formattedAddress: String?
    ) -> String {
        var remainder = formattedAddress?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        for value in [country, state, city] {
            for part in value?.split(whereSeparator: { $0.isWhitespace }) ?? [] {
                let prefix = String(part)
                guard remainder.hasPrefix(prefix) else { return remainder }
                remainder.removeFirst(prefix.count)
                remainder = remainder.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }

        return remainder
    }
}
