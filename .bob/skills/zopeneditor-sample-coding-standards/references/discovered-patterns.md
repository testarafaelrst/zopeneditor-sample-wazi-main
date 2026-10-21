# Discovered patterns - zopeneditor-sample

Discovery scope: whole workspace. Files analysed (15), chosen because the repository has few files per language:

| Language | Files |
|---|---|
| COBOL | `COBOL/SAM1.cbl`, `COBOL/SAM2.cbl`, `COBOL/PCFDEMO.cbl` |
| Copybooks | `COPYBOOK/CUSTCOPY.cpy`, `COPYBOOK/TRANREC.cpy`, `COPYLIB/DATETIME.cpy` |
| PL/I | `PLI/PSAM1.pli`, `PLI/PSAM2.pli`, `INCLUDES/CUSTPLI.inc` |
| HLASM | `ASM/ASAM1.asm` |
| REXX | `REXX/RSAM1.rexx`, `REXX/FIB.rexx` |
| JCL | `JCL/RUN.jcl`, `JCL/ALLOCATE.jcl`, `JCLPROC/COMPROC.jcl` |

Subsystems: batch only (no `EXEC CICS`, `EXEC SQL`, DL/I or MQ calls found).
Not read in full: `SAM1LIB.cbl` (copy of SAM1 with library COPY), `PSAM1LIB.pli`, `MACSAMP.pli`, `MASAM1.asm`, `ASMMAC/IRR@XACS.asm` (IBM-supplied sample), other JCL and the C++ sample.

Confidence is computed per language (pattern count / files of that language), because the sample is small.

## COBOL (SAM1, SAM2, copybooks)

| Pattern | Adoption | Confidence |
|---|---|---|
| IBM license box header, PROGRAM / AUTHOR lines | 5/5 (programs and copybooks; PCFDEMO has a shorter variant) | High |
| Uppercase code, fixed format, `*` in column 7 | 5/5 | High |
| Paragraphs `NNN-VERB-NOUN` | 2/2 business programs | High |
| Period after every paragraph, explicit scope terminators | 2/2 | High |
| One-space indentation per data level | 5/5 | High |
| `:TAG:` generic copybook + `REPLACING` | 3/3 usages (SAM1 x2, SAM2) | High |
| `FILE STATUS` on every `SELECT` and checked via `EVALUATE` | 1/1 file-based program (SAM1) | High |
| `MOVE 16 TO RETURN-CODE` for fatal open errors | 4/4 open checks | High |
| `GOBACK` at end of main line | 2/2 | High |
| Y/N flags as `PIC X` | 2/2 | High |
| Counters `S9(9) COMP-3 VALUE +0` | SAM1 all report counters | High |
| `WS-` prefix on all working storage | partial | Medium (mixed with NUM-, RPT-, ERR-MSG-) |
| Comment above each paragraph | SAM1 sections only | Medium |

### Conflicts

- **Prefix of working storage fields**. `WS-FIELDS`, `WS-UPDATE-NUM` use `WS-`; `NUM-*`, `RPT-*`, `ERR-MSG-*`, `CURRENT-*`, `WORK-*` do not. User decision: keep the mixed convention (`WS-` for work and status fields; `NUM-`, `RPT-`, `ERR-MSG-` for counters and report lines).
- **Packed vs display numerics in CUSTCOPY**: COMP-3/COMP variants are commented out (`*****05`); the display variant is active. Not enforced.

### Defects noticed (not patterns)

- `SAM1` `710-READ-TRAN-FILE` and `740-WRITE-CUSTOUT-FILE` move `WS-CUSTFILE-STATUS` into the message data instead of the status of the file that failed.
- `SAM2` comment typo `CALUCLUATE`.
- `SAM1` has a `TODO` task tag used to demonstrate editor task tags.

## PL/I (PSAM1, PSAM2, CUSTPLI)

| Pattern | Adoption | Confidence |
|---|---|---|
| License box in `/* */` and PROGRAM / AUTHOR | 2/2 programs | High |
| Underscore identifiers, uppercase | 3/3 | High |
| Comment boxes per section | 2/2 | High |
| `DUMP_FINDER` and `PROGRAM_STATUS` fields | 2/2 | High |
| `BIT(1) INIT('0'B)` flags | 1/1 where flags exist | High |
| `%INCLUDE` for shared layouts | 2/2 | High |
| `%PROCESS SOURCE RULES(LAXIF)` | 1/2 | Low |

Defect: `PSAM2` computes `BALANCE_AVG` twice and tests `BALANCE_FIRST_TIME_SW` twice.

## HLASM (ASAM1)

Single program, so every pattern is "1/1" and counts as medium confidence by sample size; the structure is also the standard IBM linkage convention, so it is treated as high: column layout, save-area chaining, `BAL R11` internal routines, `WTO` error messages, `* PROCEDURE` boxes.

## REXX (RSAM1, FIB)

| Pattern | Adoption | Confidence |
|---|---|---|
| License header comment | 2/2 | High |
| `rc` checked after `EXECIO`/command and kept in `exec_RC` | 1/1 where commands exist | High |
| `FREE FI` for every `ALLOC` | 1/1 | High |
| Variable case | mixed | Low |

## JCL (RUN, ALLOCATE, COMPROC)

| Pattern | Adoption | Confidence |
|---|---|---|
| `//*` comment lines with license block | 3/3 | High |
| `// SET HLQ=` etc. symbols | 2/2 jobs (COMPROC uses symbols as PROC parameters) | High |
| `&HLQ..SAMPLE.xxx` dataset names | 3/3 | High |
| Boxed step headers | 2/2 jobs | High |
| Job card with `NOTIFY=&SYSUID`, `MSGCLASS=H`, `MSGLEVEL=(1,1)`, `REGION=144M` | 2/2 jobs | High |
| `IEFBR14` cleanup with `DISP=(MOD,DELETE,DELETE)` | 1/1 | High |

## Code era

- COBOL: COBOL-85 style (`END-IF`, `EVALUATE`, inline `PERFORM`). No Enterprise COBOL-only features (JSON, OO) observed.
- PL/I: classic IBM PL/I for MVS & VM style with `%INCLUDE`.
- No legacy COBOL-74 constructs except the `GO TO` in the PCFDEMO program.
