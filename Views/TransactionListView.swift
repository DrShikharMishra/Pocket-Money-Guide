import SwiftUI
import SwiftData

struct TransactionListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    
    @State private var showingAddSheet = false
    @State private var transactionToEdit: Transaction?
    
    var body: some View {
        List {
            ForEach(transactions) { transaction in
                Button {
                    transactionToEdit = transaction
                } label: {
                    TransactionRow(transaction: transaction)
                }
                .buttonStyle(.plain)
            }
            .onDelete(perform: deleteItems)
        }
        .navigationTitle("Transactions")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddTransactionView()
        }
        .sheet(item: $transactionToEdit) { transaction in
            EditTransactionView(transaction: transaction)
        }
        .overlay {
            if transactions.isEmpty {
                ContentUnavailableView(
                    "No Transactions Yet",
                    systemImage: "list.bullet.rectangle",
                    description: Text("Tap the + button to add your first transaction, or go to Overview and add sample data.")
                )
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(transactions[index])
        }
    }
}

// MARK: - Row

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconForCategory(transaction.category))
                .foregroundStyle(.blue)
                .frame(width: 36, height: 36)
                .background(Color.blue.opacity(0.15))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.category)
                    .font(.headline)
                
                if !transaction.note.isEmpty {
                    Text(transaction.note)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            
            Spacer()
            
            Text(CurrencyHelper.formatSigned(transaction.amount, isExpense: transaction.isExpense))
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(transaction.isExpense ? .red : .green)
        }
        .padding(.vertical, 4)
    }
    
    private func iconForCategory(_ category: String) -> String {
        switch category.lowercased() {
        case "food": return "fork.knife"
        case "transport": return "car"
        case "clothing": return "tshirt"
        case "utilities": return "bolt"
        case "entertainment": return "tv"
        case "health": return "heart"
        case "housing": return "house"
        case "transfer": return "arrow.left.arrow.right"
        case "salary": return "banknote"
        default: return "tag"
        }
    }
}

// MARK: - Add Transaction

struct AddTransactionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var amount: String = ""
    @State private var category: String = "Food"
    @State private var note: String = ""
    @State private var isExpense: Bool = true
    @State private var date: Date = Date()
    
    private let categories = [
        "Food", "Transport", "Clothing", "Utilities",
        "Entertainment", "Health", "Housing", "Transfer",
        "Salary", "Other"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Transaction Type") {
                    Picker("Type", selection: $isExpense) {
                        Text("Expense").tag(true)
                        Text("Income").tag(false)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Details") {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { Text($0) }
                    }
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    TextField("Note (Optional)", text: $note)
                }
            }
            .navigationTitle("Add Transaction")
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
        guard let value = Double(amount), value > 0 else { return false }
        return true
    }
    
    private func save() {
        guard let value = Double(amount), value > 0 else { return }
        let tx = Transaction(
            amount: value,
            category: category,
            note: note,
            date: date,
            isExpense: isExpense
        )
        modelContext.insert(tx)
        dismiss()
    }
}

// MARK: - Edit Transaction

struct EditTransactionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var transaction: Transaction
    
    @State private var amount: String = ""
    @State private var category: String = ""
    @State private var note: String = ""
    @State private var isExpense: Bool = true
    @State private var date: Date = Date()
    
    private let categories = [
        "Food", "Transport", "Clothing", "Utilities",
        "Entertainment", "Health", "Housing", "Transfer",
        "Salary", "Other"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Transaction Type") {
                    Picker("Type", selection: $isExpense) {
                        Text("Expense").tag(true)
                        Text("Income").tag(false)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Details") {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { Text($0) }
                    }
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    TextField("Note (Optional)", text: $note)
                }
                
                Section {
                    Button("Delete Transaction", role: .destructive) {
                        modelContext.delete(transaction)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Edit Transaction")
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
            .onAppear {
                amount = String(format: "%.2f", transaction.amount)
                category = transaction.category
                note = transaction.note
                isExpense = transaction.isExpense
                date = transaction.date
            }
        }
    }
    
    private var isValid: Bool {
        guard let value = Double(amount), value > 0 else { return false }
        return true
    }
    
    private func save() {
        guard let value = Double(amount), value > 0 else { return }
        transaction.amount = value
        transaction.category = category
        transaction.note = note
        transaction.isExpense = isExpense
        transaction.date = date
        dismiss()
    }
}

#Preview {
    TransactionListView()
        .modelContainer(for: [Transaction.self, Budget.self], inMemory: true)
}
