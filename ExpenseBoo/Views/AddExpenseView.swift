import SwiftUI

struct AddExpenseView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var amount: String = ""
    @State private var comment: String = ""
    @State private var selectedCategory: Category?
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
                            .keyboardType(.decimalPad)
                            .onChange(of: amount) { oldValue, newValue in
                                // Clean and format the input to handle decimals properly
                                let filtered = newValue.replacingOccurrences(of: ",", with: ".")
                                if filtered != amount {
                                    amount = filtered
                                }
                            }
                    }
                    .listRowBackground(AppTheme.Colors.cardBackground)
                    
                    TextField("What did you buy?", text: $comment)
                        .font(AppTheme.Fonts.body())
                        .listRowBackground(AppTheme.Colors.cardBackground)
                    
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                        .font(AppTheme.Fonts.body())
                        .accentColor(AppTheme.Colors.electricCyan)
                        .listRowBackground(AppTheme.Colors.cardBackground)
                }
                
                Section(header: Text(">> CATEGORY")
                    .font(AppTheme.Fonts.caption(11))
                    .foregroundColor(AppTheme.Colors.electricCyan)
                    .tracking(2)) {
                    if dataManager.categories.isEmpty {
                        Text("NO_CATEGORIES_AVAILABLE")
                            .font(AppTheme.Fonts.caption())
                            .foregroundColor(AppTheme.Colors.electricCyan.opacity(0.5))
                            .tracking(1)
                            .listRowBackground(AppTheme.Colors.cardBackground)
                    } else {
                        ForEach(dataManager.categories) { category in
                            HStack {
                                Circle()
                                    .fill(category.color)
                                    .frame(width: 12, height: 12)
                                
                                Text(category.name)
                                    .font(AppTheme.Fonts.body())
                                
                                Spacer()
                                
                                if selectedCategory?.id == category.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(AppTheme.Colors.electricCyan)
                                }
                            }
                            .contentShape(Rectangle())
                            .listRowBackground(AppTheme.Colors.cardBackground)
                            .onTapGesture {
                                selectedCategory = category
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.Colors.primaryBackground)
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(">> ADD_EXPENSE")
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
                        saveExpense()
                    }
                    .font(AppTheme.Fonts.caption(11))
                    .foregroundColor(amount.isEmpty || comment.isEmpty ? AppTheme.Colors.electricCyan.opacity(0.3) : AppTheme.Colors.neonGreen)
                    .tracking(1)
                    .disabled(amount.isEmpty || comment.isEmpty)
                }
            }
        }
    }
    
    private func saveExpense() {
        guard let amountValue = Double(amount) else { return }
        
        let expense = Expense(
            amount: amountValue,
            comment: comment,
            date: selectedDate,
            categoryId: selectedCategory?.id
        )
        
        dataManager.addExpense(expense)
        dismiss()
    }
}

#Preview {
    AddExpenseView()
        .environmentObject(DataManager())
}