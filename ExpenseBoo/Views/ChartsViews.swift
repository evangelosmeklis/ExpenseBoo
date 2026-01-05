import SwiftUI
import Charts

struct MonthlyPerformanceChart: View {
    let stats: [MonthlyStats]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Income vs Expenses")
                .font(AppTheme.Fonts.headline(18))
                .foregroundColor(AppTheme.Colors.primaryText)
            
            Chart {
                ForEach(stats) { stat in
                    // Income Bar
                    BarMark(
                        x: .value("Month", stat.monthName),
                        y: .value("Amount", stat.income)
                    )
                    .foregroundStyle(AppTheme.Colors.income)
                    .position(by: .value("Type", "Income"))
                    .cornerRadius(4)
                    
                    // Expense Bar
                    BarMark(
                        x: .value("Month", stat.monthName),
                        y: .value("Amount", stat.expenses)
                    )
                    .foregroundStyle(AppTheme.Colors.expense)
                    .position(by: .value("Type", "Expense"))
                    .cornerRadius(4)
                }
            }
            .chartForegroundStyleScale([
                "Income": AppTheme.Colors.income,
                "Expense": AppTheme.Colors.expense
            ])
            .chartLegend(position: .top, alignment: .leading)
            .frame(height: 250)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct ProfitTrendChart: View {
    let stats: [MonthlyStats]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Profit/Loss Trend")
                .font(AppTheme.Fonts.headline(18))
                .foregroundColor(AppTheme.Colors.primaryText)
            
            Chart {
                RuleMark(y: .value("Break Even", 0))
                    .foregroundStyle(AppTheme.Colors.secondaryText.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                
                ForEach(stats) { stat in
                    LineMark(
                        x: .value("Month", stat.monthName),
                        y: .value("Balance", stat.profitLoss)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(AppTheme.Colors.electricCyan)
                    .lineStyle(StrokeStyle(lineWidth: 3))

                    PointMark(
                        x: .value("Month", stat.monthName),
                        y: .value("Balance", stat.profitLoss)
                    )
                    .foregroundStyle(stat.profitLoss >= 0 ? AppTheme.Colors.profit : AppTheme.Colors.loss)
                    .symbolSize(60)
                }
            }
            .frame(height: 250)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}
