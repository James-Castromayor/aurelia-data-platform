Aurelia Data Platform — Learning Scope & Table of Contents

Purpose

This document is the master learning scope for the Aurelia portfolio.

It acts as a checklist of the concepts, technologies, and professional practices we intend to cover while building the platform.

0. Project Foundation

Project Management

Project charter

Scope / out-of-scope

Stakeholder register

RACI

RAID log

Project kickoff

Delivery milestones

Definition of Done

Business Analysis

Business requirements

Functional requirements

Non-functional requirements

As-Is process

To-Be process

Swimlane

User stories

Acceptance criteria

Requirements Traceability Matrix

UAT plan

Architecture

System context

Solution architecture

Environment strategy

Architecture Decision Records

Deployment architecture

Production architecture

Git & GitHub

Repository initialization

.gitignore

meaningful commits

remote repository

feature branches

pull requests

code review workflow

GitHub Issues

GitHub Actions

1. Business & Data Modeling

Data Modeling Foundations

Business domain model

Entity vs table

Cardinality

One-to-many

Many-to-many

Associative entities

Data grain

Primary keys

Foreign keys

Business / natural keys

Source-system keys

Enterprise identifiers

Surrogate keys

1NF

2NF

3NF

Logical model refinement

Physical model

ER diagram

Data dictionary

Naming standards

Dimensional Modeling Foundations

Facts

Dimensions

Fact grain

Star schema

Snowflake schema

Conformed dimensions

Degenerate dimensions

Role-playing dimensions

Slowly Changing Dimension Type 1

Slowly Changing Dimension Type 2

Additive measures

Semi-additive measures

Non-additive measures

Fact-to-fact fanout

Bridge tables

Synthetic Data

Company profile

Employees

Clients

Opportunities

Projects

Timesheets

Allocations

Capacity

Budgets

Invoices

Payments

GL transactions

Data-quality exceptions

Seasonality

Business scenarios

2. PostgreSQL Operational Source

Database Fundamentals

PostgreSQL setup

Schemas

Tables

Data types

Constraints

Primary / foreign keys

Unique constraints

Check constraints

Indexes

Views

Transactions

ACID concepts

SQL

SELECT

JOIN

GROUP BY

CASE

CTE

Subqueries

Window functions

Aggregations

Date functions

NULL handling

INSERT / UPDATE / DELETE

UPSERT

Query plans

Basic optimization

3. HubSpot CRM

CRM concepts

Companies

Contacts

Deals

Deal stages

Pipelines

Custom properties

REST API

Authentication

Pagination

Rate limits

Webhooks

Closed-Won integration

Cross-system mapping

4. Python Data Engineering

Python

Virtual environments

Packages

Functions

Classes where useful

Type hints

Configuration

Environment variables

Logging

Error handling

Unit testing

API Engineering

HTTP methods

REST

JSON

Authentication

Pagination

Retry

Exponential backoff

Rate limits

Timeouts

Pipeline Engineering

Full load

Incremental load

Watermarks

Idempotency

Batch IDs

Audit metadata

Schema validation

File ingestion

CSV

JSON

Parquet

Error handling

Reprocessing

5. n8n Workflow Automation

Self-hosted n8n

Docker deployment

Credentials

HTTP Request node

Webhooks

Scheduled workflows

Conditional logic

API orchestration

Closed-Won workflow

Notifications

Failure workflows

Retry strategy

Workflow exports and Git

6. Azure Data Platform

Core Azure

Subscription / billing safety

Resource groups

Regions

RBAC

Managed identities

Key Vault concepts

Storage

Azure Blob Storage

ADLS Gen2

Containers

Folder conventions

Landing zones

RAW files

Parquet

Lifecycle management

Operations

Azure CLI

Monitoring concepts

Cost management

Resource shutdown / deletion

DEV / TEST / PROD concepts

7. Snowflake

Fundamentals

Databases

Schemas

Tables

Warehouses

Roles

Users

Storage vs compute

Virtual warehouses

Data Loading

Stages

File formats

COPY INTO

Azure integration

RAW schemas

ingestion metadata

incremental ingestion

Snowflake Engineering

Micro-partitions

pruning

clustering concepts

query history

warehouse sizing

auto-suspend

