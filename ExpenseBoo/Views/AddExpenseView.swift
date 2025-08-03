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
                Section(header: Text("Expense Details")) {
                    HStack {
                        Text(dataManager.currencySymbol)
                            .foregroundColor(.secondary)
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                        // Handle decimal separator differences (comma vs period)
                        amount = amount.replacingOccurrences(of: ",", with: ".")
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
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveExpense()
                    }
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