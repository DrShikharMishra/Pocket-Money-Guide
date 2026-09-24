# Pocket Money Guide

A beautiful, offline-first personal finance tracker built with **SwiftUI** + **SwiftData**.

100% private — no bank sync, no cloud, no tracking. Perfect for managing your daily expenses and income.

## Features

### Fully Implemented
- **Overview Dashboard** with Summary / Last 7 Days / This Month / Current Year cards
- **Manual Transaction Entry** (Expense & Income)
- **Edit & Delete** transactions (tap any row)
- **Budgets** with progress bars and overspend warnings
- **Reports** with interactive donut chart + period filter
- **Proper Indian Rupee formatting** (`₹1,00,000.00` style)
- Sample data button for instant demo
- Clean sidebar navigation

### Coming Later
- Accounts screen
- Goals / Savings targets
- Widgets

## Tech Stack

| Layer          | Technology              |
|----------------|-------------------------|
| Language       | Swift 5.9+              |
| UI             | SwiftUI                 |
| Persistence    | SwiftData               |
| Charts         | Swift Charts            |
| Minimum iOS    | iOS 17                  |
| IDE            | Xcode 15+               |

## Project Structure

```
Pocket-Money-Guide/
├── PocketMoneyGuideApp.swift      ← App entry point
├── ContentView.swift
├── Models/
│   ├── Transaction.swift
│   └── Budget.swift
├── Views/
│   ├── OverviewView.swift
│   ├── TransactionListView.swift  ← Add + Edit
│   ├── ReportsView.swift
│   └── BudgetsView.swift
├── Helpers/
│   └── CurrencyHelper.swift
├── .gitignore
└── README.md
```

## Quick Start

1. **Clone**
   ```bash
   git clone https://github.com/DrShikharMishra/Pocket-Money-Guide.git
   cd Pocket-Money-Guide
   ```

2. **Create Xcode Project**
   - Open Xcode → Create New Project → iOS → App
   - Product Name: `PocketMoneyGuide` (or any name you like)
   - Interface: **SwiftUI**
   - Storage: **SwiftData**
   - Language: **Swift**

3. **Add the files**
   - Delete the default `ContentView.swift` and any `Item.swift` that Xcode generates
   - Drag all the Swift files from this repo into your Xcode project
   - Make sure `PocketMoneyGuideApp.swift` is the `@main` entry point (rename if needed)

4. **Run**
   - Choose an iPad or iPhone simulator
   - Press `⌘R`
   - Go to **Overview** → tap **Add Sample Data** in the toolbar

## How to Use

1. **Overview** – See your financial health at a glance
2. **Transactions** – Add, edit (tap a row), or swipe to delete
3. **Budgets** – Set monthly/weekly/yearly limits per category
4. **Reports** – Explore spending with the donut chart

## License

MIT — free to use and modify.

---

Built for privacy, speed, and the Indian Rupee 🇮🇳
