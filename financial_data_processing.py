"""
Financial Data Processing & Variance Analysis Script
Author: Robert Messina
Description: Cleans transactional ledger data, calculates net profit margins,
             and performs departmental budget variance analysis.
"""

import pandas as pd
import numpy as np

# 1. Create simulated financial ledger data
data = {
    'Transaction_ID': [1001, 1002, 1003, 1004, 1005, 1006],
    'Department': ['Marketing', 'Operations', 'Finance', 'Marketing', 'Operations', 'Finance'],
    'Revenue': [150000.00, 220000.00, 180000.00, 165000.00, 210000.00, 195000.00],
    'Actual_Expenses': [112000.00, 185000.00, 130000.00, 128000.00, 175000.00, 135000.00],
    'Budgeted_Expenses': [110000.00, 190000.00, 135000.00, 120000.00, 180000.00, 140000.00]
}

df = pd.DataFrame(data)

# 2. Financial Calculations
df['Net_Profit'] = df['Revenue'] - df['Actual_Expenses']
df['Profit_Margin_%'] = (df['Net_Profit'] / df['Revenue'] * 100).round(2)

# Expense Variance (Negative = Over Budget, Positive = Under Budget)
df['Budget_Variance'] = df['Budgeted_Expenses'] - df['Actual_Expenses']
df['Variance_Status'] = np.where(df['Budget_Variance'] >= 0, 'Under Budget', 'Over Budget')

# 3. Departmental Aggregation
dept_summary = df.groupby('Department').agg(
    Total_Revenue=('Revenue', 'sum'),
    Total_Expenses=('Actual_Expenses', 'sum'),
    Total_Net_Profit=('Net_Profit', 'sum'),
    Total_Variance=('Budget_Variance', 'sum')
).reset_index()

dept_summary['Overall_Margin_%'] = (dept_summary['Total_Net_Profit'] / dept_summary['Total_Revenue'] * 100).round(2)

# 4. Print Summary Outputs
if __name__ == '__main__':
    print("=" * 60)
    print("FINANCIAL PERFORMANCE SUMMARY BY DEPARTMENT")
    print("=" * 60)
    print(dept_summary.to_string(index=False))
    print("\n" + "=" * 60)
    print("DETAILED TRANSACTIONAL LEDGER")
    print("=" * 60)
    print(df[['Transaction_ID', 'Department', 'Revenue', 'Net_Profit', 'Profit_Margin_%', 'Variance_Status']].to_string(index=False))
