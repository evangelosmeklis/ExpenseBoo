import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var tempSettings: Settings
    @State private var showingCategoryManagement = false
    @State private var showingIncomeManagement = false
    @State private var showingInvestmentManagement = false
    @State private var showingSubscriptionManagement = false
    
    init() {
        _tempSettings = State(initialValue: Settings())
    }
    
    var body: some View {
        NavigationView {
            Form {
                
                Section(header: Text("Financial Data")) {
                    Button("Manage Income") {
                        showingIncomeManagement = true
                    }
                    
                    Text("\(dataManager.incomes.count) income entries")
                        .foregroundColor(.secondary)
                        .font(.caption)

                    Button("Manage Investments") {
                        showingInvestmentManagement = true
                    }

                    Text("\(dataManager.investments.count) investment entries")
                        .foregroundColor(.secondary)
                        .font(.caption)

                    Button("Manage Categories") {
                        showingCategoryManagement = true
                    }
                    
                    Text("\(dataManager.categories.count) categories")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    
                    Button("Manage Subscriptions") {
                        showingSubscriptionManagement = true
                    }
                    
                    Text("\(dataManager.subscriptions.count) subscriptions")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                
                Section(header: Text("Display")) {
                    HStack {
                        Text("Currency")
                        Spacer()
                        Picker("Currency", selection: $tempSettings.currency) {
                            ForEach(Currency.allCases, id: \.self) { currency in
                                Text("\(currency.symbol) \(currency.displayName)")
                                    .tag(currency)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: $tempSettings.notificationsEnabled)
                    
                    if tempSettings.notificationsEnabled {
                        DatePicker("Daily Reminder", selection: $tempSettings.dailyNotificationTime, displayedComponents: .hourAndMinute)
                    }
                }
                
                Section(header: Text("Data")) {
                    HStack {
                        Text("Total Expenses")
                        Spacer()
                        Text("\(dataManager.expenses.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Total Income Entries")
                        Spacer()
                        Text("\(dataManager.incomes.count)")
                            .foregroundColor(.secondary)
                    }
                    
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                tempSettings = dataManager.settings
                dataManager.addSubscriptionExpenses()
            }
            .onChange(of: tempSettings) { oldValue, newValue in
                dataManager.updateSettings(newValue)
            }
            .sheet(isPresented: $showingCategoryManagement) {
                CategoryManagementView()
            }
            .sheet(isPresented: $showingIncomeManagement) {
                IncomeManagementView()
            }
            .sheet(isPresented: $showingInvestmentManagement) {
                InvestmentManagementView()
            }
            .sheet(isPresented: $showingSubscriptionManagement) {
                SubscriptionManagementView()
            }
        }
    }
}

struct CategoryManagementView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddCategory = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dataManager.categories) { category in
                    HStack {
                        Circle()
                            .fill(category.color)
                            .frame(width: 20, height: 20)
                        
                        Text(category.name)
                        
                        Spacer()
                        
                        Text("\(expenseCount(for: category))")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                .onDelete(perform: deleteCategories)
            }
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        showingAddCategory = true
                    }
                }
            }
            .sheet(isPresented: $showingAddCategory) {
                AddCategoryView()
            }
        }
    }
    
    private func expenseCount(for category: Category) -> Int {
        return dataManager.expenses.filter { $0.categoryId == category.id }.count
    }
    
    private func deleteCategories(offsets: IndexSet) {
        for offset in offsets {
            let category = dataManager.categories[offset]
            dataManager.deleteCategory(category)
        }
    }
}

struct AddCategoryView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var selectedColor: Color = .blue
    
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink, .gray, .brown, .cyan]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Category Details")) {
                    TextField("Category Name", text: $name)
                }
                
                Section(header: Text("Color")) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 15) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 3)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Add Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveCategory()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveCategory() {
        let category = Category(name: name, color: selectedColor)
        dataManager.addCategory(category)
        dismiss()
    }
}

#Preview {
    SettingsView()
        .environmentObject(DataManager())
}