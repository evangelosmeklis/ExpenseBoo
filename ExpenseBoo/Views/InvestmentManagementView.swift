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

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(dataManager.currencySymbol)\(investment.amount, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(.purple)

                Text(investment.comment)
                    .font(.subheadline)
                    .foregroundColor(.primary)

                HStack {
                    Text(investment.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if let categoryId = investment.categoryId,
                       let category = dataManager.getCategoryById(categoryId) {
                        Text("• \(category.name)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            Button("Edit") {
                showingEditInvestment = true
            }
            .font(.caption)
            .foregroundColor(.purple)
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showingEditInvestment) {
            EditInvestmentView(investment: investment)
        }
    }
}

struct EditInvestmentView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss

    let investment: Investment
    @State private var amount: String = ""
    @State private var comment: String = ""
    @State private var selectedDate = Date()
    @State private var selectedCategory: Category?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Investment Details")) {
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

                    TextField("What did you invest in?", text: $comment)

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
                                        .foregroundColor(.purple)
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
                    Button("Delete Investment", role: .destructive) {
                        dataManager.deleteInvestment(investment)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Edit Investment")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                amount = String(investment.amount)
                comment = investment.comment
                selectedDate = investment.date
                selectedCategory = dataManager.getCategoryById(investment.categoryId)
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

        var updatedInvestment = investment
        updatedInvestment.amount = amountValue
        updatedInvestment.comment = comment
        updatedInvestment.date = selectedDate
        updatedInvestment.categoryId = selectedCategory?.id

        dataManager.updateInvestment(updatedInvestment)
        dismiss()
    }
}

#Preview {
    InvestmentManagementView()
        .environmentObject(DataManager())
}