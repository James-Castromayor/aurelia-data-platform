# Aurelia RAID Log

## Purpose

This document tracks major risks, assumptions, issues, and dependencies affecting the Aurelia Enterprise Cloud Data & Analytics Platform.

---

## Risks

| ID    | Risk                                                              | Impact | Probability | Mitigation                                                                                 |
| ----- | ----------------------------------------------------------------- | ------ | ----------- | ------------------------------------------------------------------------------------------ |
| R-001 | Cloud resources generate unexpected charges                       | High   | Medium      | Prefer free/local resources, configure budgets and alerts, suspend/delete unused resources |
| R-002 | API limits interrupt ingestion                                    | Medium | Medium      | Implement pagination, retry handling, rate-limit awareness and incremental extraction      |
| R-003 | Poor synthetic data produces unrealistic analytics                | High   | Medium      | Define business rules before generating data and validate distributions                    |
| R-004 | Cross-system identifiers become inconsistent                      | High   | Medium      | Maintain explicit source identifiers and enterprise mappings                               |
| R-005 | Secrets are accidentally committed                                | High   | Low         | `.gitignore`, `.env`, GitHub Secrets and secret-scanning practices                         |
| R-006 | Portfolio scope becomes too large                                 | High   | Medium      | Prioritize core data stack and defer nonessential technologies                             |
| R-007 | Snowflake trial expires before useful implementation is completed | Medium | Medium      | Delay account activation until prerequisite phases are complete                            |
| R-008 | AI produces unsupported business answers                          | High   | Medium      | Ground responses, provide citations, restrict data sources and evaluate retrieval          |
| R-009 | Source schema changes break ingestion                             | Medium | Medium      | Validation, logging, schema checks and controlled error handling                           |

---

## Assumptions

| ID    | Assumption                                                                                                      |
| ----- | --------------------------------------------------------------------------------------------------------------- |
| A-001 | All portfolio business data will be synthetic.                                                                  |
| A-002 | HubSpot free capabilities will be sufficient for the required CRM demonstrations or the design will be adapted. |
| A-003 | Local development will be used whenever cloud deployment provides little additional learning value.             |
| A-004 | Batch processing is sufficient for most analytical workloads.                                                   |
| A-005 | Near-real-time processing will only be introduced for business processes that genuinely benefit from it.        |
| A-006 | Power BI Desktop/local development is sufficient for the initial BI implementation.                             |
| A-007 | The Operations Platform is a supporting source system rather than the primary portfolio deliverable.            |

---

## Issues

No material implementation issues are currently open.

Issues discovered during development will be recorded here or tracked through GitHub Issues as appropriate.

---

## Dependencies

| ID    | Dependency                 | Required Before                      |
| ----- | -------------------------- | ------------------------------------ |
| D-001 | Business domain model      | Synthetic data generation            |
| D-002 | Operational schema         | Operations ingestion                 |
| D-003 | HubSpot configuration      | CRM API ingestion                    |
| D-004 | Python ingestion framework | Cloud source ingestion               |
| D-005 | Azure landing design       | Snowflake cloud ingestion            |
| D-006 | Snowflake RAW data         | dbt transformations                  |
| D-007 | dbt dimensional models     | Power BI analytical implementation   |
| D-008 | Trusted analytical models  | Structured AI analytics              |
| D-009 | Business documents         | RAG implementation                   |
| D-010 | Stable platform components | Final CI/CD and deployment hardening |

## Review Approach

The RAID log should be reviewed at major project milestones.

New risks, assumptions, issues, and dependencies should be added as they are discovered rather than waiting until the end of the project.
