import SwiftUI

struct SubscriptionsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddSubscription = false
    @State private var isGridView = true
    @State private var isSelectionMode = false
    @State private var selectedSubscriptions: Set<UUID> = []
    @State private var showingSettings = false

    var totalMonthlyCost: Double {
        dataManager.subscriptions.filter { $0.isActive }.reduce(0) { $0 + $1.amount }
    }

    var selectedMonthlyCost: Double {
        dataManager.subscriptions
            .filter { selectedSubscriptions.contains($0.id) }
            .reduce(0) { $0 + $1.amount }
    }

    var sortedSubscriptions: [Subscription] {
        dataManager.subscriptions.sorted { $0.amount > $1.amount }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    HStack {
                        Spacer()
                        Button(action: { showingSettings = true }) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundColor(AppTheme.Colors.secondaryText.opacity(0.6))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // Header Stats
                    VStack(spacing: 12) {
                        if isSelectionMode && !selectedSubscriptions.isEmpty {
                            // Selection mode - show selected vs total
                            HStack(alignment: .center, spacing: 20) {
                                // Total
                                VStack(spacing: 4) {
                                    Text("Total")
                                        .font(AppTheme.Fonts.caption(12))
                                        .foregroundColor(AppTheme.Colors.secondaryText)
                                    Text("\(dataManager.currencySymbol)\(totalMonthlyCost, specifier: "%.2f")")
                                        .font(AppTheme.Fonts.title(24))
                                        .foregroundColor(AppTheme.Colors.primaryText)
                                }

                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16))
                                    .foregroundColor(AppTheme.Colors.secondaryText)

                                // Selected (Potential Savings)
                                VStack(spacing: 4) {
                                    Text("Could Save")
                                        .font(AppTheme.Fonts.caption(12))
                                        .foregroundColor(AppTheme.Colors.loss)
                                    Text("\(dataManager.currencySymbol)\(selectedMonthlyCost, specifier: "%.2f")")
                                        .font(AppTheme.Fonts.title(24))
                                        .foregroundColor(AppTheme.Colors.loss)
                                        .fontWeight(.bold)
                                }
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .background(.ultraThinMaterial)
                            .cornerRadius(16)
                            .shadow(color: AppTheme.Colors.loss.opacity(0.2), radius: 10, x: 0, y: 5)

                            Text("\(selectedSubscriptions.count) selected")
                                .font(AppTheme.Fonts.caption(12))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(AppTheme.Colors.loss.opacity(0.2))
                                .cornerRadius(10)
                                .foregroundColor(AppTheme.Colors.loss)
                        } else {
                            // Normal mode
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
                    }
                    .padding(.top)
                    .animation(.easeInOut(duration: 0.3), value: isSelectionMode)
                    .animation(.easeInOut(duration: 0.3), value: selectedSubscriptions.count)
                    
                    // Unified View Section
                    VStack(alignment: .leading, spacing: 16) {
                        // Header with Switcher and Add Button
                        HStack {
                            Text("Overview")
                                .font(AppTheme.Fonts.headline(18))

                            Spacer()

                            // Selection Mode Button
                            Button(action: {
                                isSelectionMode.toggle()
                                if !isSelectionMode {
                                    selectedSubscriptions.removeAll()
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: isSelectionMode ? "checkmark.circle.fill" : "checkmark.circle")
                                        .font(.system(size: 14))
                                    Text(isSelectionMode ? "Done" : "Select")
                                        .font(AppTheme.Fonts.caption(12))
                                }
                                .foregroundColor(isSelectionMode ? AppTheme.Colors.electricCyan : AppTheme.Colors.secondaryText)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(isSelectionMode ? AppTheme.Colors.electricCyan.opacity(0.2) : AppTheme.Colors.secondaryBackground)
                                .cornerRadius(8)
                            }
                            .padding(.trailing, 8)

                            // View Switcher
                            HStack(spacing: 0) {
                                Button(action: { isGridView = true }) {
                                    Image(systemName: "square.grid.2x2.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(isGridView ? .white : AppTheme.Colors.secondaryText)
                                        .frame(width: 36, height: 32)
                                        .background(isGridView ? AppTheme.Colors.electricCyan : Color.clear)
                                        .cornerRadius(8)
                                }

                                Button(action: { isGridView = false }) {
                                    Image(systemName: "list.bullet")
                                        .font(.system(size: 14))
                                        .foregroundColor(!isGridView ? .white : AppTheme.Colors.secondaryText)
                                        .frame(width: 36, height: 32)
                                        .background(!isGridView ? AppTheme.Colors.electricCyan : Color.clear)
                                        .cornerRadius(8)
                                }
                            }
                            .padding(2)
                            .background(AppTheme.Colors.secondaryBackground)
                            .cornerRadius(10)
                            .padding(.trailing, 8)

                            // Add Button
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
                            if isGridView {
                                SubscriptionGridView(
                                    subscriptions: sortedSubscriptions,
                                    dataManager: dataManager,
                                    isSelectionMode: isSelectionMode,
                                    selectedSubscriptions: $selectedSubscriptions
                                )
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(sortedSubscriptions) { subscription in
                                        SubscriptionCardRow(
                                            subscription: subscription,
                                            isSelectionMode: isSelectionMode,
                                            isSelected: selectedSubscriptions.contains(subscription.id)
                                        )
                                        .onTapGesture {
                                            if isSelectionMode {
                                                if selectedSubscriptions.contains(subscription.id) {
                                                    selectedSubscriptions.remove(subscription.id)
                                                } else {
                                                    selectedSubscriptions.insert(subscription.id)
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 20)
                            }
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
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
}

// MARK: - Visualization
struct SubscriptionGridView: View {
    let subscriptions: [Subscription]
    let dataManager: DataManager
    let isSelectionMode: Bool
    @Binding var selectedSubscriptions: Set<UUID>

    // Vibrant color palette
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

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(Array(subscriptions.enumerated()), id: \.element.id) { index, subscription in
                SubscriptionGridCard(
                    subscription: subscription,
                    color: colorPalette[index % colorPalette.count],
                    dataManager: dataManager,
                    isSelectionMode: isSelectionMode,
                    isSelected: selectedSubscriptions.contains(subscription.id)
                )
                .onTapGesture {
                    if isSelectionMode {
                        if selectedSubscriptions.contains(subscription.id) {
                            selectedSubscriptions.remove(subscription.id)
                        } else {
                            selectedSubscriptions.insert(subscription.id)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

struct SubscriptionGridCard: View {
    let subscription: Subscription
    let color: Color
    let dataManager: DataManager
    let isSelectionMode: Bool
    let isSelected: Bool

    var category: Category? {
        dataManager.getCategoryById(subscription.categoryId)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Icon & Category Indicator
            HStack {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 32, height: 32)

                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }

                Spacer()

                // Selection indicator or status dot
                if isSelectionMode {
                    ZStack {
                        Circle()
                            .fill(isSelected ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 24, height: 24)

                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(color)
                        }
                    }
                } else if subscription.isActive {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 6, height: 6)
                        .shadow(color: .white.opacity(0.5), radius: 4)
                }
            }
            
            Spacer()
            
            // Amount
            Text("\(dataManager.currencySymbol)\(subscription.amount, specifier: "%.2f")")
                .font(AppTheme.Fonts.number(24))
                .foregroundColor(.white)
                .fontWeight(.bold)
            
            // Name
            Text(subscription.name)
                .font(AppTheme.Fonts.body(14))
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(1)
        }
        .padding(16)
        .frame(height: 160)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [color, color.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? Color.white : Color.white.opacity(0.2), lineWidth: isSelected ? 3 : 1)
        )
        .scaleEffect(isSelected ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Sub Views
struct SubscriptionCardRow: View {
    @EnvironmentObject var dataManager: DataManager
    let subscription: Subscription
    let isSelectionMode: Bool
    let isSelected: Bool
    @State private var showingEdit = false

    var category: Category? {
        dataManager.getCategoryById(subscription.categoryId)
    }

    var body: some View {
        HStack {
            // Selection indicator
            if isSelectionMode {
                ZStack {
                    Circle()
                        .stroke(isSelected ? AppTheme.Colors.electricCyan : AppTheme.Colors.secondaryText.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(AppTheme.Colors.electricCyan)
                            .frame(width: 24, height: 24)

                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.trailing, 8)
            }

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
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? AppTheme.Colors.electricCyan : Color.clear, lineWidth: 2)
        )
        .onTapGesture {
            if !isSelectionMode {
                showingEdit = true
            }
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
