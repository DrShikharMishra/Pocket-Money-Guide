import SwiftUI
import SwiftData

struct BudgetsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Budget.category) private var budgets: [Budget]
    @Query private var transactions: [Transaction]
    
    @State private var showingAddBudget = false
    
    var body: some View {
        List {
            ForEach(budgets) { budget in
                BudgetRow(budget: budget, spent: spent(for: budget))
            }
            .onDelete(perform: deleteBudgets)
        }
        .navigationTitle("Budgets")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddBudget = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
        }
        .sheet(isPresented: $showingAddBudget) {
            AddBudgetView()
        }
        .overlay {
            if budgets.isEmpty {
                ContentUnavailableView(
                    "No Budgets Yet",
                    systemImage: "chart.pie",
                    description: Text("Create a budget to track spending against limits for categories like Food, Transport, etc.")
                )
            }
        }
    }
    
    private func spent(for budget: Budget) -> Double {
        let calendar = Calendar.current
        let now = Date()
        
        return transactions
            .filter { $0.isExpense && $0.category == budget.category }
            .filter { tx in
                switch budget.period {
                case "Weekly":
                    return calendar.isDate(tx.date, equalTo: now, toGranularity: .weekOfYear)
                case "Yearly":
                    return calendar.isDate(tx.date, equalTo: now, toGranularity: .year)
                default: // Monthly
                    return calendar.isDate(tx.date, equalTo: now, toGranularity: .month)
                }
            }
            .reduce(0) { $0 + $1.amount }
    }
    
    private func deleteBudgets(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(budgets[index])
        }
    }
}

struct BudgetRow: View {
    let budget: Budget
    let spent: Double
    
    private var progress: Double {
        min(spent / max(budget.limit, 1), 1.0)
    }
    
    private var remaining: Double {
        max(budget.limit - spent, 0)
    }
    
    private var isOver: Bool {
        spent > budget.limit
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(budget.category)
                    .font(.headline)
                Spacer()
                Text(budget.period)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            ProgressView(value: progress)
                .tint(isOver ? .red : (progress > 0.8 ? .orange : .blue))
            
            HStack {
                Text("Spent \(CurrencyHelper.format(spent))")
                    .font(.subheadline)
                    .foregroundStyle(isOver ? .red : .primary)
                
                Spacer()
                
                if isOver {
                    Text("Over by \(CurrencyHelper.format(spent - budget.limit))")
                        .font(.subheadline)
                        .foregroundStyle(.red)
                } else {
                    Text("\(CurrencyHelper.format(remaining)) left")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Text("Limit: \(CurrencyHelper.format(budget.limit))")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 6)
    }
}

struct AddBudgetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var category: String = "Food"
    @State private var limit: String = ""
    @State private var period: String = "Monthly"
    
    private let categories = [
        "Food", "Transport", "Clothing", "Utilities",
        "Entertainment", "Health", "Housing", "Transfer", "Other"
    ]
    
    private let periods = ["Weekly", "Monthly", "Yearly"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Budget Details") {
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { Text($0) }
                    }
                    
                    TextField("Limit Amount", text: $limit)
                        .keyboardType(.decimalPad)
                    
                    Picker("Period", selection: $period) {
                        ForEach(periods, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("New Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
    private var isValid: Bool {
        guard let value = Double(limit), value > 0 else { return false }
        return true
    }
    
    private func save() {
        guard let value = Double(limit), value > 0 else { return }
        let budget = Budget(category: category, limit: value, period: period)
        modelContext.insert(budget)
        dismiss()
    }
}

#Preview {
    BudgetsView()
        .modelContainer(for: [Transaction.self, Budget.self], inMemory: true)
}
