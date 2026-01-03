import SwiftUI

struct InvestmentManagementView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddInvestment = false

    var body: some View {
        NavigationView {
            List {
                if dataManager.investments.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)

                        Text("No investment entries")
                            .font(.title2)
                            .foregroundColor(.secondary)

                        Text("Add your investments to track your portfolio")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(dataManager.investments.sorted { $0.date > $1.date }) { investment in
                        InvestmentRowView(investment: investment)
                    }
                }
            }
            .navigationTitle("Investment Management")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        showingAddInvestment = true
                    }
                }
            }
            .sheet(isPresented: $showingAddInvestment) {
                AddInvestmentView()
            }
        }
    }
}

struct InvestmentRowView: View {
    @EnvironmentObject var dataManager: DataManager
    let investment: Investment
    @State private var showingEditInvestment = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Circle()
                .fill(AppTheme.Colors.investment.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.Colors.investment)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(investment.comment.isEmpty ? "Investment" : investment.comment)
                    .font(AppTheme.Fonts.body(16))
                    .foregroundColor(AppTheme.Colors.primaryText)

                Text(dateFormatter.string(from: investment.date))
                    .font(AppTheme.Fonts.caption(12))
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }

            Spacer()

            Text("\(dataManager.currencySymbol)\(investment.amount, specifier: "%.2f")")
                .font(AppTheme.Fonts.number(16))
                .foregroundColor(AppTheme.Colors.primaryText)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            showingEditInvestment = true
        }
        .sheet(isPresented: $showingEditInvestment) {
            EditInvestmentView(investment: investment)
        }
        .listRowBackground(Color.clear)
        .listRowSeparatorTint(AppTheme.Colors.secondaryText.opacity(0.2))
    }
}

struct EditInvestmentView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss

    let investment: Investment
    @State private var amount: String = ""
    @State private var comment: String = ""
    @State private var selectedDate = Date()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Investment Details")
                    .font(AppTheme.Fonts.caption(12))
                    .foregroundColor(AppTheme.Colors.secondaryText)) {
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

                    TextField("What did you invest in?", text: $comment)
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
                    Button("Delete Investment", role: .destructive) {
                        dataManager.deleteInvestment(investment)
                        dismiss()
                    }
                    .font(AppTheme.Fonts.body())
                    .listRowBackground(AppTheme.Colors.cardBackground)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.Colors.primaryBackground)
            .navigationTitle("Edit Investment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Edit Investment")
                        .font(AppTheme.Fonts.headline(16))
                        .foregroundColor(AppTheme.Colors.primaryText)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(AppTheme.Fonts.body())
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .font(AppTheme.Fonts.body())
                    .disabled(amount.isEmpty || comment.isEmpty)
                }
            }
            .onAppear {
                amount = String(investment.amount)
                comment = investment.comment
                selectedDate = investment.date
            }
        }
    }

    private func saveChanges() {
        guard let amountValue = Double(amount) else { return }

        var updatedInvestment = investment
        updatedInvestment.amount = amountValue
        updatedInvestment.comment = comment
        updatedInvestment.date = selectedDate
        updatedInvestment.categoryId = nil

        dataManager.updateInvestment(updatedInvestment)
        dismiss()
    }
}

#Preview {
    InvestmentManagementView()
        .environmentObject(DataManager())
}