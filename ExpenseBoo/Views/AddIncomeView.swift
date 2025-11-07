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
                Section(header: Text(">> INCOME_DETAILS")
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
                    
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                        .font(AppTheme.Fonts.body())
                        .accentColor(AppTheme.Colors.electricCyan)
                        .listRowBackground(AppTheme.Colors.cardBackground)
                    
                    Toggle("Monthly Income", isOn: $isMonthly)
                        .font(AppTheme.Fonts.body())
                        .tint(AppTheme.Colors.income)
                        .listRowBackground(AppTheme.Colors.cardBackground)
                }
                
                if !isMonthly {
                    Section(footer: Text("// One-time income will not reset with your monthly cycle")
                        .font(AppTheme.Fonts.caption(10))
                        .foregroundColor(AppTheme.Colors.electricCyan.opacity(0.6))
                        .tracking(0.5)) {
                        EmptyView()
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.Colors.primaryBackground)
            .navigationTitle("Add Income")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(">> ADD_INCOME")
                        .font(AppTheme.Fonts.headline(16))
                        .foregroundColor(AppTheme.Colors.income)
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
                        saveIncome()
                    }
                    .font(AppTheme.Fonts.caption(11))
                    .foregroundColor(amount.isEmpty ? AppTheme.Colors.electricCyan.opacity(0.3) : AppTheme.Colors.neonGreen)
                    .tracking(1)
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