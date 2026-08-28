# Aurelia Local Development Environment

## Purpose

This document describes the local development environment used to build the Aurelia Enterprise Cloud Data & Analytics Platform.

The project prioritizes local development and open-source tooling where practical to reduce cloud cost and improve reproducibility.

## Core Local Tools

| Tool               | Purpose                                               |
| ------------------ | ----------------------------------------------------- |
| Git                | Version control                                       |
| GitHub             | Remote repository and collaboration                   |
| Visual Studio Code | Primary development editor                            |
| Python             | Data ingestion, APIs, automation and data engineering |
| Docker Desktop     | Local containerized services                          |
| PostgreSQL         | Operational source-system database                    |
| Database Client    | SQL development and database administration           |
| .NET SDK           | ASP.NET Core Operations API                           |
| Node.js / npm      | React front-end development                           |

## Tools Added Later

The following tools will be introduced only when required:

* dbt
* n8n
* Azure CLI
* Snowflake tooling
* Power BI Desktop
* PySpark
* Microsoft Fabric tooling
* AI/RAG dependencies

## Environment Principles

1. Install technologies progressively.
2. Avoid unnecessary global dependencies.
3. Use Python virtual environments for Python projects.
4. Use environment variables for configuration.
5. Never store secrets in source control.
6. Prefer Docker for services where containerization improves reproducibility.
7. Document required versions once implementation dependencies require them.
8. Keep development configuration separate from production architecture.

## Planned Local Architecture

```text
Developer Workstation

VS Code
   │
   ├── Git
   │
   ├── Python
   │
   ├── .NET
   │
   ├── Node.js
   │
   └── Docker
          │
          ├── PostgreSQL
          └── n8n (later)
```

## Cloud Boundary

Local development resources are separate from future cloud resources.

```text
LOCAL DEVELOPMENT

Python / PostgreSQL / Docker
          │
          │ controlled integration
          ▼
────────────────────────────
       CLOUD BOUNDARY
────────────────────────────
          │
          ▼
Azure → Snowflake → Analytics
```

Cloud services will only be introduced when their corresponding implementation phase begins.
