# Supabase API Documentation

## Overview

TradeWFriend uses **Supabase** as its backend — a managed PostgreSQL 16 instance with auto-generated RESTful APIs, real-time subscriptions, and Row-Level Security (RLS).

Base URL: `https://<project-id>.supabase.co/rest/v1/`

Authentication: `apikey: <SUPABASE_ANON_KEY>` (header)

---

## Tables

### `employees`

Employee/owner accounts with PIN-based authentication.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | `uuid` | `PK DEFAULT gen_random_uuid()` | Unique identifier |
| `phone` | `text` | `UNIQUE NOT NULL` | Normalized Rwandan phone (e.g. `0788123456`) |
| `display_name` | `text` | `NOT NULL` | Employee display name |
| `business_name` | `text` | `NOT NULL` | Business/trade name |
| `pin_hash` | `text` | `NOT NULL` | SHA-256(`{phone}:{pin}`) |
| `role` | `text` | `NOT NULL DEFAULT 'employee'` | `owner` \| `employee` |
| `created_by` | `text` | `NOT NULL` | Phone of the creator account |
| `email` | `text` | | Optional email address |
| `is_active` | `bool` | `NOT NULL DEFAULT true` | Soft-delete flag |
| `created_at` | `timestamptz` | `DEFAULT now()` | Record creation timestamp |

**Indexes:**
- `idx_employees_phone` on `phone`

**RLS Policy:**
```sql
-- Employees can read their own business's employees
CREATE POLICY "Read own business employees"
  ON employees FOR SELECT
  USING (created_by = current_setting('app.current_phone', true)::text
         OR phone = current_setting('app.current_phone', true)::text);

-- Owners can insert new employees
CREATE POLICY "Owners can insert employees"
  ON employees FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM employees e
      WHERE e.phone = current_setting('app.current_phone', true)::text
      AND e.role = 'owner'
    )
  );
```

---

### `inventory_items`

Product catalog with stock tracking.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | `uuid` | `PK DEFAULT gen_random_uuid()` | Unique identifier |
| `item_name` | `text` | `NOT NULL` | Product name |
| `quantity` | `int4` | `NOT NULL DEFAULT 0` | Current stock quantity |
| `cost_price` | `float8` | `NOT NULL DEFAULT 0` | Unit cost price in RWF |
| `category` | `text` | | Product category |
| `subcategory` | `text` | | Product subcategory |
| `created_at` | `timestamptz` | `DEFAULT now()` | Record creation timestamp |

**Sample Queries:**

```sql
-- All products with low stock (<= 5 units)
SELECT * FROM inventory_items WHERE quantity <= 5 ORDER BY quantity ASC;

-- Total inventory value
SELECT SUM(quantity * cost_price) AS total_value FROM inventory_items;

-- Products by category
SELECT category, COUNT(*) AS count, SUM(quantity) AS total_stock
FROM inventory_items GROUP BY category;
```

---

### `sales`

Transaction records for each sale event.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | `uuid` | `PK DEFAULT gen_random_uuid()` | Unique identifier |
| `item_name` | `text` | `NOT NULL` | Product name at time of sale |
| `quantity` | `int4` | `NOT NULL` | Number of units sold |
| `sale_price` | `float8` | `NOT NULL` | Unit sale price in RWF |
| `cost_price` | `float8` | `NOT NULL` | Unit cost price in RWF |
| `created_at` | `timestamptz` | `DEFAULT now()` | Sale timestamp |

**Sample Queries:**

```sql
-- Today's revenue
SELECT COALESCE(SUM(sale_price * quantity), 0) AS today_revenue
FROM sales WHERE created_at::date = CURRENT_DATE;

-- 7-day sales breakdown
SELECT DATE(created_at) AS day,
       SUM(sale_price * quantity) AS revenue,
       COUNT(*) AS transactions
FROM sales
WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY DATE(created_at)
ORDER BY day;

-- Profit per product
SELECT item_name,
       SUM((sale_price - cost_price) * quantity) AS total_profit
FROM sales GROUP BY item_name ORDER BY total_profit DESC;
```

---

### `customers`

