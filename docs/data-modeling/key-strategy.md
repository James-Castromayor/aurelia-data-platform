# Aurelia Data Key and Identity Strategy

## 1. Purpose

This document defines how Aurelia identifies business entities within individual source systems and across the enterprise analytical platform.

The strategy distinguishes operational identifiers from analytical warehouse keys.

---

# 2. Primary Key

A primary key uniquely identifies a row inside a system.

Example:

```text
Operations Client

client_id
---------
CLI-000127
```

`CLI-000127` identifies that client inside the Aurelia Operations Platform.

---

# 3. Foreign Key

A foreign key connects one entity to another.

Example:

```text
PROJECT

project_id
client_id
project_name
```

If:

```text
project_id = PRJ-1001
client_id  = CLI-000127
```

then `client_id` connects the project to its client.

Conceptually:

```text
CLIENT
CLI-000127
     │
     │ client_id
     ▼
PROJECT
PRJ-1001
```

---

# 4. Source-System Key

A source-system key is an identifier assigned by a particular source application.

The same real-world organization may therefore have several source keys.

Example:

```text
HubSpot

company_id = 845923


Operations

client_id = CLI-000127


Finance

customer_id = CUST-00481
```

These identifiers should be retained during ingestion for lineage and reconciliation.

---

# 5. Business Key

A business key identifies a business entity using a stable business-recognizable identifier where one exists.

Examples could include:

```text
employee_number = EMP-00127
project_number  = PRJ-2026-0048
invoice_number  = INV-2026-00152
```

Business keys should not automatically be assumed to be globally unique unless the business rules guarantee this.

---

# 6. Enterprise Identifier

Aurelia may assign an enterprise-level identifier when records representing the same business entity need to be linked across systems.

Example:

```text
enterprise_client_id = CLIENT-000127
```

Mapping:

| System     | Source Identifier | Enterprise Client ID |
| ---------- | ----------------- | -------------------- |
| HubSpot    | 845923            | CLIENT-000127        |
| Operations | CLI-000127        | CLIENT-000127        |
| Finance    | CUST-00481        | CLIENT-000127        |

This allows cross-system integration without forcing source applications to share the same physical primary key.

---

# 7. Surrogate Key

The analytical warehouse may create its own technical key.

Example:

```text
dim_client

client_key             = 1027
enterprise_client_id   = CLIENT-000127
client_name            = Northstar Technologies
```

`client_key` is the warehouse surrogate key.

It has analytical meaning only as an identifier.

Example:

```text
DIM_CLIENT

client_key | enterprise_client_id
-----------|---------------------
1027       | CLIENT-000127
```

Facts can reference:

```text
FACT_INVOICE

invoice_key
client_key
project_key
invoice_amount
```

rather than repeatedly carrying long source-system identifiers.

---

# 8. Why Source Keys Are Not Warehouse Keys

A HubSpot identifier should not become the universal analytical key.

For example:

```text
HubSpot company_id = 845923
```

should not automatically become:

```text
dim_client.client_key = 845923
```

because:

* HubSpot is only one source system.
* Another CRM could replace HubSpot.
* Some clients may originate outside CRM.
* Source identifiers can follow source-specific rules.
* Historical warehouse records may require multiple versions of the same business entity.

The warehouse should control its own analytical keys.

---

# 9. Example Cross-System Identity Flow

```text
                 REAL-WORLD CLIENT
                        │
                        ▼
              Northstar Technologies
                        │
       ┌────────────────┼────────────────┐
       ▼                ▼                ▼
    HubSpot         Operations         Finance

    845923          CLI-000127        CUST-00481
       │                │                │
       └────────────────┼────────────────┘
                        ▼
                Identity Mapping

               CLIENT-000127
                        │
                        ▼
                    dim_client

                  client_key
                      1027
```

---

# 10. Analytical Example

The warehouse might contain:

```text
dim_client

client_key:            1027
enterprise_client_id:  CLIENT-000127
client_name:           Northstar Technologies
```

and:

```text
fact_invoice

invoice_number: INV-2026-00152
client_key:     1027
amount:         100000
```

while:

```text
fact_sales_pipeline

opportunity_id: OPP-9812
client_key:     1027
pipeline_value: 150000
```

Both analytical facts can now be analyzed through the same conformed client dimension.

---

# 11. Slowly Changing Dimensions

Surrogate keys also become important when historical attribute changes must be preserved.

Suppose:

```text
Northstar Technologies
Region = Australia
```

later changes to:

```text
Region = APAC
```

If historical reporting must preserve the previous classification, the warehouse may contain:

| client_key | enterprise_client_id | region    | valid_from | valid_to   |
| ---------: | -------------------- | --------- | ---------- | ---------- |
|       1027 | CLIENT-000127        | Australia | 2025-01-01 | 2026-06-30 |
|       1189 | CLIENT-000127        | APAC      | 2026-07-01 | Current    |

The business entity remains:

```text
CLIENT-000127
```

but the warehouse has two surrogate keys representing two historical versions.

This is a Slowly Changing Dimension Type 2 pattern.

We will only use SCD Type 2 where historical preservation provides genuine analytical value.

---

# 12. Key Strategy Principles

1. Source-system identifiers must be retained for lineage.

2. Source-system keys should not automatically become enterprise analytical keys.

3. Stable business identifiers should be documented explicitly.

4. Cross-system mappings should be controlled and traceable.

5. Warehouse dimensions should use surrogate keys where appropriate.

6. Facts should reference analytical dimensions using the intended dimensional-model key strategy.

7. Slowly Changing Dimensions should only be introduced where historical attribute tracking is useful.

8. Keys must not be confused with business measures or descriptive attributes.
