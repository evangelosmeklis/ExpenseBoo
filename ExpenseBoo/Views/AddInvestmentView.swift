import SwiftUI

struct AddInvestmentView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss

    @State private var amount: String = ""
    @State private var comment: String = ""
    @State private var selectedCategory: Category?
    @State private var selectedDate = Date()

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
                                // Clean and format the input to handle decimals properly
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
            }
            .navigationTitle("Add Investment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveInvestment()
                    }
                    .disabled(amount.isEmpty || comment.isEmpty)
                }
            }
        }
    }

    private func saveInvestment() {
        guard let amountValue = Double(amount) else { return }

        let investment = Investment(
            amount: amountValue,
            comment: comment,
            date: selectedDate,
            categoryId: selectedCategory?.id
        )

        dataManager.addInvestment(investment)
        dismiss()
    }
}

#Preview {
    AddInvestmentView()
        .environmentObject(DataManager())
}