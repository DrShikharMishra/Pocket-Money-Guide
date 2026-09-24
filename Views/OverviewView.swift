import SwiftUI
import SwiftData

struct OverviewView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    
    @State private var showingAddSheet = false
    
    // MARK: - Computed Periods
    
    private var calendar: Calendar { Calendar.current }
    
    private var thisMonthTransactions: [Transaction] {
        transactions.filter { calendar.isDate($0.date, equalTo: Date(), toGranularity: .month) }
    }
    
    private var last7DaysTransactions: [Transaction] {
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return transactions.filter { $0.date >= sevenDaysAgo }
    }
    
    private var thisYearTransactions: [Transaction] {
        transactions.filter { calendar.isDate($0.date, equalTo: Date(), toGranularity: .year) }
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Paycheck / Next period teaser (decorative)
                PaycheckTeaserCard()
                
                // Main Summary (This Month)
                PeriodSummaryCard(
                    title: "Summary",
                    subtitle: monthYearString(Date()),
                    transactions: thisMonthTransactions,
                    badge: "Positive"
                )
                
                // Last 7 Days
                PeriodSummaryCard(
                    title: "Last 7 Days",
                    subtitle: dateRangeString(days: 7),
                    transactions: last7DaysTransactions,
                    badge: nil
                )
                
                // This Month (explicit)
                PeriodSummaryCard(
                    title: "This Month",
                    subtitle: monthYearString(Date()),
                    transactions: thisMonthTransactions,
                    badge: "Positive"
                )
                
                // Current Year
                PeriodSummaryCard(
                    title: "Current Year",
                    subtitle: yearString(Date()),
                    transactions: thisYearTransactions,
                    badge: "Positive"
                )
            }
            .padding()
        }
        .navigationTitle("Overview")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
            
            ToolbarItem(placement: .secondaryAction) {
                Button("Add Sample Data") {
                    addSampleData()
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddTransactionView()
        }
    }
    
    // MARK: - Helpers
    
    private func monthYearString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func yearString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }
    
    private func dateRangeString(days: Int) -> String {
        let end = Date()
        let start = calendar.date(byAdding: .day, value: -days, to: end) ?? end
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
    
    private func addSampleData() {
        let samples: [(Double, String, String, Bool, Int)] = [
            (1850.00, "Salary", "Monthly salary", false, -2),
            (420.50, "Food", "Swiggy order", true, -1),
            (1200.00, "Housing", "Rent contribution", true, -5),
            (350.00, "Transport", "Uber & metro", true, -3),
            (899.00, "Entertainment", "Netflix + Spotify", true, -10),
            (2500.00, "Transfer", "To savings", true, -8),
            (150.75, "Food", "Cafe", true, -2),
            (5000.00, "Salary", "Freelance", false, -15),
            (680.00, "Utilities", "Electricity bill", true, -12),
            (320.00, "Health", "Pharmacy", true, -4)
        ]
        
        for (amount, category, note, isExpense, daysAgo) in samples {
            let date = calendar.date(byAdding: .day, value: daysAgo, to: Date()) ?? Date()
            let tx = Transaction(amount: amount, category: category, note: note, date: date, isExpense: isExpense)
            modelContext.insert(tx)
        }
    }
}

// MARK: - Period Summary Card

struct PeriodSummaryCard: View {
    let title: String
    let subtitle: String
    let transactions: [Transaction]
    let badge: String?
    
    private var income: Double {
        transactions.filter { !$0.isExpense }.reduce(0) { $0 + $1.amount }
    }
    
    private var expense: Double {
        transactions.filter { $0.isExpense }.reduce(0) { $0 + $1.amount }
    }
    
    private var net: Double { income - expense }
    
    private var percentLeft: Int {
        guard income > 0 else { return 0 }
        return Int(((income - expense) / income) * 100)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                Text(title)
                    .font(.title3.bold())
                
                if let badge {
                    Text(badge)
                        .font(.caption2.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.green.opacity(0.2))
                        .foregroundStyle(.green)
                        .clipShape(Capsule())
                }
                
                Spacer()
            }
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            // Big Net Number
            Text(CurrencyHelper.format(net))
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(net >= 0 ? .green : .red)
            
            // Expense / Income row
            HStack(spacing: 20) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundStyle(.red)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Expense")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(CurrencyHelper.formatSigned(expense, isExpense: true))
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(.red)
                    }
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundStyle(.green)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Income")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(CurrencyHelper.formatSigned(income, isExpense: false))
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(.green)
                    }
                }
                
                Spacer()
            }
            
            // Footer insight
            if income > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("\(percentLeft)% of income left after spending")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else if expense > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(.orange)
                    Text("No income recorded in this period")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Decorative Paycheck Card

struct PaycheckTeaserCard: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(0..<8) { i in
                        Circle()
                            .fill(i < 5 ? Color.blue : Color.blue.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                Text("Less than a week until your next paycheck arrives.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.3), lineWidth: 6)
                    .frame(width: 56, height: 56)
                Circle()
                    .trim(from: 0, to: 0.72)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 56, height: 56)
                    .rotationEffect(.degrees(-90))
                Text("DAYS")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.blue)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    OverviewView()
        .modelContainer(for: [Transaction.self, Budget.self], inMemory: true)
}
