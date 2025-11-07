import SwiftUI

struct IncomeManagementView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddIncome = false
    
    var body: some View {
        NavigationView {
            List {
                if dataManager.incomes.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "dollarsign.circle")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No income entries")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Text("Add your income to track your budget")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(dataManager.incomes.sorted { $0.date > $1.date }) { income in
                        IncomeRowView(income: income)
                    }
                }
            }
            .navigationTitle("Income Management")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        showingAddIncome = true
                    }
                }
            }
            .sheet(isPresented: $showingAddIncome) {
                AddIncomeView()
            }
        }
    }
}

struct IncomeRowView: View {
    @EnvironmentObject var dataManager: DataManager
    let income: Income
    @State private var showingEditIncome = false
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(dataManager.currencySymbol)\(income.amount, specifier: "%.2f")")
                    .font(AppTheme.Fonts.number(16))
                    .foregroundColor(AppTheme.Colors.income)
                
                HStack {
                    Text(income.date, style: .date)
                        .font(AppTheme.Fonts.caption(10))
                        .foregroundColor(AppTheme.Colors.electricCyan.opacity(0.7))
                    
                    if income.isMonthly {
                        Text("• MONTHLY")
                            .font(AppTheme.Fonts.caption(10))
                            .foregroundColor(AppTheme.Colors.electricCyan)
                            .tracking(0.5)
                    } else {
                        Text("• ONE-TIME")
                            .font(AppTheme.Fonts.caption(10))
                            .foregroundColor(AppTheme.Colors.techOrange)
                            .tracking(0.5)
                    }
                }
            }
            
            Spacer()
            
            Button("EDIT") {
                showingEditIncome = true
            }
            .font(AppTheme.Fonts.caption(10))
            .foregroundColor(AppTheme.Colors.income)
            .tracking(1)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .sheet(isPresented: $showingEditIncome) {
            EditIncomeView(income: income)
        }
    }
}

struct EditIncomeView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    let income: Income
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
                            .onChange(of: amount) { oldValue, newValue in
                                let filtered = newValue.replacingOccurrences(of: ",", with: ".")
                                if filtered != amount {
                                    amount = filtered
                                }
                            }
                    }
                    
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                    
                    Toggle("Monthly Income", isOn: $isMonthly)
                }
                
                Section {
                    Button("Delete Income", role: .destructive) {
                        dataManager.deleteIncome(income)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Edit Income")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                amount = String(income.amount)
                selectedDate = income.date
                isMonthly = income.isMonthly
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
                    .disabled(amount.isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        guard let amountValue = Double(amount) else { return }
        
        var updatedIncome = income
        updatedIncome.amount = amountValue
        updatedIncome.date = selectedDate
        updatedIncome.isMonthly = isMonthly
        
        dataManager.updateIncome(updatedIncome)
        dismiss()
    }
}

#Preview {
    IncomeManagementView()
        .environmentObject(DataManager())
}