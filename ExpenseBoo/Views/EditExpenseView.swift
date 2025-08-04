import SwiftUI

struct EditExpenseView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    let expense: Expense
    @State private var amount: String = ""
    @State private var comment: String = ""
    @State private var selectedCategory: Category?
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Expense Details")) {
                    HStack {
                        Text(dataManager.currencySymbol)
                            .foregroundColor(.secondary)
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .onChange(of: amount) { oldValue, newValue in
                                let filtered = newValue.replacingOccurrences(of: ",", with: ".")
                                if filtered != amount {
                                    amount = filtered
                                }
                            }
                    }
                    
                    TextField("What did you buy?", text: $comment)
                    
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                }
                
                Section(header: Text("Category")) {
                    if dataManager.categories.isEmpty {
                        Text("No categories available")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(dataManager.categories) { category in
                            HStack {
                                Circle()
                                    .fill(category.color)
                                    .frame(width: 12, height: 12)
                                
                                Text(category.name)
                                
                                Spacer()
                                
                                if selectedCategory?.id == category.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedCategory = category
                            }
                        }
                    }
                }
                
                Section {
                    Button("Delete Expense", role: .destructive) {
                        dataManager.deleteExpense(expense)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Edit Expense")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                amount = String(expense.amount)
                comment = expense.comment
                selectedDate = expense.date
                selectedCategory = dataManager.getCategoryById(expense.categoryId)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(amount.isEmpty || comment.isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        guard let amountValue = Double(amount) else { return }
        
        var updatedExpense = expense
        updatedExpense.amount = amountValue
        updatedExpense.comment = comment
        updatedExpense.date = selectedDate
        updatedExpense.categoryId = selectedCategory?.id
        
        dataManager.updateExpense(updatedExpense)
        dismiss()
    }
}

#Preview {
    EditExpenseView(expense: Expense(amount: 25.50, comment: "Lunch", categoryId: nil))
        .environmentObject(DataManager())
}