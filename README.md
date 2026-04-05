# 💰 SaveWise

A personal finance tracker built with Flutter. Track your income and expenses, set a savings goal, and understand your spending habits — all stored locally on your device, no account needed.

---

## 📲 How to run

**You need Flutter 3.0+** installed. 


cd saveWise
flutter pub get
flutter run


That's it. No backend. No API keys. No internet connection needed. Everything saves directly on the device.


---

## 📱 What's in the app

The app has 5 tabs at the bottom.

### 🏠 Home
Your financial snapshot at a glance.
- Big balance card at the top (income minus all expenses)
- Two pills showing total income and total expenses
- Your savings goal progress bar
- A donut chart breaking down spending by category
- Your last 5 transactions

### 🧾 Transactions
Every transaction you've ever added, in one list.
- Filter by **All / Income / Expense** using the chips at the top
- **Swipe left** on any transaction to delete it
- **Tap** any transaction to edit it
- Tap the **+** icon in the top right (or the floating button) to add a new one

### 🎯 Goal
Your monthly savings goal.
- Shows how much you've saved vs your target, as a progress bar
- Shows days remaining until your deadline
- Calculates your **daily savings target** (remaining amount ÷ days left)
- Tap the edit icon in the top right to change the goal title, target amount, or deadline
- Once your balance reaches the target, it shows ✅ Done

### 📊 Insights
Understand where your money goes.
- **Weekly comparison** — this week's spending vs last week, with a trend arrow
- **6-month bar chart** — monthly expense totals for the past 6 months
- **Top spending categories** — ranked list with progress bars showing proportion

### 👤 Profile & Settings
- Edit your display name
- Toggle **dark mode** (switches the entire app instantly)
- **Export to CSV** — saves all your transactions as a `.csv` file to Downloads (Android) or opens the share sheet (iOS)
- **Clear All Data** — deletes all transactions and your goal, but keeps your name and dark mode setting
- **Log Out** — wipes everything and resets the app to a fresh state

---

## ➕ Adding a transaction

1. Tap the purple **+** floating button on Home or Transactions
2. Choose **Expense** or **Income** using the toggle at the top
3. Enter the amount
4. Pick a category (Food, Transport, Shopping, Health, etc.)
5. Select the date (defaults to today)
6. Optionally add a note
7. Tap **Add Transaction**

The balance, charts, and goal progress all update immediately.

---

## 🏗 How the app is structured

The app is split into 4 clear layers. Each layer only talks to the one directly below it — never skips.

```
┌──────────────────────────────────┐
│         Screens (UI)             │  Shows data. Sends user actions.
├──────────────────────────────────┤
│           BLoC                   │  Receives actions. Runs logic. Updates UI.
├──────────────────────────────────┤
│        Repositories              │  Business rules. Talks to storage.
├──────────────────────────────────┤
│       LocalDataSource            │  SharedPreferences. JSON in, JSON out.
└──────────────────────────────────┘
```

**Screens** never read from storage directly. They fire an event → BLoC handles it → BLoC emits a new state → screen rebuilds. That's the entire flow for every user interaction.

### The BLoC flow, step by step

```
User taps "Add Transaction"
       ↓
Screen:   context.read<TransactionBloc>().add(AddTransaction(tx))
       ↓
BLoC:     receives AddTransaction event
          calls _repo.add(tx)          ← saves to SharedPreferences
          reloads full list from disk
          calls emit(newState)         ← announces "data changed"
       ↓
BlocBuilder detects new state
       ↓
Screen rebuilds showing the new transaction
```

There are 4 BLoCs, one per feature area:

| BLoC | Owns |
|---|---|
| `TransactionBloc` | All transaction data, totals, balance, active filter |
| `GoalBloc` | The savings goal — load, update, sync with balance |
| `InsightsBloc` | Chart data — weekly comparison, monthly trend, category breakdown |
| `ProfileBloc` | Name, dark mode preference, clear data, logout |

---

## 💾 Data storage

Everything is stored locally using **SharedPreferences** as JSON strings. There are 4 keys:

| Key | What's stored |
|---|---|
| `transactions_v1` | JSON array of all transactions |
| `goal_v1` | JSON object with goal title, target, current amount, deadline |
| `profile_username` | Your display name string |
| `profile_darkmode` | Boolean for dark mode |

No data ever leaves the device. No network requests are made anywhere in the app.

---



## 📦 Dependencies

| Package | What it does |
|---|---|
| `flutter_bloc` | BLoC state management |
| `equatable` | Value equality for BLoC states (prevents unnecessary UI rebuilds) |
| `shared_preferences` | Local key-value storage |
| `fl_chart` | Pie chart and bar chart |
| `uuid` | Generates unique IDs for each transaction |
| `intl` | Date and currency formatting |
| `path_provider` | Gets the device Downloads/Documents folder path for CSV export |
| `share_plus` | iOS share sheet for exporting the CSV file |

---
