import SwiftUI

struct SavingGoalsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddGoal = false
    @State private var showingGenericGoal = false
    
    var activeGoals: [SavingGoal] {
        dataManager.savingGoals.filter { !$0.isGeneric && $0.targetDate >= Date() }.sorted { $0.targetDate < $1.targetDate }
    }
    
    var completedGoals: [SavingGoal] {
        dataManager.savingGoals.filter { !$0.isGeneric && $0.progress >= 1.0 }.sorted { $0.targetDate > $1.targetDate }
    }
    
    var genericGoal: SavingGoal? {
        dataManager.savingGoals.first { $0.isGeneric }
    }
    
    var body: some View {
        NavigationView {
            List {
                if let genericGoal = genericGoal {
                    Section(header: Text("Monthly Saving Goal")) {
                        GenericGoalRowView(goal: genericGoal)
                    }
                } else {
                    Section(header: Text("Monthly Saving Goal")) {
                        Button("Set Monthly Saving Goal") {
                            showingGenericGoal = true
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                if !activeGoals.isEmpty {
                    Section(header: Text("Active Goals")) {
                        ForEach(activeGoals) { goal in
                            SavingGoalRowView(goal: goal)
                        }
                    }
                }
                
                if !completedGoals.isEmpty {
                    Section(header: Text("Completed Goals")) {
                        ForEach(completedGoals) { goal in
                            SavingGoalRowView(goal: goal)
                        }
                    }
                }
                
                if activeGoals.isEmpty && completedGoals.isEmpty && genericGoal == nil {
                    VStack(spacing: 20) {
                        Image(systemName: "target")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No saving goals yet")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Text("Set goals to track your savings progress")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }
            .navigationTitle("Saving Goals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Add Specific Goal") {
                            showingAddGoal = true
                        }
                        
                        if genericGoal == nil {
                            Button("Set Monthly Goal") {
                                showingGenericGoal = true
                            }
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                AddSavingGoalView()
            }
            .sheet(isPresented: $showingGenericGoal) {
                AddGenericGoalView()
            }
        }
    }
}

struct SavingGoalRowView: View {
    @EnvironmentObject var dataManager: DataManager
    let goal: SavingGoal
    @State private var showingEditGoal = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(goal.name)
                    .font(.headline)
                
                Spacer()
                
                Button(action: { showingEditGoal = true }) {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                }
            }
            
            HStack {
                Text("\(dataManager.currencySymbol)\(goal.currentAmount, specifier: "%.2f")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("of \(dataManager.currencySymbol)\(goal.targetAmount, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(goal.progress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: goal.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: goal.progress >= 1.0 ? .green : .blue))
            
            HStack {
                if goal.daysRemaining > 0 {
                    Text("\(goal.daysRemaining) days left")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if goal.remainingAmount > 0 {
                        Text("Save \(dataManager.currencySymbol)\(goal.dailySavingNeeded, specifier: "%.2f")/day")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                } else {
                    Text("Goal deadline passed")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showingEditGoal) {
            EditSavingGoalView(goal: goal)
        }
    }
}

struct GenericGoalRowView: View {
    @EnvironmentObject var dataManager: DataManager
    let goal: SavingGoal
    @State private var showingEditGoal = false
    
    var monthlyProgress: Double {
        let currentBalance = dataManager.getCurrentBalance()
        guard goal.targetAmount > 0 else { return 0 }
        return min(max(currentBalance, 0) / goal.targetAmount, 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Save \(dataManager.currencySymbol)\(goal.targetAmount, specifier: "%.2f") this month")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { showingEditGoal = true }) {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                }
            }
            
            HStack {
                Text("Current surplus: \(dataManager.currencySymbol)\(max(dataManager.getCurrentBalance(), 0), specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(dataManager.getCurrentBalance() >= 0 ? .green : .red)
                
                Spacer()
                
                Text("\(Int(monthlyProgress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: monthlyProgress)
                .progressViewStyle(LinearProgressViewStyle(tint: monthlyProgress >= 1.0 ? .green : .blue))
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showingEditGoal) {
            EditSavingGoalView(goal: goal)
        }
    }
}

struct AddSavingGoalView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var targetAmount: String = ""
    @State private var targetDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal Details")) {
                    TextField("Goal Name", text: $name)
                    
                    HStack {
                        Text(dataManager.currencySymbol)
                            .foregroundColor(.secondary)
                        TextField("0.00", text: $targetAmount)
                            .keyboardType(.decimalPad)
                            .onChange(of: targetAmount) { newValue in
                                let filtered = newValue.replacingOccurrences(of: ",", with: ".")
                                if filtered != targetAmount {
                                    targetAmount = filtered
                                }
                            }
                    }
                    
                    DatePicker("Target Date", selection: $targetDate, in: Date()..., displayedComponents: .date)
                }
            }
            .navigationTitle("Add Saving Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveGoal()
                    }
                    .disabled(name.isEmpty || targetAmount.isEmpty)
                }
            }
        }
    }
    
    private func saveGoal() {
        guard let amountValue = Double(targetAmount) else { return }
        
        let goal = SavingGoal(
            name: name,
            targetAmount: amountValue,
            targetDate: targetDate
        )
        
        dataManager.addSavingGoal(goal)
        dismiss()
    }
}

struct AddGenericGoalView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var targetAmount: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Monthly Saving Goal"), footer: Text("This goal resets each month and tracks how much you want to save from your monthly surplus")) {
                    HStack {
                        Text(dataManager.currencySymbol)
                            .foregroundColor(.secondary)
                        TextField("0.00", text: $targetAmount)
                            .keyboardType(.decimalPad)
                            .onChange(of: targetAmount) { newValue in
                                let filtered = newValue.replacingOccurrences(of: ",", with: ".")
                                if filtered != targetAmount {
                                    targetAmount = filtered
                                }
                            }
                    }
                }
            }
            .navigationTitle("Monthly Saving Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveGoal()
                    }
                    .disabled(targetAmount.isEmpty)
                }
            }
        }
    }
    
    private func saveGoal() {
        guard let amountValue = Double(targetAmount) else { return }
        
        let goal = SavingGoal(
            name: "Monthly Saving Goal",
            targetAmount: amountValue,
            targetDate: Date(),
            isGeneric: true
        )
        
        dataManager.addSavingGoal(goal)
        dismiss()
    }
}

