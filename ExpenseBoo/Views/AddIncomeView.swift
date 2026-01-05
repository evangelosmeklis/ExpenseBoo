import SwiftUI

struct AddIncomeView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var amount: String = ""
    @State private var selectedDate = Date()
    @State private var isMonthly = true
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                AppTheme.Colors.primaryBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Amount Input Section
                    VStack(spacing: 10) {
                        Text("INCOME AMOUNT")
                            .font(AppTheme.Fonts.caption(12))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                            .tracking(2)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(dataManager.currencySymbol)
                                .font(.system(size: 40, weight: .medium, design: .rounded))
                                .foregroundColor(AppTheme.Colors.secondaryText)

                            TextField("0", text: $amount)
                                .font(.system(size: 60, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.Colors.income)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: true, vertical: false)
                                .onChange(of: amount) { oldValue, newValue in
                                    let filtered = newValue.replacingOccurrences(of: ",", with: ".")
                                    if filtered != amount {
                                        amount = filtered
                                    }
                                }
                        }
                    }
                    .padding(.top, 40)
                    
                    // Details Card
                    VStack(spacing: 20) {
                        // Date Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("DATE")
                                .font(AppTheme.Fonts.caption(12))
                                .foregroundColor(AppTheme.Colors.secondaryText)
                                .tracking(1)
                            
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(AppTheme.Colors.income)
                                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                    .labelsHidden()
                                    .accentColor(AppTheme.Colors.income)
                                Spacer()
                            }
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                        }
                        
                        // Monthly Toggle
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Monthly Income")
                                        .font(AppTheme.Fonts.body())
                                        .foregroundColor(AppTheme.Colors.primaryText)
                                    
                                    if !isMonthly {
                                        Text("One-time income")
                                            .font(AppTheme.Fonts.caption(10))
                                            .foregroundColor(AppTheme.Colors.secondaryText)
                                    }
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $isMonthly)
                                    .labelsHidden()
                                    .tint(AppTheme.Colors.income)
                            }
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                        }
                    }
                    .padding(24)
                    .background(.ultraThinMaterial)
                    .cornerRadius(24)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Buttons
                    HStack(spacing: 16) {
                        Button(action: { dismiss() }) {
                            Text("Cancel")
                                .font(AppTheme.Fonts.headline(16))
                                .foregroundColor(AppTheme.Colors.secondaryText)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(28)
                        }
                        
                        Button(action: { saveIncome() }) {
                            Text("Save Income")
                                .font(AppTheme.Fonts.headline(16))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [AppTheme.Colors.income, AppTheme.Colors.income.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(28)
                                .shadow(color: AppTheme.Colors.income.opacity(0.4), radius: 10, x: 0, y: 5)
                        }
                        .disabled(amount.isEmpty)
                        .opacity(amount.isEmpty ? 0.6 : 1)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
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