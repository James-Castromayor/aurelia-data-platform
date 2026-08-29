# ============================================================
# Aurelia Enterprise Cloud Data & Analytics Platform
# PostgreSQL Operational Database Rebuild
#
# Purpose:
#   1. Load environment configuration
#   2. Drop the operations schema
#   3. Recreate the operations schema
#   4. Execute all operational SQL scripts in order
#   5. Grant application permissions
#   6. Generate synthetic data
#
# Run from repository root:
#
#   .\scripts\rebuild_operations_db.ps1
#
# ============================================================

$ErrorActionPreference = "Stop"


# ============================================================
# 1. Resolve Repository Root
# ============================================================

$ScriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDirectory

Set-Location $RepoRoot

Write-Host ""
Write-Host "==============================================="
Write-Host " Aurelia PostgreSQL Operational DB Rebuild"
Write-Host "==============================================="
Write-Host ""

Write-Host "Repository:"
Write-Host "  $RepoRoot"
Write-Host ""


# ============================================================
# 2. Check Required Files
# ============================================================

$EnvFile = Join-Path $RepoRoot ".env"

if (-not (Test-Path $EnvFile)) {
    throw @"
.env file not found.

Create .env in the repository root first.

Example:

DB_HOST=localhost
DB_PORT=5432
DB_NAME=aurelia_operations
DB_USER=aurelia_app
DB_PASSWORD=your_password
"@
}


# ============================================================
# 3. Load .env
# ============================================================

Write-Host "[1/8] Loading environment configuration..."

$EnvValues = @{}

Get-Content $EnvFile | ForEach-Object {

    $Line = $_.Trim()

    if (
        $Line -and
        -not $Line.StartsWith("#") -and
        $Line.Contains("=")
    ) {

        $Parts = $Line -split "=", 2

        $Key = $Parts[0].Trim()
        $Value = $Parts[1].Trim()

        $EnvValues[$Key] = $Value
    }
}


$DB_HOST = $EnvValues["DB_HOST"]
$DB_PORT = $EnvValues["DB_PORT"]
$DB_NAME = $EnvValues["DB_NAME"]
$DB_USER = $EnvValues["DB_USER"]
$DB_PASSWORD = $EnvValues["DB_PASSWORD"]


if (-not $DB_HOST) {
    throw "DB_HOST missing from .env"
}

if (-not $DB_PORT) {
    throw "DB_PORT missing from .env"
}

if (-not $DB_NAME) {
    throw "DB_NAME missing from .env"
}

if (-not $DB_USER) {
    throw "DB_USER missing from .env"
}

if (-not $DB_PASSWORD) {
    throw "DB_PASSWORD missing from .env"
}


Write-Host "Database: $DB_NAME"
Write-Host "Host:     $DB_HOST"
Write-Host "Port:     $DB_PORT"
Write-Host "User:     $DB_USER"
Write-Host ""


# ============================================================
# 4. Check psql
# ============================================================

Write-Host "[2/8] Checking PostgreSQL CLI..."

$PsqlCommand = Get-Command psql -ErrorAction SilentlyContinue

if (-not $PsqlCommand) {
    throw @"
psql was not found in PATH.

Confirm PostgreSQL is installed and its bin directory
is available in your Windows PATH.
"@
}

Write-Host "psql found."
Write-Host ""


# ============================================================
# 5. Check Python Virtual Environment
# ============================================================

Write-Host "[3/8] Checking Python environment..."

$PythonPath = Join-Path `
    $RepoRoot `
    ".venv\Scripts\python.exe"

if (-not (Test-Path $PythonPath)) {
    throw @"
Python virtual environment was not found.

Expected:

.venv\Scripts\python.exe

Create it with:

python -m venv .venv

Then install:

pip install -r requirements.txt
"@
}

Write-Host "Python environment found."
Write-Host ""


# ============================================================
# 6. SQL Helper Function
# ============================================================

function Invoke-AureliaSqlFile {

    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    if (-not (Test-Path $FilePath)) {
        throw "SQL file not found: $FilePath"
    }

    $FileName = Split-Path $FilePath -Leaf

    Write-Host "Executing $FileName ..."

    $env:PGPASSWORD = $DB_PASSWORD

    & psql `
        -h $DB_HOST `
        -p $DB_PORT `
        -U $DB_USER `
        -d $DB_NAME `
        -v ON_ERROR_STOP=1 `
        -f $FilePath

    if ($LASTEXITCODE -ne 0) {
        throw "SQL execution failed: $FileName"
    }
}


# ============================================================
# 7. Reset Operations Schema
# ============================================================

Write-Host "[4/8] Resetting operations schema..."

$env:PGPASSWORD = $DB_PASSWORD

$ResetSql = @"
DROP SCHEMA IF EXISTS operations CASCADE;

CREATE SCHEMA operations;

GRANT USAGE, CREATE
ON SCHEMA operations
TO $DB_USER;
"@

