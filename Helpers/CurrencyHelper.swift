import Foundation

enum CurrencyHelper {
    /// Indian Rupee formatter that produces ₹1,00,000 style grouping
    static let inrFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "INR"
        formatter.currencySymbol = "₹"
        formatter.locale = Locale(identifier: "en_IN")
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }()
    
    static func format(_ amount: Double) -> String {
        inrFormatter.string(from: NSNumber(value: amount)) ?? "₹\(String(format: "%.2f", amount))"
    }
    
    /// Signed version: -₹1,234.56 or +₹1,234.56
    static func formatSigned(_ amount: Double, isExpense: Bool) -> String {
        let prefix = isExpense ? "-" : "+"
        return prefix + format(amount)
    }
}
