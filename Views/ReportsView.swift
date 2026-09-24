import SwiftUI
import SwiftData
import Charts

struct ReportsView: View {
    @Query private var transactions: [Transaction]
    
    @State private var selectedPeriod: Period = .thisMonth
    
    enum Period: String, CaseIterable, Identifiable {
        case thisMonth = "This Month"
        case lastMonth = "Last Month"
        case thisYear = "This Year"
        case allTime = "All Time"
        
        var id: String { rawValue }
    }
    
    private var filteredTransactions: [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedPeriod {
        case .thisMonth:
            return transactions.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
        case .lastMonth:
            guard let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) else { return [] }
            return transactions.filter { calendar.isDate($0.date, equalTo: lastMonth, toGranularity: .month) }
        case .thisYear:
            return transactions.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .year) }
        case .allTime:
            return transactions
        }
    }
    
    private var categoryData: [(category: String, amount: Double)] {
        let expenses = filteredTransactions.filter { $0.isExpense }
        let grouped = Dictionary(grouping: expenses, by: { $0.category })
        return grouped
            .map { (category: $0.key, amount: $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.amount > $1.amount }
    }
    
    private var totalExpense: Double {
        categoryData.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Period Picker
                Picker("Period", selection: $selectedPeriod) {
                    ForEach(Period.allCases) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                Text("Top Categories")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                if categoryData.isEmpty {
                    ContentUnavailableView(
                        "No expense data",
                        systemImage: "chart.pie",
                        description: Text("Add some expense transactions to see the breakdown.")
                    )
                    .frame(height: 280)
                } else {
                    // Donut Chart
                    Chart(categoryData, id: \.category) { item in
                        SectorMark(
                            angle: .value("Amount", item.amount),
                            innerRadius: .ratio(0.62),
                            angularInset: 1.5
                        )
                        .cornerRadius(5)
                        .foregroundStyle(by: .value("Category", item.category))
                    }
                    .frame(height: 280)
                    .padding(.horizontal)
                    
                    // Total
                    Text("Total Expense: \(CurrencyHelper.format(totalExpense))")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    // Legend
                    VStack(spacing: 0) {
                        ForEach(Array(categoryData.enumerated()), id: \.element.category) { index, item in
                            HStack {
                                Circle()
                                    .fill(colorForIndex(index))
                                    .frame(width: 10, height: 10)
                                
                                Text(item.category)
                                
                                Spacer()
                                
                                Text(CurrencyHelper.format(item.amount))
                                
                                Text("\(percentage(item.amount))%")
                                    .foregroundStyle(.secondary)
                                    .frame(width: 40, alignment: .trailing)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal)
                            
                            if index < categoryData.count - 1 {
                                Divider().padding(.leading, 28)
                            }
                        }
                    }
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Reports")
    }
    
    private func percentage(_ amount: Double) -> Int {
        guard totalExpense > 0 else { return 0 }
        return Int((amount / totalExpense) * 100)
    }
    
    private func colorForIndex(_ index: Int) -> Color {
        let colors: [Color] = [.pink, .blue, .orange, .purple, .green, .cyan, .mint, .indigo, .teal, .yellow]
        return colors[index % colors.count]
    }
}

#Preview {
    ReportsView()
        .modelContainer(for: [Transaction.self, Budget.self], inMemory: true)
}
