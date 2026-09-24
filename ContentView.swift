import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab: String? = "Overview"
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedTab) {
                NavigationLink(value: "Overview") {
                    Label("Overview", systemImage: "doc.text")
                }
                NavigationLink(value: "Accounts") {
                    Label("Accounts", systemImage: "creditcard")
                }
                NavigationLink(value: "Budgets") {
                    Label("Budgets", systemImage: "chart.pie")
                }
                NavigationLink(value: "Transactions") {
                    Label("Transactions", systemImage: "list.bullet")
                }
                NavigationLink(value: "Reports") {
                    Label("Reports", systemImage: "chart.bar")
                }
                NavigationLink(value: "Goals") {
                    Label("Goals", systemImage: "target")
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Pocket Money Guide")
        } detail: {
            Group {
                switch selectedTab {
                case "Overview":
                    OverviewView()
                case "Transactions":
                    TransactionListView()
                case "Reports":
                    ReportsView()
                case "Budgets":
                    BudgetsView()
                case "Accounts":
                    PlaceholderView(title: "Accounts", systemImage: "creditcard", message: "Coming soon — track multiple bank accounts and cards.")
                case "Goals":
                    PlaceholderView(title: "Goals", systemImage: "target", message: "Coming soon — set savings goals and track progress.")
                default:
                    ContentUnavailableView(
                        "Select a section",
                        systemImage: "sidebar.left",
                        description: Text("Choose an item from the sidebar to get started.")
                    )
                }
            }
        }
    }
}

struct PlaceholderView: View {
    let title: String
    let systemImage: String
    let message: String
    
    var body: some View {
        ContentUnavailableView(title, systemImage: systemImage, description: Text(message))
            .navigationTitle(title)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Transaction.self, Budget.self], inMemory: true)
}
