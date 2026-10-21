# Z language pattern library - zopeneditor-sample

Detection rules used while reviewing or generating code for this workspace.

## Language detection (file extension and folder)

| Language | Extensions | Folders in this workspace |
|---|---|---|
| COBOL | `.cbl` | `COBOL/` |
| COBOL copybook | `.cpy` | `COPYBOOK/`, `COPYLIB/`, `COPYLIB-MVS/` |
| PL/I | `.pli` | `PLI/` |
| PL/I include | `.inc` | `INCLUDES/`, `INCLUDELIB/`, `INCLUDELIB-MVS/` |
| HLASM | `.asm` | `ASM/`, `ASMCOPY/`, `ASMMAC/` |
| REXX | `.rexx` | `REXX/`, `REXXINC/`, `REXXLIB/` |
| JCL | `.jcl` | `JCL/`, `JCLLIB/`, `JCLPROC/` |
| C++ | `.C`, `.h` | `CPP/` (outside the scope of this skill) |

Library resolution for COPY / %INCLUDE comes from the property groups in `zapp.yaml`. The name after `IN` in `COPY X IN MYFILE` must exist in `libraries`.

## Subsystem detection

| Subsystem | Indicators | Status here |
|---|---|---|
| CICS | `EXEC CICS`, `DFHCOMMAREA`, `EIBCALEN` | Not found |
| DB2 | `EXEC SQL`, `SQLCA`, `SQLCODE` | Not found |
| IMS | `DL/I`, `GU`, `GN`, `ISRT`, `DLET`, `REPL` | Not found |
| MQ | `MQOPEN`, `MQGET`, `MQPUT` | Not found |
| Batch | `FILE-CONTROL`, `FILE STATUS`, `OPEN INPUT`, sequential datasets | All analysed programs |

If a subsystem appears later, re-run discovery and add a subsystem section to `SKILL.md`.

## COBOL idioms

- `COPY name REPLACING ==:TAG:== BY ==PREFIX==` produces `PREFIX-REC` style names. Use the prefix that matches the role (`CUST`, `WS-CUST`, `CSTOUT`).
- Return flag pattern: caller passes `WS-TRAN-OK` and `WS-TRAN-MSG`; callee sets `'Y'`/`'N'` and the message.
- End-of-file is a flag (`WS-TRAN-EOF = 'Y'`), tested in `PERFORM ... UNTIL`.
- Numbered paragraph ranges encode purpose (see SKILL.md).
- `FILLER REDEFINES` is used in `TRANREC` for several views of one record.

## PL/I idioms

- `BASED(ADDR(x))` overlays alternate record layouts on one buffer (`CUSTOMER_RECORD`, `PRODUCT_RECORD`).
- `DEFINED` gives named access to part of a record.
- `ON` units for file conditions are expected in programs that open files (`MSG_ONFILE`, `MSG_ONCODE`, `MSG_ONCONDID` messages exist in PSAM1).

## HLASM idioms

- `BAL R11,routine` with save in a `...SAV` field is the local call convention; R13 is the save area, R15 the return code.
- `WTO '* PROGRAM: text'` is used for operator messages.

## REXX idioms

- `EXECIO ... STEM name.` then use `name.0` for the count and `DROP name.` before reuse.
- `exec_RC` accumulates the first failing return code.

## JCL idioms

- `// SET` symbols at the top; `&HLQ..` (double dot) before a literal qualifier.
- `IEFBR14` steps to delete or allocate datasets; `COND=(8,LT)` guards later steps.
- Compile step names follow `CMPL` + program name (`CMPLSAM1`).

## Code era detection

| Era | Signs |
|---|---|
| COBOL-74 | No `END-IF`, period-terminated nested `IF`, `GO TO` heavy |
| COBOL-85 | `END-IF`, `EVALUATE`, inline `PERFORM ... END-PERFORM` (this project) |
| Enterprise COBOL | `JSON PARSE`, `XML`, long names, OO |
| Classic PL/I | `OPTIONS(MAIN)`, fixed format (this project) |
| Modern PL/I | Free format, newer built-ins |
