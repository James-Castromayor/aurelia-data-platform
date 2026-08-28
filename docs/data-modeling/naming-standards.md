# Aurelia Data Naming Standards

## 1. Purpose

This document establishes naming conventions for databases, tables, models, columns, files, and analytical objects.

Consistent naming improves readability, maintainability, discoverability, and lineage.

## 2. General Rules

Prefer:

* lowercase names
* snake_case
* descriptive names
* consistent terminology
* explicit identifiers

Avoid:

```text
tblCustomer
CustomerTable
custTbl
T_CUST
final_final_customer
data2
temp_new
```

Prefer:

```text
client
project
timesheet_entry
resource_allocation
```

## 3. Operational PostgreSQL

Operational tables use singular business-entity names.

Examples:

```text
client
contract
project
employee
skill
employee_skill
resource_allocation
employee_capacity
timesheet_entry
invoice
invoice_line
payment
payment_allocation
```

Primary keys:

```text
client_id
project_id
employee_id
invoice_id
```

Foreign keys use the referenced entity name:

```text
project.client_id
project.project_manager_id
invoice.client_id
timesheet_entry.employee_id
```

## 4. Business Identifiers

Business-facing identifiers should clearly communicate their purpose.

Examples:

```text
employee_number
project_number
contract_number
invoice_number
journal_number
```

Avoid ambiguous names such as:

```text
number
code1
identifier
ref
```

## 5. Boolean Columns

Boolean columns should communicate a clear yes/no condition.

Examples:

```text
is_billable
is_active
is_approved
is_certified
```

Avoid unclear names such as:

```text
flag
status_flag
yes_no
```

## 6. Dates and Timestamps

Use descriptive suffixes.

Dates:

```text
start_date
end_date
work_date
invoice_date
due_date
payment_date
```

Timestamps:

```text
created_at
updated_at
submitted_at
approved_at
ingested_at
```

## 7. Snowflake RAW

RAW tables should preserve source-system identity.

Conceptual examples:

```text
raw.hubspot_company
raw.hubspot_contact
raw.hubspot_deal

raw.operations_project
raw.operations_employee
raw.operations_timesheet_entry

raw.finance_invoice
raw.finance_payment
raw.finance_gl_entry
```

RAW ingestion metadata may include:

```text
_source_system
_source_file
_batch_id
_ingested_at
```

## 8. dbt Source Models

Source definitions represent externally loaded data.

Example:

```text
source('operations', 'project')
source('finance', 'invoice')
```

## 9. dbt Staging Models

Pattern:

```text
stg_<source>__<entity>
```

Examples:

```text
stg_hubspot__companies
stg_hubspot__deals

stg_operations__projects
stg_operations__employees
stg_operations__timesheet_entries

stg_finance__invoices
stg_finance__payments
```

Staging models primarily:

* rename
* cast
* standardize
* clean
* perform basic deduplication

They should contain limited business logic.

## 10. dbt Intermediate Models

Pattern:

```text
int_<business_concept>
```

Examples:

```text
int_project_labor_cost
int_employee_weekly_capacity
int_resource_utilization
int_invoice_payment_status
```

Intermediate models contain reusable transformation and business logic.

## 11. Dimensional Models

Dimensions:

```text
dim_<entity>
```

Examples:

```text
dim_date
dim_employee
dim_client
dim_project
dim_service
```

Facts:

```text
fact_<business_process>
```

Examples:

```text
fact_timesheet
fact_resource_plan
fact_capacity
fact_invoice
fact_payment
fact_project_cost
```

## 12. Analytical Marts

Pattern:

```text
mart_<subject>
```

Examples:

```text
mart_sales_pipeline
mart_resource_utilization
mart_project_profitability
mart_accounts_receivable
mart_executive_kpis
```

## 13. Warehouse Keys

Warehouse surrogate keys use:

```text
<entity>_key
```

Examples:

```text
employee_key
client_key
project_key
date_key
service_key
```

Source identifiers remain explicitly identifiable where required:

```text
source_project_id
source_client_id
```

Enterprise identifiers use:

```text
enterprise_client_id
enterprise_project_id
```

when an enterprise-level mapping is required.

## 14. Measures

Use descriptive business terminology.

Prefer:

```text
planned_hours
actual_hours
billable_hours
capacity_hours
invoice_amount
payment_amount
labor_cost
gross_profit
gross_margin
```

Avoid:

```text
value1
amount2
metric
total_value
calc
```

## 15. Repository Naming

Folders should represent architectural responsibility rather than individual developers.

Examples:

```text
ingestion/
automation/
dbt/
app/
powerbi/
ai/
infrastructure/
docs/
```

## 16. Guiding Principle

A developer or analyst unfamiliar with the implementation should be able to make a reasonable guess about what an object contains from its name alone.

Clarity is more important than abbreviation.