Customer profiles with debt tracking.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | `uuid` | `PK DEFAULT gen_random_uuid()` | Unique identifier |
| `name` | `text` | `NOT NULL` | Customer name |
| `phone` | `text` | | Contact phone number |
| `email` | `text` | | Contact email address |
| `amount` | `float8` | `NOT NULL DEFAULT 0` | Outstanding debt amount in RWF |
| `total_paid` | `float8` | `NOT NULL DEFAULT 0` | Cumulative payments received |
| `business_id` | `text` | | Scopes customer to a business |
| `is_paid` | `bool` | `DEFAULT false` | Quick payment status flag |
| `due_date` | `date` | | Expected repayment date |
| `created_at` | `timestamptz` | `DEFAULT now()` | Record creation timestamp |

**Sample Queries:**

```sql
-- Customers with outstanding debt
SELECT id, name, phone, amount, due_date
FROM customers
WHERE amount > 0
ORDER BY amount DESC;

-- Total outstanding debt
SELECT COALESCE(SUM(amount), 0) AS total_outstanding
FROM customers WHERE amount > 0;

-- Overdue customers (past due date)
SELECT id, name, phone, amount, due_date
FROM customers
WHERE amount > 0 AND due_date < CURRENT_DATE
ORDER BY due_date ASC;
```

---

### `debt_payments`

Individual payment records against customer debts.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | `uuid` | `PK DEFAULT gen_random_uuid()` | Unique identifier |
| `customer_id` | `uuid` | `FK -> customers(id) NOT NULL` | Associated customer |
| `amount` | `float8` | `NOT NULL` | Payment amount in RWF |
| `created_at` | `timestamptz` | `DEFAULT now()` | Payment timestamp |

**Indexes:**
- `idx_debt_payments_customer` on `customer_id`

**Sample Queries:**

```sql
-- Full payment history for a customer
SELECT dp.id, dp.amount, dp.created_at
FROM debt_payments dp
WHERE dp.customer_id = '<customer-uuid>'
ORDER BY dp.created_at DESC;

-- Total payments collected in a period
SELECT COALESCE(SUM(amount), 0) AS total_collected
FROM debt_payments
WHERE created_at >= date_trunc('month', CURRENT_DATE);
```

---

### `app_settings`

Key-value configuration store for business settings.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | `uuid` | `PK DEFAULT gen_random_uuid()` | Unique identifier |
| `setting_key` | `text` | `UNIQUE NOT NULL` | Configuration key |
| `setting_value` | `text` | `NOT NULL` | Configuration value (parsed by app) |

**Sample Queries:**

```sql
-- Get a specific setting
SELECT setting_value FROM app_settings WHERE setting_key = 'daily_sales_target';

-- All settings
SELECT * FROM app_settings;
```

---

## Realtime Subscriptions

Supabase realtime can be enabled per table for live dashboard updates:

```dart
// Dart client subscription example
Supabase.instance.client
    .channel('dashboard-updates')
    .on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
        event: '*',
        schema: 'public',
        table: 'sales',
      ),
      (payload) {
        // Refresh dashboard stats
      },
    )
    .subscribe();
```

Tables recommended for realtime:
- `sales` — Update dashboard KPIs live
- `inventory_items` — Reflect stock changes immediately
- `debt_payments` — Update customer ledger in real time

---

## Row-Level Security

Enable RLS on all tables with the following pattern:

```sql
-- Helper function to set current employee context
CREATE OR REPLACE FUNCTION app.set_current_phone(phone text)
RETURNS void AS $$
  SELECT set_config('app.current_phone', phone, false);
$$ LANGUAGE sql;

-- Generic policy: user can only access their business's data
-- (Assumes a business_id column or created_by linkage)
CREATE POLICY "Business scoped access"
  ON inventory_items FOR ALL
  USING (
    created_by = current_setting('app.current_phone', true)::text
    OR EXISTS (
      SELECT 1 FROM employees e
      WHERE e.phone = current_setting('app.current_phone', true)::text
      AND e.business_name = inventory_items.business_name
    )
  );
```

---

## Error Codes

| Status | Code | Meaning |
|--------|------|---------|
| `200` | — | Success |
| `201` | — | Created (INSERT) |
| `204` | — | No content (DELETE success) |
| `400` | `PGRST100` | Malformed request body |
| `401` | `PGRST101` | Unauthenticated (missing/wrong API key) |
| `403` | `PGRST102` | RLS policy violation |
| `404` | `PGRST103` | Record not found |
| `406` | `PGRST104` | Not acceptable (invalid Accept header) |
| `409` | `PGRST105` | Unique constraint violation |
| `429` | — | Rate limited |