$ResetSql | & psql `
    -h $DB_HOST `
    -p $DB_PORT `
    -U $DB_USER `
    -d $DB_NAME `
    -v ON_ERROR_STOP=1


if ($LASTEXITCODE -ne 0) {
    throw "Failed to recreate operations schema."
}

Write-Host "operations schema recreated."
Write-Host ""


# ============================================================
# 8. Execute Operational Schema Scripts
# ============================================================

Write-Host "[5/8] Building operational schema..."
Write-Host ""


$SqlDirectory = Join-Path `
    $RepoRoot `
    "database\operations"


$SqlFiles = @(

    "001_reference_tables.sql",
    "002_employees.sql",
    "003_clients_contracts.sql",
    "004_projects.sql",
    "005_resource_planning.sql",
    "006_timesheets.sql",
    "007_project_budget.sql",
    "008_invoicing.sql",
    "009_payments.sql",
    "010_general_ledger.sql",
    "011_indexes_views.sql"

)


foreach ($SqlFile in $SqlFiles) {

    $FullPath = Join-Path `
        $SqlDirectory `
        $SqlFile

    Invoke-AureliaSqlFile `
        -FilePath $FullPath
}


Write-Host ""
Write-Host "Operational tables created."
Write-Host ""


# ============================================================
# 9. Grant Application Permissions
# ============================================================

Write-Host "[6/8] Applying database permissions..."

$PermissionsSql = @"

GRANT USAGE
ON SCHEMA operations
TO $DB_USER;


GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES
IN SCHEMA operations
TO $DB_USER;


GRANT USAGE, SELECT, UPDATE
ON ALL SEQUENCES
IN SCHEMA operations
TO $DB_USER;


ALTER DEFAULT PRIVILEGES
IN SCHEMA operations
GRANT SELECT, INSERT, UPDATE, DELETE
ON TABLES
TO $DB_USER;


ALTER DEFAULT PRIVILEGES
IN SCHEMA operations
GRANT USAGE, SELECT, UPDATE
ON SEQUENCES
TO $DB_USER;

"@

$PermissionsSql | & psql `
    -h $DB_HOST `
    -p $DB_PORT `
    -U $DB_USER `
    -d $DB_NAME `
    -v ON_ERROR_STOP=1


if ($LASTEXITCODE -ne 0) {
    throw "Failed to apply database permissions."
}

Write-Host "Permissions applied."
Write-Host ""


# ============================================================
# 10. Generate Synthetic Data
# ============================================================

Write-Host "[7/8] Generating synthetic operational data..."
Write-Host ""


$GeneratorPath = Join-Path `
    $RepoRoot `
    "database\operations\seed\generate_synthetic_data.py"


if (-not (Test-Path $GeneratorPath)) {
    throw "Synthetic data generator not found: $GeneratorPath"
}


& $PythonPath $GeneratorPath


if ($LASTEXITCODE -ne 0) {
    throw "Synthetic data generation failed."
}


Write-Host ""
Write-Host "Synthetic data generated."
Write-Host ""


# ============================================================
# 11. Basic Validation
# ============================================================

Write-Host "[8/8] Running basic validation..."
Write-Host ""


$ValidationSql = @"

SELECT
    'employee' AS table_name,
    COUNT(*) AS row_count
FROM operations.employee

UNION ALL

SELECT
    'client',
    COUNT(*)
FROM operations.client

UNION ALL

SELECT
    'contract',
    COUNT(*)
FROM operations.contract

UNION ALL

SELECT
    'project',
    COUNT(*)
FROM operations.project

UNION ALL

SELECT
    'employee_capacity',
    COUNT(*)
FROM operations.employee_capacity

UNION ALL

SELECT
    'resource_allocation',
    COUNT(*)
FROM operations.resource_allocation

UNION ALL

SELECT
    'timesheet_entry',
    COUNT(*)
FROM operations.timesheet_entry

UNION ALL

SELECT
    'project_budget',
    COUNT(*)
FROM operations.project_budget

UNION ALL

SELECT
    'invoice',
    COUNT(*)
FROM operations.invoice

UNION ALL

SELECT
    'invoice_line',
    COUNT(*)
FROM operations.invoice_line

UNION ALL

SELECT
    'payment',
    COUNT(*)
FROM operations.payment

UNION ALL

SELECT
    'payment_allocation',
    COUNT(*)
FROM operations.payment_allocation

UNION ALL

SELECT
    'gl_journal',
    COUNT(*)
FROM operations.gl_journal

UNION ALL

SELECT
    'gl_entry',
    COUNT(*)
FROM operations.gl_entry

ORDER BY table_name;

"@


$ValidationSql | & psql `
    -h $DB_HOST `
    -p $DB_PORT `
    -U $DB_USER `
    -d $DB_NAME `
    -v ON_ERROR_STOP=1


if ($LASTEXITCODE -ne 0) {
    throw "Database validation failed."
}


# ============================================================
# 12. Cleanup Environment Variable
# ============================================================

Remove-Item Env:PGPASSWORD `
    -ErrorAction SilentlyContinue


# ============================================================
# Complete
# ============================================================

Write-Host ""
Write-Host "==============================================="
Write-Host " Aurelia Operational Database Ready"
Write-Host "==============================================="
Write-Host ""
Write-Host "Database: $DB_NAME"
Write-Host "Schema:   operations"
Write-Host ""
Write-Host "Schema creation:       COMPLETE"
Write-Host "Indexes/views:         COMPLETE"
Write-Host "Synthetic data:        COMPLETE"
Write-Host "Basic validation:      COMPLETE"
Write-Host ""
Write-Host "Rebuild completed successfully."
Write-Host ""