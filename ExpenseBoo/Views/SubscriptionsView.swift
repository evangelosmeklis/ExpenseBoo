import SwiftUI

struct SubscriptionsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddSubscription = false
    
    var totalMonthlyCost: Double {
        dataManager.subscriptions.filter { $0.isActive }.reduce(0) { $0 + $1.amount }
    }
    
    var sortedSubscriptions: [Subscription] {
        dataManager.subscriptions.sorted { $0.amount > $1.amount }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Stats
                    VStack(spacing: 8) {
                        Text("Total Monthly")
                            .font(AppTheme.Fonts.caption(14))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                        
                        Text("\(dataManager.currencySymbol)\(totalMonthlyCost, specifier: "%.2f")")
                            .font(AppTheme.Fonts.title(36))
                            .foregroundColor(AppTheme.Colors.primaryText)
                            .shadow(color: AppTheme.Colors.electricCyan.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        Text("\(dataManager.subscriptions.filter { $0.isActive }.count) active subscriptions")
                             .font(AppTheme.Fonts.caption(12))
                             .padding(.horizontal, 10)
                             .padding(.vertical, 4)
                             .background(AppTheme.Colors.secondaryBackground)
                             .cornerRadius(10)
                             .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                    .padding(.top)
                    
                    // Visualization: Subscription Map
                    if !dataManager.subscriptions.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Expense Map")
                                .font(AppTheme.Fonts.headline(18))
                                .padding(.horizontal)
                            
                            SubscriptionTreeMap(
                                subscriptions: sortedSubscriptions,
                                totalAmount: totalMonthlyCost == 0 ? 1 : totalMonthlyCost,
                                dataManager: dataManager
                            )
                            .frame(height: 220)
                            .padding(.horizontal)
                        }
                    }
                    
                    // List
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Your Subscriptions")
                                .font(AppTheme.Fonts.headline(18))
                            Spacer()
                            Button(action: { showingAddSubscription = true }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(AppTheme.Colors.electricCyan)
                            }
                        }
                        .padding(.horizontal)
                        
                        if dataManager.subscriptions.isEmpty {
                            EmptyStateView()
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(dataManager.subscriptions) { subscription in
                                    SubscriptionCardRow(subscription: subscription)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .background(AppTheme.Colors.primaryBackground.ignoresSafeArea())
            .navigationTitle("Subscriptions")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddSubscription) {
                AddSubscriptionView()
            }
        }
    }
}

// MARK: - Visualization
struct SubscriptionTreeMap: View {
    let subscriptions: [Subscription]
    let totalAmount: Double
    let dataManager: DataManager

    // Vibrant color palette for subscriptions
    let colorPalette: [Color] = [
        Color(red: 0.3, green: 0.7, blue: 0.9),   // Sky Blue
        Color(red: 0.9, green: 0.5, blue: 0.3),   // Coral
        Color(red: 0.5, green: 0.8, blue: 0.5),   // Mint Green
        Color(red: 0.8, green: 0.4, blue: 0.7),   // Purple
        Color(red: 1.0, green: 0.7, blue: 0.3),   // Golden
        Color(red: 0.4, green: 0.6, blue: 0.9),   // Blue
        Color(red: 0.9, green: 0.6, blue: 0.5),   // Peach
        Color(red: 0.5, green: 0.7, blue: 0.8),   // Teal
        Color(red: 0.8, green: 0.5, blue: 0.5),   // Rose
        Color(red: 0.6, green: 0.8, blue: 0.4)    // Lime
    ]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 8) {
                ForEach(Array(subscriptions.enumerated()), id: \.element.id) { index, subscription in
                    SubscriptionBox(
                        subscription: subscription,
                        color: colorPalette[index % colorPalette.count],
                        dataManager: dataManager
                    )
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(height: 220)
    }
}

struct SubscriptionBox: View {
    let subscription: Subscription
    let color: Color
    let dataManager: DataManager

    // Calculate width based on amount (min 80, max 200)
    private var boxWidth: CGFloat {
        let percentage = subscription.amount / max(dataManager.subscriptions.map { $0.amount }.max() ?? 1, 1)
        return 80 + (percentage * 120) // Range: 80-200
    }

