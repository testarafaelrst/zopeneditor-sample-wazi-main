---
name: zopeneditor-sample-coding-standards
description: Enforces zopeneditor-sample coding standards for COBOL and copybooks. Discovered from codebase analysis. Use when "review code", "check standards", "generate code", or "refactor code".
metadata:
  author: Discovered by Bob Z Coding Standards Builder
  version: 1.0.0
  enforcement-level: moderate
  target-languages: [COBOL]
  discovery-date: 2026-03-30
  confidence-threshold: 80%
---

# zopeneditor-sample Coding Standards

This skill defines and enforces the coding standards discovered from the `COBOL/` directory and related copybooks.

## Core Rules & Confidence Summary

- **Enforcement Level**: Moderate
- **Languages Covered**: IBM Enterprise COBOL for z/OS, Copybooks

---

## COBOL Standards

### 1. Mandatory / High Confidence Standards (MUST Follow)

#### Fixed Format & Margins
- **Sequence & Indicator Area**: Columns 1-6 are reserved/blank; Column 7 is indicator area (`*` for comments).
- **Area A & B**: Area A starts at column 8 (Divisions, Sections, Paragraphs, FD, 01 levels). Statements and subordinate data items start in Area B (columns 12-72).
- **Line Length**: Lines must never exceed 72 columns.

#### Header & Documentation
- Every file must preserve or include the standard IBM Copyright & License Header block at lines 1-8:
  ```cobol
         ****************************************************************
         * LICENSED MATERIALS - PROPERTY OF IBM
         * "RESTRICTED MATERIALS OF IBM"
         * (C) COPYRIGHT IBM CORPORATION. ALL RIGHTS RESERVED
         * US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION,
         * OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE
         * CONTRACT WITH IBM CORPORATION
         ****************************************************************
  ```
- Program metadata comments should follow immediately below the header with `PROGRAM:`, `AUTHOR:`, and functional description.

#### Variable Naming Conventions
- **Working Storage**: Prefix `WS-` for status flags, control indicators, and work records (e.g., `WS-CUSTFILE-STATUS`, `WS-TRAN-EOF`).
- **Reports & Formats**: Prefix `RPT-` for report headers, detail lines, and edit fields.
- **Error Messages**: Prefix `ERR-MSG-` for error descriptions.
- **Numbers & Accumulators**: Descriptive names in uppercase with hyphens (e.g., `NUM-TRAN-RECS`, `NUM-ADD-PROCESSED`).

#### Paragraph & Section Organization
- **Numbered Paragraphs**: Prefix paragraphs with numeric sequence numbers indicating order of execution or hierarchy (e.g., `000-MAIN`, `100-PROCESS-TRANSACTIONS`, `700-OPEN-FILES`, `730-READ-CUSTOMER-FILE`, `790-CLOSE-FILES`, `800-INIT-REPORT`, `850-REPORT-TRAN-STATS`).
- **Program Termination**: Terminate execution with `GOBACK.` at the end of the driver routine `000-MAIN`.

#### Copybook Tagging & Resolution
- Use pseudo-text replacement tagging `:TAG:` for shared record layouts:
  ```cobol
         COPY CUSTCOPY REPLACING ==:TAG:== BY ==CUST==.
         COPY CUSTCOPY REPLACING ==:TAG:== BY ==WS-CUST==.
  ```
- Match library qualification (`COPY X IN MYLIB` / `COPY X IN MYFILE`) to definitions declared in `zapp.yaml`.

#### Error Handling & File Status
- Check `FILE STATUS` after every I/O operation (`READ`, `WRITE`, `OPEN`, `CLOSE`).
- Use structured `EVALUATE WS-...-STATUS` with explicit handlers for `'00'` (success), `'10'` (EOF), and `WHEN OTHER` for error reporting.

---

### 2. Formatting Guidelines (zcodeformat.yaml)

- Indentation length: 1 space indent for structured blocks and data division hierarchies.
- No forced alignment for `VALUE` clauses.
- Comment case: preserve original case.
- Copybook code case: uppercase.