cost control

Time Travel concepts

zero-copy cloning concepts

8. dbt Analytics Engineering

dbt Fundamentals

Project structure

profiles

models

ref()

source()

DAG

materializations

Layers

RAW

STAGING

INTERMEDIATE

ANALYTICS

Data Quality

not_null

unique

relationships

accepted_values

custom tests

Advanced dbt

macros

Jinja

seeds

snapshots

incremental models

documentation

lineage

exposures

contracts concepts

9. Dimensional Data Warehouse

dim_date

dim_employee

dim_client

dim_project

dim_service

dim_business_unit

dim_cost_center

dim_account

dim_currency

fact_sales_pipeline

fact_resource_plan

fact_capacity

fact_timesheet

fact_project_cost

fact_invoice

fact_payment

fact_gl_transaction

project financial marts

profitability

utilization

budget vs actual

10. Power BI

Modeling

Power Query

Star schema

Relationships

Date table

Measures vs calculated columns

DAX

CALCULATE

filter context

row context

SUMX

DIVIDE

time intelligence

variance measures

utilization measures

profitability measures

Dashboards

Executive dashboard

Sales pipeline

Project performance

Resource utilization

Finance / AR

Profitability

Performance

model size

relationship design

measure optimization

Import vs DirectQuery concepts

11. Operations Application

Backend

ASP.NET Core

REST API

Entity Framework Core

PostgreSQL

DTOs

validation

logging

API documentation

Frontend

React

TypeScript

API calls

forms

project management UI

resource allocation UI

timesheet UI

Deployment

Docker

environment configuration

local deployment

free/public demo strategy

12. PySpark & Microsoft Fabric Extension

Why Spark exists

DataFrames

transformations

lazy evaluation

partitions

Parquet

Spark SQL

when Spark is justified

Fabric architecture overview

OneLake

Lakehouse

Warehouse

notebooks

pipelines

Snowflake / Fabric comparison

13. RAG

RAG architecture

documents

chunking

embeddings

vector databases

semantic search

retrieval

prompt grounding

citations

hallucination controls

document ingestion

access control

14. AI Agents

Agent concepts

Tool calling

Structured data retrieval

Snowflake / API tools

Read-only agents

least privilege

confirmation before writes

human approval

audit logging

failure handling

agent vs workflow distinction

15. Testing, Security & CI/CD

Testing

Unit tests

Integration tests

Data tests

API tests

UAT

regression testing

Security

.env

GitHub Secrets

credential rotation

RBAC

least privilege

secret scanning

data classification concepts

audit logging

CI/CD

GitHub Actions

Python tests

dbt tests

application build

deployment workflow

environment promotion

approval gates

rollback strategy

16. Monitoring & Operations

Pipeline logging

batch audit table

alerts

SLA concepts

freshness monitoring

failure recovery

reprocessing

runbooks

incident response

data lineage

observability concepts

17. Architecture & Production Design

System context

Container/component diagrams

data-flow diagram

networking concepts

private endpoints

managed identity

Key Vault

DEV / TEST / PROD

scalability

reliability

HA / DR concepts

RPO / RTO

cost optimization

ADRs

production differences

18. Portfolio & Career Packaging

GitHub

professional README

architecture diagrams

setup guide

screenshots

demo

sample data

technical documentation

business documentation

Case Study

business problem

architecture

design decisions

implementation

challenges

testing

security

cost

lessons learned

future improvements

Interview Preparation

explain architecture

explain data flow

explain grain

explain dimensional modeling

explain ELT

explain incremental loading

explain dbt

explain Azure

explain Snowflake

explain failures

explain security

explain tradeoffs

explain scaling

Primary Learning Priority

Master

SQL

Python

Azure

Snowflake

dbt

Dimensional Modeling

Power BI

Git / GitHub

REST APIs

n8n

Supporting

PostgreSQL

Docker

ASP.NET Core

React

PySpark

Microsoft Fabric

Power Automate

RAG

AI Agents

AWS equivalent concepts

Do Not Specialize Yet

Databricks

Kubernetes

Kafka

Terraform

Salesforce

GCP

Tableau

Advanced Machine Learning

These technologies may be introduced later only when the architecture provides a genuine reason to use them.