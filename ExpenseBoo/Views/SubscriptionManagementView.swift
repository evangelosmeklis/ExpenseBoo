import SwiftUI

struct SubscriptionManagementView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddSubscription = false
    
    var body: some View {
        NavigationView {
            List {
                if dataManager.subscriptions.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "repeat.circle")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No subscriptions")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Text("Add recurring expenses like Netflix, Spotify, etc.")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(dataManager.subscriptions) { subscription in
                        SubscriptionRowView(subscription: subscription)
                    }
                }
            }
            .navigationTitle("Subscriptions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        showingAddSubscription = true
                    }
                }
            }
            .sheet(isPresented: $showingAddSubscription) {
                AddSubscriptionView()
            }
        }
    }
}

struct SubscriptionRowView: View {
    @EnvironmentObject var dataManager: DataManager
    let subscription: Subscription
    @State private var showingEditSubscription = false
    
    var category: Category? {
        dataManager.getCategoryById(subscription.categoryId)
    }
    
    var body: some View {
        HStack {
            if let category = category {
                Circle()
                    .fill(category.color)
                    .frame(width: 12, height: 12)
            } else {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 12, height: 12)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(subscription.name)
                    .font(.body)
                
                HStack {
                    Text(category?.name ?? "Uncategorized")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if !subscription.isActive {
                        Text("Paused")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("$\(subscription.amount, specifier: "%.2f")")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(subscription.isActive ? .red : .secondary)
                
                Text("monthly")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            showingEditSubscription = true
        }
        .sheet(isPresented: $showingEditSubscription) {
            EditSubscriptionView(subscription: subscription)
        }
    }
}

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
                        Text("$")
                            .foregroundColor(.secondary)
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                        amount = amount.replacingOccurrences(of: ",", with: ".")
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
                        Text("$")
                            .foregroundColor(.secondary)
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                        amount = amount.replacingOccurrences(of: ",", with: ".")
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

#Preview {
    SubscriptionManagementView()
        .environmentObject(DataManager())
}