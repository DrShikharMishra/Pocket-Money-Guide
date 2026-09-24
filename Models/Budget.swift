import Foundation
import SwiftData

@Model
class Budget {
    var id: UUID
    var category: String
    var limit: Double
    var period: String   // "Monthly", "Weekly", "Yearly"
    
    init(category: String, limit: Double, period: String = "Monthly") {
        self.id = UUID()
        self.category = category
        self.limit = limit
        self.period = period
    }
}
