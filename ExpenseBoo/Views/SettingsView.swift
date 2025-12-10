import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var tempSettings: Settings
    @State private var showingIncomeManagement = false
    @State private var showingInvestmentManagement = false
    @State private var showingSubscriptionManagement = false
    
    init() {
        _tempSettings = State(initialValue: Settings())
    }
    
    var body: some View {
        NavigationView {
            Form {
                
                Section(header: Text(">> FINANCIAL_DATA")
                    .font(AppTheme.Fonts.caption(11))
                    .foregroundColor(AppTheme.Colors.electricCyan)
                    .tracking(2)) {
                    Button("Manage Income") {
                        showingIncomeManagement = true
                    }
                    .font(AppTheme.Fonts.body())
                    .foregroundColor(AppTheme.Colors.income)
                    .listRowBackground(AppTheme.Colors.cardBackground)
                    
                    Text("[\(dataManager.incomes.count) ENTRIES]")
                        .foregroundColor(AppTheme.Colors.electricCyan.opacity(0.6))
                        .font(AppTheme.Fonts.caption(10))
                        .tracking(1)
                        .listRowBackground(AppTheme.Colors.cardBackground)

                    Button("Manage Investments") {
                        showingInvestmentManagement = true
                    }
                    .font(AppTheme.Fonts.body())
                    .foregroundColor(AppTheme.Colors.investment)
                    .listRowBackground(AppTheme.Colors.cardBackground)

                    Text("[\(dataManager.investments.count) ENTRIES]")
                        .foregroundColor(AppTheme.Colors.electricCyan.opacity(0.6))
                        .font(AppTheme.Fonts.caption(10))
                        .tracking(1)
                        .listRowBackground(AppTheme.Colors.cardBackground)
                    
                    Button("Manage Subscriptions") {
                        showingSubscriptionManagement = true
                    }
                    .font(AppTheme.Fonts.body())
                    .foregroundColor(AppTheme.Colors.techOrange)
                    .listRowBackground(AppTheme.Colors.cardBackground)
                    
                    Text("[\(dataManager.subscriptions.count) SUBSCRIPTIONS]")
                        .foregroundColor(AppTheme.Colors.electricCyan.opacity(0.6))
                        .font(AppTheme.Fonts.caption(10))
                        .tracking(1)
                        .listRowBackground(AppTheme.Colors.cardBackground)
                }
                
                Section(header: Text(">> DISPLAY")
                    .font(AppTheme.Fonts.caption(11))
                    .foregroundColor(AppTheme.Colors.electricCyan)
                    .tracking(2)) {
                    HStack {
                        Text("Currency")
                            .font(AppTheme.Fonts.body())
                            .foregroundColor(AppTheme.Colors.primaryText)
                        Spacer()
                        Picker("Currency", selection: $tempSettings.currency) {
                            ForEach(Currency.allCases, id: \.self) { currency in
                                Text("\(currency.symbol) \(currency.displayName)")
                                    .font(AppTheme.Fonts.body())
                                    .tag(currency)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .accentColor(AppTheme.Colors.electricCyan)
                    }
                    .listRowBackground(AppTheme.Colors.cardBackground)
                }
                
                Section(header: Text(">> NOTIFICATIONS")
                    .font(AppTheme.Fonts.caption(11))
                    .foregroundColor(AppTheme.Colors.electricCyan)
                    .tracking(2)) {
                    Toggle("Enable Notifications", isOn: $tempSettings.notificationsEnabled)
                        .font(AppTheme.Fonts.body())
                        .foregroundColor(AppTheme.Colors.primaryText)
                        .tint(AppTheme.Colors.electricCyan)
                        .listRowBackground(AppTheme.Colors.cardBackground)

                    if tempSettings.notificationsEnabled {
                        DatePicker("Daily Reminder", selection: $tempSettings.dailyNotificationTime, displayedComponents: .hourAndMinute)
                            .font(AppTheme.Fonts.body())
                            .foregroundColor(AppTheme.Colors.primaryText)
                            .accentColor(AppTheme.Colors.electricCyan)
                            .listRowBackground(AppTheme.Colors.cardBackground)
                    }
                }
                
                Section(header: Text(">> DATA")
                    .font(AppTheme.Fonts.caption(11))
                    .foregroundColor(AppTheme.Colors.electricCyan)
                    .tracking(2)) {
                    HStack {
                        Text("Total Expenses")
                            .font(AppTheme.Fonts.body())
                            .foregroundColor(AppTheme.Colors.primaryText)
                        Spacer()
                        Text("\(dataManager.expenses.count)")
                            .font(AppTheme.Fonts.number())
                            .foregroundColor(AppTheme.Colors.electricCyan.opacity(0.7))
                    }
                    .listRowBackground(AppTheme.Colors.cardBackground)

                    HStack {
                        Text("Total Income Entries")
                            .font(AppTheme.Fonts.body())
                            .foregroundColor(AppTheme.Colors.primaryText)
                        Spacer()
                        Text("\(dataManager.incomes.count)")
                            .font(AppTheme.Fonts.number())
                            .foregroundColor(AppTheme.Colors.electricCyan.opacity(0.7))
                    }
                    .listRowBackground(AppTheme.Colors.cardBackground)
                    
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.Colors.primaryBackground)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(">> SETTINGS")
                        .font(AppTheme.Fonts.headline(18))
                        .foregroundColor(AppTheme.Colors.electricCyan)
                        .tracking(2)
                }
            }
            .onAppear {
                tempSettings = dataManager.settings
                dataManager.addSubscriptionExpenses()
            }
            .onChange(of: tempSettings) { oldValue, newValue in
                dataManager.updateSettings(newValue)
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