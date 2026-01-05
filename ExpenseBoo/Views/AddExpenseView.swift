import SwiftUI

struct AddExpenseView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var amount: String = ""
    @State private var comment: String = ""
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                AppTheme.Colors.primaryBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Amount Input Section
                    VStack(spacing: 10) {
                        Text("AMOUNT")
                            .font(AppTheme.Fonts.caption(12))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                            .tracking(2)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(dataManager.currencySymbol)
                                .font(.system(size: 40, weight: .medium, design: .rounded))
                                .foregroundColor(AppTheme.Colors.secondaryText)

                            TextField("0", text: $amount)
                                .font(.system(size: 60, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.Colors.expense)
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
                        // Note Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("DETAILS")
                                .font(AppTheme.Fonts.caption(12))
                                .foregroundColor(AppTheme.Colors.secondaryText)
                                .tracking(1)
                            
                            HStack {
                                Image(systemName: "pencil")
                                    .foregroundColor(AppTheme.Colors.electricCyan)
                                TextField("What is this for?", text: $comment)
                                    .font(AppTheme.Fonts.body())
                                    .foregroundColor(AppTheme.Colors.primaryText)
                            }
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                        }
                        
                        // Date Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("DATE")
                                .font(AppTheme.Fonts.caption(12))
                                .foregroundColor(AppTheme.Colors.secondaryText)
                                .tracking(1)
                            
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(AppTheme.Colors.electricCyan)
                                DatePicker("", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                                    .labelsHidden()
                                    .accentColor(AppTheme.Colors.electricCyan)
                                Spacer()
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
                        
                        Button(action: { saveExpense() }) {
                            Text("Save Expense")
                                .font(AppTheme.Fonts.headline(16))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [AppTheme.Colors.expense, AppTheme.Colors.expense.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(28)
                                .shadow(color: AppTheme.Colors.expense.opacity(0.4), radius: 10, x: 0, y: 5)
                        }
                        .disabled(amount.isEmpty || comment.isEmpty)
                        .opacity(amount.isEmpty || comment.isEmpty ? 0.6 : 1)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func saveExpense() {
        guard let amountValue = Double(amount) else { return }
        
        let expense = Expense(
            amount: amountValue,
            comment: comment,
            date: selectedDate,
            categoryId: nil
        )
        
        dataManager.addExpense(expense)
        dismiss()
    }
}

#Preview {
    AddExpenseView()
        .environmentObject(DataManager())
}