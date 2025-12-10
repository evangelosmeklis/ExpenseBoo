import SwiftUI

struct EditExpenseView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    let expense: Expense
    @State private var amount: String = ""
    @State private var comment: String = ""
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(">> EXPENSE_DETAILS")
                    .font(AppTheme.Fonts.caption(11))
                    .foregroundColor(AppTheme.Colors.electricCyan)
                    .tracking(2)) {
                    HStack {
                        Text(dataManager.currencySymbol)
                            .font(AppTheme.Fonts.body())
                            .foregroundColor(AppTheme.Colors.electricCyan.opacity(0.7))
                        TextField("0.00", text: $amount)
                            .font(AppTheme.Fonts.body())
                            .foregroundColor(AppTheme.Colors.primaryText)
                            .keyboardType(.decimalPad)
                            .onChange(of: amount) { oldValue, newValue in
                                let filtered = newValue.replacingOccurrences(of: ",", with: ".")
                                if filtered != amount {
                                    amount = filtered
                                }
                            }
                    }
                    .listRowBackground(AppTheme.Colors.cardBackground)

                    TextField("What did you buy?", text: $comment)
                        .font(AppTheme.Fonts.body())
                        .foregroundColor(AppTheme.Colors.primaryText)
                        .listRowBackground(AppTheme.Colors.cardBackground)

                    DatePicker("Date & Time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                        .font(AppTheme.Fonts.body())
                        .foregroundColor(AppTheme.Colors.primaryText)
                        .accentColor(AppTheme.Colors.electricCyan)
                        .listRowBackground(AppTheme.Colors.cardBackground)
                }
                
                Section {
                    Button("Delete Expense", role: .destructive) {
                        dataManager.deleteExpense(expense)
                        dismiss()
                    }
                    .font(AppTheme.Fonts.body())
                    .listRowBackground(AppTheme.Colors.cardBackground)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.Colors.primaryBackground)
            .navigationTitle("Edit Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(">> EDIT_EXPENSE")
                        .font(AppTheme.Fonts.headline(16))
                        .foregroundColor(AppTheme.Colors.expense)
                        .tracking(2)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("CANCEL") {
                        dismiss()
                    }
                    .font(AppTheme.Fonts.caption(11))
                    .foregroundColor(AppTheme.Colors.electricCyan)
                    .tracking(1)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("SAVE") {
                        saveChanges()
                    }
                    .font(AppTheme.Fonts.caption(11))
                    .foregroundColor(amount.isEmpty || comment.isEmpty ? AppTheme.Colors.electricCyan.opacity(0.3) : AppTheme.Colors.neonGreen)
                    .tracking(1)
                    .disabled(amount.isEmpty || comment.isEmpty)
                }
            }
            .onAppear {
                amount = String(expense.amount)
                comment = expense.comment
                selectedDate = expense.date
            }
        }
    }
    
    private func saveChanges() {
        guard let amountValue = Double(amount) else { return }
        
        var updatedExpense = expense
        updatedExpense.amount = amountValue
        updatedExpense.comment = comment
        updatedExpense.date = selectedDate
        updatedExpense.categoryId = nil
        
        dataManager.updateExpense(updatedExpense)
        dismiss()
    }
}

#Preview {
    EditExpenseView(expense: Expense(amount: 25.50, comment: "Lunch", categoryId: nil))
        .environmentObject(DataManager())
}