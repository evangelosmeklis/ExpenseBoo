import SwiftUI

struct AddIncomeView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var amount: String = ""
    @State private var selectedDate = Date()
    @State private var isMonthly = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Income Details")) {
                    HStack {
                        Text(dataManager.currencySymbol)
                            .foregroundColor(.secondary)
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .onChange(of: amount) { newValue in
                                // Clean and format the input to handle decimals properly
                                let filtered = newValue.replacingOccurrences(of: ",", with: ".")
                                if filtered != amount {
                                    amount = filtered
                                }
                            }
                    }
                    
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                    
                    Toggle("Monthly Income", isOn: $isMonthly)
                }
                
                if !isMonthly {
                    Section(footer: Text("One-time income will not reset with your monthly cycle")) {
                        EmptyView()
                    }
                }
            }
            .navigationTitle("Add Income")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveIncome()
                    }
                    .disabled(amount.isEmpty)
                }
            }
        }
    }
    
    private func saveIncome() {
        guard let amountValue = Double(amount) else { return }
        
        let income = Income(
            amount: amountValue,
            date: selectedDate,
            isMonthly: isMonthly
        )
        
        dataManager.addIncome(income)
        dismiss()
    }
}

#Preview {
    AddIncomeView()
        .environmentObject(DataManager())
}