struct EditSavingGoalView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    let goal: SavingGoal
    @State private var currentAmount: String = ""
    @State private var targetAmount: String = ""
    @State private var name: String = ""
    @State private var targetDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                if !goal.isGeneric {
                    Section(header: Text("Goal Details")) {
                        TextField("Goal Name", text: $name)
                        
                        HStack {
                            Text("Target: \(dataManager.currencySymbol)")
                                .foregroundColor(.secondary)
                            TextField("0.00", text: $targetAmount)
                                .keyboardType(.decimalPad)
                                .onChange(of: targetAmount) { newValue in
                                    let filtered = newValue.replacingOccurrences(of: ",", with: ".")
                                    if filtered != targetAmount {
                                        targetAmount = filtered
                                    }
                                }
                        }
                        
                        DatePicker("Target Date", selection: $targetDate, in: Date()..., displayedComponents: .date)
                    }
                    
                    Section(header: Text("Progress")) {
                        HStack {
                            Text("Current: \(dataManager.currencySymbol)")
                                .foregroundColor(.secondary)
                            TextField("0.00", text: $currentAmount)
                                .keyboardType(.decimalPad)
                                .onChange(of: currentAmount) { newValue in
                                    let filtered = newValue.replacingOccurrences(of: ",", with: ".")
                                    if filtered != currentAmount {
                                        currentAmount = filtered
                                    }
                                }
                        }
                    }
                } else {
                    Section(header: Text("Monthly Saving Goal")) {
                        HStack {
                            Text("Target: \(dataManager.currencySymbol)")
                                .foregroundColor(.secondary)
                            TextField("0.00", text: $targetAmount)
                                .keyboardType(.decimalPad)
                                .onChange(of: targetAmount) { newValue in
                                    let filtered = newValue.replacingOccurrences(of: ",", with: ".")
                                    if filtered != targetAmount {
                                        targetAmount = filtered
                                    }
                                }
                        }
                    }
                }
                
                Section {
                    Button("Delete Goal", role: .destructive) {
                        dataManager.deleteSavingGoal(goal)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Edit Goal")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                currentAmount = String(goal.currentAmount)
                targetAmount = String(goal.targetAmount)
                name = goal.name
                targetDate = goal.targetDate
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
                }
            }
        }
    }
    
    private func saveChanges() {
        guard let targetAmountValue = Double(targetAmount) else { return }
        let currentAmountValue = Double(currentAmount) ?? 0
        
        var updatedGoal = goal
        updatedGoal.targetAmount = targetAmountValue
        updatedGoal.name = goal.isGeneric ? goal.name : name
        updatedGoal.targetDate = goal.isGeneric ? goal.targetDate : targetDate
        
        if !goal.isGeneric {
            updatedGoal.currentAmount = currentAmountValue
        }
        
        dataManager.updateSavingGoal(updatedGoal)
        dismiss()
    }
}

#Preview {
    SavingGoalsView()
        .environmentObject(DataManager())
}