# Library Management System (DBMS Mini Project)

A MySQL-based Library Management System for managing books, authors, members, book copies, issue/return transactions, reservations, and fines.

## Features
- Store book, author, publisher, category, member, and staff details
- Track individual book copies and their availability
- Issue and return books
- Record reservations and fines
- Use primary keys, foreign keys, UNIQUE, NOT NULL, CHECK, and DEFAULT constraints
- Demonstrate joins, set operations, nested/correlated queries, aggregates, window functions, views, triggers, procedures, and cursors

## Requirements
- MySQL 8.0+
- MySQL Workbench or MySQL command-line client

## Run the project
1. Open MySQL Workbench.
2. Open `sql/library_management.sql`.
3. Execute the script from top to bottom.
4. Refresh the Schemas panel and select the `library_management` database.
5. Run the example queries in the final section.

Alternatively, from a terminal:

```bash
mysql -u root -p < sql/library_management.sql
```

## Project structure

```text
Library_Management_DBMS_Project/
├── README.md
└── sql/
    └── library_management.sql
```

## GitHub upload
Create a new GitHub repository named `Library-Management-System-DBMS`, then upload this folder or push it using Git:

```bash
git init
git add .
git commit -m "Add Library Management System DBMS project"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/Library-Management-System-DBMS.git
git push -u origin main
```

Replace `YOUR-USERNAME` with your GitHub username.

## Note
This is an academic demonstration project. Sample records are fictional. The fine trigger uses a simple fixed daily fine rate and can be changed according to project requirements.