    var body: some View {
        VStack(spacing: 8) {
            // Amount display
            VStack(spacing: 4) {
                Text("\(dataManager.currencySymbol)\(subscription.amount, specifier: "%.2f")")
                    .font(AppTheme.Fonts.number(22))
                    .foregroundColor(.white)
                    .fontWeight(.bold)

                Text("/mo")
                    .font(AppTheme.Fonts.caption(10))
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 16)

            Spacer()

            // Subscription name
            Text(subscription.name)
                .font(AppTheme.Fonts.body(13))
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 8)
                .padding(.bottom, 12)
        }
        .frame(width: boxWidth, height: 190)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [color, color.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Sub Views
struct SubscriptionCardRow: View {
    @EnvironmentObject var dataManager: DataManager
    let subscription: Subscription
    @State private var showingEdit = false
    
    var category: Category? {
        dataManager.getCategoryById(subscription.categoryId)
    }
    
    var body: some View {
        HStack {
            // Icon / Category
            ZStack {
                Circle()
                    .fill(category?.color.opacity(0.2) ?? Color.gray.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Image(systemName: "creditcard.fill")
                    .foregroundColor(category?.color ?? .gray)
                    .font(.system(size: 20))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(subscription.name)
                    .font(AppTheme.Fonts.body(16))
                    .foregroundColor(AppTheme.Colors.primaryText)
                
                Text(category?.name ?? "Uncategorized")
                    .font(AppTheme.Fonts.caption(12))
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(dataManager.currencySymbol)\(subscription.amount, specifier: "%.2f")")
                    .font(AppTheme.Fonts.number(16))
                    .foregroundColor(subscription.isActive ? AppTheme.Colors.primaryText : .gray)
                
                if !subscription.isActive {
                    Text("Paused")
                        .font(AppTheme.Fonts.caption(10))
                        .padding(4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                } else {
                    Text("/mo")
                        .font(AppTheme.Fonts.caption(12))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }
            }
        }
        .padding(16)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .onTapGesture {
            showingEdit = true
        }
        .sheet(isPresented: $showingEdit) {
            EditSubscriptionView(subscription: subscription)
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "creditcard.circle")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.electricCyan.opacity(0.5))
            
            Text("No subscriptions yet")
                .font(AppTheme.Fonts.headline())
                .foregroundColor(AppTheme.Colors.secondaryText)
            
            Text("Add your recurring expenses to track them here.")
                .font(AppTheme.Fonts.caption())
                .foregroundColor(AppTheme.Colors.secondaryText.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

// MARK: - Add/Edit Views

struct AddSubscriptionView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var amount: String = ""
    @State private var selectedCategory: Category?
    @State private var startDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Subscription Details")) {
                    TextField("Subscription Name", text: $name)
                    
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
                    
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
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
                                        .foregroundColor(.blue)
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
            .navigationTitle("Add Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSubscription()
                    }
                    .disabled(name.isEmpty || amount.isEmpty)
                }
            }
        }
    }
    
    private func saveSubscription() {
        guard let amountValue = Double(amount) else { return }
        
        let subscription = Subscription(
            name: name,
            amount: amountValue,
            categoryId: selectedCategory?.id,
            startDate: startDate
        )
        
        dataManager.addSubscription(subscription)
        dismiss()
    }
}

struct EditSubscriptionView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    let subscription: Subscription
    @State private var name: String = ""
    @State private var amount: String = ""
    @State private var selectedCategory: Category?
    @State private var startDate = Date()
    @State private var isActive = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Subscription Details")) {
                    TextField("Subscription Name", text: $name)
                    
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
                    
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    
                    Toggle("Active", isOn: $isActive)
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
                                        .foregroundColor(.blue)
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
                    Button("Delete Subscription", role: .destructive) {
                        dataManager.deleteSubscription(subscription)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Edit Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                name = subscription.name
                amount = String(subscription.amount)
                selectedCategory = dataManager.getCategoryById(subscription.categoryId)
                startDate = subscription.startDate
                isActive = subscription.isActive
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
                    .disabled(name.isEmpty || amount.isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        guard let amountValue = Double(amount) else { return }
        
        var updatedSubscription = subscription
        updatedSubscription.name = name
        updatedSubscription.amount = amountValue
        updatedSubscription.categoryId = selectedCategory?.id
        updatedSubscription.startDate = startDate
        updatedSubscription.isActive = isActive
        
        dataManager.updateSubscription(updatedSubscription)
        dismiss()
    }
}
