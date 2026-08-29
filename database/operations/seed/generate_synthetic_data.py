import os
import random
from datetime import date, timedelta
from decimal import Decimal

import psycopg
from faker import Faker
from dotenv import load_dotenv


# =========================================================
# Configuration
# =========================================================

load_dotenv()

random.seed(42)
fake = Faker()
Faker.seed(42)

DB_CONFIG = {
    "host": os.getenv("DB_HOST"),
    "port": os.getenv("DB_PORT"),
    "dbname": os.getenv("DB_NAME"),
    "user": os.getenv("DB_USER"),
    "password": os.getenv("DB_PASSWORD"),
}


# =========================================================
# Helper Functions
# =========================================================

def random_date(start_date, end_date):
    """
    Return a random date between start_date and end_date.
    """
    days = (end_date - start_date).days

    if days <= 0:
        return start_date

    return start_date + timedelta(
        days=random.randint(0, days)
    )


# =========================================================
# Main
# =========================================================

def main():

    print("Connecting to Aurelia PostgreSQL...")

    with psycopg.connect(**DB_CONFIG) as conn:

        with conn.cursor() as cur:

            print("Connected successfully.")
            print()
            print("Generating Aurelia synthetic data...")


            # =================================================
            # 1. Reset Existing Generated Data
            # =================================================

            print("Resetting existing synthetic data...")

            cur.execute(
                """
                TRUNCATE TABLE
                    operations.employee,
                    operations.client,
                    operations.contract,
                    operations.project
                RESTART IDENTITY CASCADE;
                """
            )

            print("Existing synthetic data cleared.")


            # =================================================
            # 2. Load Reference IDs
            # =================================================

            print("Loading reference data...")

            # Business Unit
            cur.execute(
                """
                SELECT business_unit_id
                FROM operations.business_unit
                ORDER BY business_unit_id
                LIMIT 1;
                """
            )

            result = cur.fetchone()

            if result is None:
                raise RuntimeError(
                    "No business_unit records found. "
                    "Run the reference-table seed script first."
                )

            business_unit_id = result[0]


            # Cost Center
            cur.execute(
                """
                SELECT cost_center_id
                FROM operations.cost_center
                ORDER BY cost_center_id
                LIMIT 1;
                """
            )

            result = cur.fetchone()

            if result is None:
                raise RuntimeError(
                    "No cost_center records found. "
                    "Run the reference-table seed script first."
                )

            cost_center_id = result[0]


            # Skills
            cur.execute(
                """
                SELECT skill_id
                FROM operations.skill
                ORDER BY skill_id;
                """
            )

            skill_ids = [
                row[0]
                for row in cur.fetchall()
            ]

            if not skill_ids:
                raise RuntimeError(
                    "No skills found. "
                    "Run the reference-table seed script first."
                )


            # Services
            cur.execute(
                """
                SELECT service_id
                FROM operations.service
                ORDER BY service_id;
                """
            )

            service_ids = [
                row[0]
                for row in cur.fetchall()
            ]

            if not service_ids:
                raise RuntimeError(
                    "No services found. "
                    "Run the reference-table seed script first."
                )


            # =================================================
            # 3. Employees
            # =================================================

            print("Generating employees...")

            employee_ids = []

            for i in range(1, 151):

                first_name = fake.first_name()
                last_name = fake.last_name()

                hire_date = random_date(
                    date(2018, 1, 1),
                    date(2025, 12, 31),
                )

                cur.execute(
                    """
                    INSERT INTO operations.employee (
                        employee_number,
                        first_name,
                        last_name,
                        email,
                        business_unit_id,
                        cost_center_id,
                        hire_date,
                        is_active
                    )
                    VALUES (
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        TRUE
                    )
                    RETURNING employee_id;
                    """,
                    (
                        f"EMP-{i:04d}",
                        first_name,
                        last_name,
                        f"employee{i}@aurelia-demo.com",
                        business_unit_id,
                        cost_center_id,
                        hire_date,
                    ),
                )

                employee_id = cur.fetchone()[0]
                employee_ids.append(employee_id)

            print(
                f"Employees generated: "
                f"{len(employee_ids)}"
            )


            # =================================================
            # 4. Employee Skills
            # =================================================

            print("Generating employee skills...")

            employee_skill_count = 0

            for employee_id in employee_ids:

                max_skill_count = min(
                    5,
                    len(skill_ids),
                )

                min_skill_count = min(
                    2,
                    max_skill_count,
                )

                number_of_skills = random.randint(
                    min_skill_count,
                    max_skill_count,
                )

                selected_skills = random.sample(
                    skill_ids,
                    k=number_of_skills,
                )

                for skill_id in selected_skills:

                    cur.execute(
                        """
                        INSERT INTO operations.employee_skill (
                            employee_id,
                            skill_id,
                            proficiency_level,
                            years_experience
                        )
                        VALUES (
                            %s,
                            %s,
                            %s,
                            %s
                        )
                        ON CONFLICT DO NOTHING;
                        """,
                        (
                            employee_id,
                            skill_id,
                            random.randint(1, 5),
                            round(
                                random.uniform(
                                    0.5,
                                    12.0,
                                ),
                                1,
                            ),
                        ),
                    )

                    employee_skill_count += cur.rowcount

            print(
                f"Employee skills generated: "
                f"{employee_skill_count}"
            )


            # =================================================
            # 5. Clients
            # =================================================

            print("Generating clients...")

            client_ids = []

            countries = [
                "USA",
                "GBR",
                "AUS",
                "DEU",
                "SGP",
                "CAN",
            ]

            industries = [
                "Financial Services",
                "Manufacturing",
                "Technology",
                "Healthcare",
                "Retail",
                "Professional Services",
            ]

            for i in range(1, 71):

                cur.execute(
                    """
                    INSERT INTO operations.client (
                        client_number,
                        client_name,
                        country_code,
                        industry,
                        is_active
                    )
                    VALUES (
                        %s,
                        %s,
                        %s,
                        %s,
                        TRUE
                    )
                    RETURNING client_id;
                    """,
                    (
                        f"CLI-{i:04d}",
                        fake.company(),
                        random.choice(countries),
                        random.choice(industries),
                    ),
                )

                client_id = cur.fetchone()[0]
                client_ids.append(client_id)

            print(
                f"Clients generated: "
                f"{len(client_ids)}"
            )


            # =================================================
            # 6. Contracts
            # =================================================

            print("Generating contracts...")

            contract_ids = []

            for i in range(1, 121):

                client_id = random.choice(
                    client_ids
                )

                contract_start = random_date(
                    date(2024, 1, 1),
                    date(2026, 6, 30),
                )

                contract_end = (
                    contract_start
                    + timedelta(
                        days=random.randint(
                            90,
                            730,
                        )
                    )
                )

                cur.execute(
                    """
                    INSERT INTO operations.contract (
                        client_id,
                        contract_number,
                        contract_name,
                        contract_type,
                        start_date,
                        end_date,
                        contract_value,
                        currency_code,
                        is_active
                    )
                    VALUES (
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        TRUE
                    )
                    RETURNING contract_id;
                    """,
                    (
                        client_id,
                        f"CON-{i:04d}",
                        (
                            f"{fake.catch_phrase()} "
                            f"Agreement"
                        ),
                        random.choice(
                            [
                                "FIXED_PRICE",
                                "TIME_AND_MATERIALS",
                            ]
                        ),
                        contract_start,
                        contract_end,
                        round(
                            random.uniform(
                                50000,
                                750000,
                            ),
                            2,
                        ),
                        "USD",
                    ),
                )

                contract_id = cur.fetchone()[0]
                contract_ids.append(contract_id)

            print(
                f"Contracts generated: "
                f"{len(contract_ids)}"
            )


            # =================================================
            # 7. Projects
            # =================================================

            print("Generating projects...")

            project_ids = []

            for i in range(1, 201):

                contract_id = random.choice(
                    contract_ids
                )

                cur.execute(
                    """
                    SELECT
                        client_id,
                        start_date,
                        end_date
                    FROM operations.contract
                    WHERE contract_id = %s;
                    """,
                    (contract_id,),
                )

                contract_row = cur.fetchone()

                client_id = contract_row[0]
                contract_start = contract_row[1]
                contract_end = contract_row[2]

                project_start = contract_start

                project_end = min(
                    contract_end,
                    project_start
                    + timedelta(
                        days=random.randint(
                            90,
                            365,
                        )
                    ),
                )

                project_status = random.choice(
                    [
                        "PLANNED",
                        "ACTIVE",
                        "ACTIVE",
                        "ACTIVE",
                        "COMPLETED",
                    ]
                )

                cur.execute(
                    """
                    INSERT INTO operations.project (
                        client_id,
                        contract_id,
                        service_id,
                        project_number,
                        project_name,
                        project_status,
                        start_date,
                        end_date,
                        project_manager_employee_id,
                        is_billable,
                        is_active
                    )
                    VALUES (
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        TRUE,
                        TRUE
                    )
                    RETURNING project_id;
                    """,
                    (
                        client_id,
                        contract_id,
                        random.choice(
                            service_ids
                        ),
                        f"PRJ-{i:04d}",
                        fake.catch_phrase(),
                        project_status,
                        project_start,
                        project_end,
                        random.choice(
                            employee_ids
                        ),
                    ),
                )

                project_id = cur.fetchone()[0]
                project_ids.append(project_id)

            print(
                f"Projects generated: "
                f"{len(project_ids)}"
            )


            # =================================================
            # 8. Load Project Details
            # =================================================

            cur.execute(
                """
                SELECT
                    project_id,
                    start_date,
                    end_date
                FROM operations.project
                WHERE project_id = ANY(%s)
                ORDER BY project_id;
                """,
                (project_ids,),
            )

            project_details = cur.fetchall()


            # =================================================
            # 9. Employee Capacity
            # =================================================

            print("Generating employee capacity...")

            capacity_start = date(2024, 1, 1)
            capacity_end = date(2026, 8, 31)

            capacity_count = 0

            for employee_id in employee_ids:

                current_date = capacity_start

                while current_date <= capacity_end:

                    # Monday-Friday only
                    if current_date.weekday() < 5:

                        available_hours = (
                            random.choice(
                                [
                                    8.0,
                                    8.0,
                                    8.0,
                                    7.5,
                                    6.0,
                                ]
                            )
                        )

                        cur.execute(
                            """
                            INSERT INTO operations.employee_capacity (
                                employee_id,
                                work_date,
                                available_hours,
                                capacity_type
                            )
                            VALUES (
                                %s,
                                %s,
                                %s,
                                'STANDARD'
                            )
                            ON CONFLICT (
                                employee_id,
                                work_date
                            )
                            DO NOTHING;
                            """,
                            (
                                employee_id,
                                current_date,
                                available_hours,
                            ),
                        )

                        capacity_count += (
                            cur.rowcount
                        )

                    current_date += timedelta(
                        days=1
                    )

            print(
                f"Capacity records generated: "
                f"{capacity_count}"
            )


            # =================================================
            # 10. Resource Allocations
            # =================================================

            print(
                "Generating resource allocations..."
            )

            allocation_count = 0

            for _ in range(10000):

                employee_id = random.choice(
                    employee_ids
                )

                (
                    project_id,
                    project_start,
                    project_end,
                ) = random.choice(
                    project_details
                )

                allocation_date = random_date(
                    project_start,
                    project_end,
                )

                # Monday of selected week
                planning_week = (
                    allocation_date
                    - timedelta(
                        days=(
                            allocation_date.weekday()
                        )
                    )
                )

                allocated_hours = random.choice(
                    [
                        8.0,
                        16.0,
                        20.0,
                        24.0,
                        32.0,
                        40.0,
                        48.0,
                    ]
                )

                cur.execute(
                    """
                    INSERT INTO operations.resource_allocation (
                        employee_id,
                        project_id,
                        planning_week,
                        allocated_hours,
                        allocation_status
                    )
                    VALUES (
                        %s,
                        %s,
                        %s,
                        %s,
                        'PLANNED'
                    )
                    ON CONFLICT (
                        employee_id,
                        project_id,
                        planning_week
                    )
                    DO NOTHING;
                    """,
                    (
                        employee_id,
                        project_id,
                        planning_week,
                        allocated_hours,
                    ),
                )

                allocation_count += (
                    cur.rowcount
                )

            print(
                f"Resource allocations generated: "
                f"{allocation_count}"
            )


            # =================================================
            # 11. Timesheet Entries
            # =================================================

            print("Generating timesheets...")

            timesheet_count = 0

            activity_codes = [
                "DEVELOPMENT",
                "DATA_ENGINEERING",
                "ANALYSIS",
                "TESTING",
                "DESIGN",
                "MEETING",
            ]

            for _ in range(100000):

                employee_id = random.choice(
                    employee_ids
                )

                (
                    project_id,
                    project_start,
                    project_end,
                ) = random.choice(
                    project_details
                )

                work_date = random_date(
                    project_start,
                    project_end,
                )

                # Ignore weekend entries
                if work_date.weekday() >= 5:
                    continue

                service_id = random.choice(
                    service_ids
                )

                hours_worked = random.choice(
                    [
                        1.0,
                        2.0,
                        4.0,
                        6.0,
                        7.5,
                        8.0,
                        9.0,
                        10.0,
                    ]
                )

                is_billable = (
                    random.random() < 0.90
                )

                is_approved = (
                    random.random() < 0.95
                )

                cur.execute(
                    """
                    INSERT INTO operations.timesheet_entry (
                        employee_id,
                        project_id,
                        service_id,
                        work_date,
                        hours_worked,
                        activity_code,
                        description,
                        is_billable,
                        is_approved
                    )
                    VALUES (
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s
                    );
                    """,
                    (
                        employee_id,
                        project_id,
                        service_id,
                        work_date,
                        hours_worked,
                        random.choice(
                            activity_codes
                        ),
                        (
                            "Synthetic Aurelia "
                            "project work"
                        ),
                        is_billable,
                        is_approved,
                    ),
                )

                timesheet_count += 1

            print(
                f"Timesheet entries generated: "
                f"{timesheet_count}"
            )

            # =================================================
            # Project Budgets
            # =================================================

            print("Generating project budgets...")

            budget_versions = ["BASELINE", "FORECAST-01"]
            budget_categories = ["LABOR", "CLOUD", "SOFTWARE", "TRAVEL"]

            budget_count = 0

            for project_id in project_ids:
                for version in budget_versions:
                    for category in budget_categories:
                        cur.execute("""
                            INSERT INTO operations.project_budget (
                                project_id,
                                budget_version,
                                budget_category,
                                budget_amount,
                                currency_code
                            )
                            VALUES (%s,%s,%s,%s,'USD');
                        """, (
                            project_id,
                            version,
                            category,
                            round(random.uniform(5000, 200000), 2)
                        ))
                        budget_count += 1

            print(f"Budgets generated: {budget_count}")

            # =================================================
            # Invoices
            # =================================================

            print("Generating invoices...")

            invoice_ids = []

            for i in range(1, 2001):

                project_id, start_date, end_date = random.choice(project_details)

                cur.execute("""
                    SELECT client_id
                    FROM operations.project
                    WHERE project_id = %s;
                """, (project_id,))

                client_id = cur.fetchone()[0]

                invoice_date = random_date(start_date, end_date)

                total = round(random.uniform(3000, 40000), 2)

                cur.execute("""
                    INSERT INTO operations.invoice (
                        client_id,
                        project_id,
                        invoice_number,
                        invoice_date,
                        due_date,
                        currency_code,
                        invoice_status,
                        total_amount
                    )
                    VALUES (
                        %s,%s,%s,%s,%s,'USD','ISSUED',%s
                    )
                    RETURNING invoice_id;
                """, (
                    client_id,
                    project_id,
                    f"INV-{i:05d}",
                    invoice_date,
                    invoice_date + timedelta(days=30),
                    total
                ))

                invoice_id = cur.fetchone()[0]
                invoice_ids.append(invoice_id)

                remaining = total

                for line in range(1, 4):

                    if line == 3:
                        amount = remaining
                    else:
                        amount = round(random.uniform(0.2, 0.5) * total, 2)
                        remaining -= amount

                    cur.execute("""
                        INSERT INTO operations.invoice_line (
                            invoice_id,
                            line_number,
                            description,
                            quantity,
                            unit_price,
                            line_amount
                        )
                        VALUES (%s,%s,%s,1,%s,%s);
                    """, (
                        invoice_id,
                        line,
                        f"Professional Services Line {line}",
                        amount,
                        amount
                    ))

            print(f"Invoices generated: {len(invoice_ids)}")

            # =================================================
            # Payments
            # =================================================

            print("Generating payments...")

            payment_count = 0

            for invoice_id in invoice_ids:

                if random.random() < 0.80:       # 80% paid

                    cur.execute("""
                        SELECT client_id,total_amount,invoice_date
                        FROM operations.invoice
                        WHERE invoice_id=%s;
                    """, (invoice_id,))

                    client_id, total_amount, invoice_date = cur.fetchone()

                    payment_ratio = Decimal(
                            str(round(random.uniform(0.5, 1.0), 2))
                        )

                    paid_amount = (
                        total_amount * payment_ratio
                    ).quantize(Decimal("0.01"))

                    cur.execute("""
                        INSERT INTO operations.payment (
                            client_id,
                            payment_reference,
                            payment_date,
                            payment_amount,
                            currency_code,
                            payment_method
                        )
                        VALUES (
                            %s,%s,%s,%s,'USD','BANK_TRANSFER'
                        )
                        RETURNING payment_id;
                    """, (
                        client_id,
                        f"PAY-{payment_count+1:05d}",
                        invoice_date + timedelta(days=random.randint(5, 60)),
                        paid_amount
                    ))

                    payment_id = cur.fetchone()[0]

                    cur.execute("""
                        INSERT INTO operations.payment_allocation (
                            payment_id,
                            invoice_id,
                            allocated_amount
                        )
                        VALUES (%s,%s,%s);
                    """, (
                        payment_id,
                        invoice_id,
                        paid_amount
                    ))

                    payment_count += 1

            print(f"Payments generated: {payment_count}")

            # =================================================
            # GL Journals & Entries
            # =================================================

            print("Generating GL journals...")

            gl_count = 0

            for invoice_id in invoice_ids:

                cur.execute("""
                    SELECT total_amount, invoice_date, project_id
                    FROM operations.invoice
                    WHERE invoice_id=%s;
                """, (invoice_id,))

                total, journal_date, project_id = cur.fetchone()

                cur.execute("""
                    INSERT INTO operations.gl_journal (
                        journal_number,
                        journal_date,
                        journal_description
                    )
                    VALUES (%s,%s,%s)
                    RETURNING gl_journal_id;
                """, (
                    f"JE-{invoice_id:05d}",
                    journal_date,
                    "Revenue Recognition"
                ))

                journal_id = cur.fetchone()[0]

                # Accounts Receivable
                cur.execute("""
                    INSERT INTO operations.gl_entry (
                        gl_journal_id,
                        gl_account_id,
                        project_id,
                        line_number,
                        debit_amount,
                        credit_amount,
                        description
                    )
                    VALUES (%s,2,%s,1,%s,0,'Accounts Receivable');
                """, (
                    journal_id,
                    project_id,
                    total
                ))

                # Revenue
                cur.execute("""
                    INSERT INTO operations.gl_entry (
                        gl_journal_id,
                        gl_account_id,
                        project_id,
                        line_number,
                        debit_amount,
                        credit_amount,
                        description
                    )
                    VALUES (%s,3,%s,2,0,%s,'Consulting Revenue');
                """, (
                    journal_id,
                    project_id,
                    total
                ))

                gl_count += 2

            print(f"GL entries generated: {gl_count}")
            

            # =================================================
            # 12. Commit
            # =================================================

            conn.commit()


    # =========================================================
    # Finished
    # =========================================================

    print()
    print("==========================================")
    print("Aurelia synthetic data generation complete")
    print("==========================================")
    print(f"Employees:            {len(employee_ids)}")
    print(f"Employee Skills:      {employee_skill_count}")
    print(f"Clients:              {len(client_ids)}")
    print(f"Contracts:            {len(contract_ids)}")
    print(f"Projects:             {len(project_ids)}")
    print(f"Capacity Records:     {capacity_count}")
    print(f"Resource Allocations: {allocation_count}")
    print(f"Timesheet Entries:    {timesheet_count}")
    print("==========================================")


if __name__ == "__main__":
    main()