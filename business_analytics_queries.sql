-- ====================================================================
-- Business Analytics & Financial Reporting Queries
-- Author: Robert Messina
-- Description: Analytical SQL queries for customer revenue aggregation,
--              departmental cost variance, and month-over-month growth.
-- ====================================================================

-- --------------------------------------------------------------------
-- Query 1: Top Revenue-Generating Customers with Lifetime Value
-- --------------------------------------------------------------------
SELECT 
    c.customer_id,
    c.company_name,
    c.industry,
    COUNT(o.order_id) AS total_orders,
    SUM(o.order_amount) AS total_revenue,
    ROUND(AVG(o.order_amount), 2) AS avg_order_value
FROM customers c
INNER JOIN orders o 
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.company_name, c.industry
HAVING SUM(o.order_amount) >= 10000
ORDER BY total_revenue DESC;


-- --------------------------------------------------------------------
-- Query 2: Departmental Budget vs. Actual Expenses (CTE Analysis)
-- --------------------------------------------------------------------
WITH MonthlyExpenses AS (
    SELECT 
        department_id,
        DATE_TRUNC('month', transaction_date) AS fiscal_month,
        SUM(amount) AS actual_spend
    FROM general_ledger
    WHERE account_type = 'Expense'
    GROUP BY department_id, DATE_TRUNC('month', transaction_date)
)
SELECT 
    d.department_name,
    m.fiscal_month,
    b.budget_amount,
    m.actual_spend,
    (b.budget_amount - m.actual_spend) AS variance,
    CASE 
        WHEN m.actual_spend > b.budget_amount THEN 'Favorable / Under Budget'
        ELSE 'Unfavorable / Over Budget'
    END AS budget_status
FROM MonthlyExpenses m
JOIN departments d 
    ON m.department_id = d.department_id
JOIN budgets b 
    ON m.department_id = b.department_id 
   AND m.fiscal_month = b.budget_month
ORDER BY m.fiscal_month DESC, variance ASC;


-- --------------------------------------------------------------------
-- Query 3: Running Total Revenue and Rank by Month (Window Function)
-- --------------------------------------------------------------------
SELECT 
    order_date,
    daily_revenue,
    SUM(daily_revenue) OVER (ORDER BY order_date) AS running_total_revenue,
    DENSE_RANK() OVER (PARTITION BY DATE_TRUNC('month', order_date) ORDER BY daily_revenue DESC) AS daily_revenue_rank
FROM (
    SELECT 
        CAST(order_timestamp AS DATE) AS order_date,
        SUM(order_amount) AS daily_revenue
    FROM sales_transactions
    GROUP BY CAST(order_timestamp AS DATE)
) subquery
ORDER BY order_date ASC;
