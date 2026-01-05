import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var tempSettings: Settings
    @State private var showingIncomeManagement = false
    @State private var showingInvestmentManagement = false

    
    init() {
        _tempSettings = State(initialValue: Settings())
    }
    
    var body: some View {
        NavigationView {
            Form {
                
                Section(header: Text("Financial Data")
                    .font(AppTheme.Fonts.caption(13))
                    .foregroundColor(AppTheme.Colors.secondaryText)) {
                    Button("Manage Income") {
                        showingIncomeManagement = true
                    }
                    .font(AppTheme.Fonts.body())
                    .foregroundColor(AppTheme.Colors.primaryText)
                    .listRowBackground(AppTheme.Colors.cardBackground)
                    
                    Text("\(dataManager.incomes.count) entries")
                        .foregroundColor(AppTheme.Colors.secondaryText)
                        .font(AppTheme.Fonts.caption())
                        .listRowBackground(AppTheme.Colors.cardBackground)

                    Button("Manage Investments") {
                        showingInvestmentManagement = true
                    }
                    .font(AppTheme.Fonts.body())
                    .foregroundColor(AppTheme.Colors.primaryText)
                    .listRowBackground(AppTheme.Colors.cardBackground)

                    Text("\(dataManager.investments.count) entries")
                        .foregroundColor(AppTheme.Colors.secondaryText)
                        .font(AppTheme.Fonts.caption())
                        .listRowBackground(AppTheme.Colors.cardBackground)
                }
                
                Section(header: Text("Display")
                    .font(AppTheme.Fonts.caption(13))
                    .foregroundColor(AppTheme.Colors.secondaryText)) {
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
                        .tint(AppTheme.Colors.electricCyan)
                    }
                    .listRowBackground(AppTheme.Colors.cardBackground)
                }
                
                Section(header: Text("Notifications")
                    .font(AppTheme.Fonts.caption(13))
                    .foregroundColor(AppTheme.Colors.secondaryText)) {
                    Toggle("Enable Notifications", isOn: $tempSettings.notificationsEnabled)
                        .font(AppTheme.Fonts.body())
                        .foregroundColor(AppTheme.Colors.primaryText)
                        .tint(AppTheme.Colors.electricCyan)
                        .listRowBackground(AppTheme.Colors.cardBackground)

                    if tempSettings.notificationsEnabled {
                        DatePicker("Daily Reminder", selection: $tempSettings.dailyNotificationTime, displayedComponents: .hourAndMinute)
                            .font(AppTheme.Fonts.body())
                            .foregroundColor(AppTheme.Colors.primaryText)
                            .tint(AppTheme.Colors.electricCyan)
                            .listRowBackground(AppTheme.Colors.cardBackground)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.Colors.primaryBackground)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(AppTheme.Fonts.headline(18))
                        .foregroundColor(AppTheme.Colors.electricCyan)
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