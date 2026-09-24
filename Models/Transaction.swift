import Foundation
import SwiftData

@Model
class Transaction {
    var id: UUID
    var amount: Double
    var category: String
    var note: String
    var date: Date
    var isExpense: Bool   // true = Expense, false = Income
    
    init(
        amount: Double,
        category: String,
        note: String = "",
        date: Date = Date(),
        isExpense: Bool
    ) {
        self.id = UUID()
        self.amount = amount
        self.category = category
        self.note = note
        self.date = date
        self.isExpense = isExpense
    }
}
