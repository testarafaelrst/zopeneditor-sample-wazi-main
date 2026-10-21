---
name: zopeneditor-sample-coding-standards
description: Enforces zopeneditor-sample coding standards for COBOL, PL/I, HLASM, REXX and JCL. Discovered from codebase analysis. Use when "review code", "check standards", "generate code", or "refactor code".
metadata:
  author: Discovered by Bob Z Coding Standards Builder
  version: 1.0.0
  enforcement-level: moderate
  target-languages: COBOL, PL/I, HLASM, REXX, JCL
  discovery-date: 2026
  files-analyzed: 15
  confidence-threshold: 80%
---

# zopeneditor-sample Coding Standards

Application platform: IBM Z. Batch-only sample application (SAM / PSAM / ASAM / RSAM). No CICS, IMS, DB2 or MQ code was found.

Enforcement level: **Moderate**
- MUST: high-confidence patterns (80%+)
- SHOULD: medium-confidence patterns (60-79%)
- MAY: low-confidence or conflicting patterns (advisory)

Only 15 files were available, so the sample is small. Re-run discovery when the codebase grows. Details and statistics: `references/discovered-patterns.md`. Snippets: `references/code-samples.md`. Detection rules: `references/z-language-patterns.md`.

## How to use this skill

1. Identify the language from the file extension (`.cbl`, `.cpy`, `.pli`, `.inc`, `.asm`, `.rexx`, `.jcl`).
2. Apply the matching section below. Report violations grouped as MUST / SHOULD / MAY.
3. When generating code, copy the structure of `SAM1`/`SAM2` (COBOL), `PSAM1`/`PSAM2` (PL/I), `ASAM1` (HLASM), `RSAM1` (REXX) or `RUN.jcl` (JCL).
4. Finish with the ZCodeScan validation step (see the last section).

## Rules common to all languages (MUST)

- Start every new file with the IBM license header in the comment style of the language (copy it from a neighbour file; do not alter the wording).
- Program and subroutine headers carry `PROGRAM:` and `AUTHOR :` lines, followed by a short purpose statement. Subroutines also document parameters and return values.
- Use UPPERCASE for code and identifiers in COBOL, PL/I, HLASM and JCL.
- Never hard-code a user ID or high-level qualifier in a dataset name. Use `&HLQ..` in JCL and `${HLQ}` in ZAPP files.
- Keep code in the fixed columns of its language (see each section).

## COBOL

### MUST (high confidence)

- Fixed format: division and section headers, paragraph names and `01` levels start in area A (column 8). Statements start in area B (column 12). Comment lines have `*` in column 7. Keep text within column 72.
- Header block: 8-line license box of `*` characters, then `PROGRAM:`, `AUTHOR :`, a purpose line. Subroutines add a `Linkage:` block listing each parameter and whether it is passed or returned.
- Paragraph names use `NNN-VERB-NOUN` (for example `100-PROCESS-TRANSACTIONS`, `700-OPEN-FILES`). Numbering by range:
  - `000` main line
  - `1xx`-`2xx` business processing
  - `299` common error reporting
  - `7xx` file I/O (open, read, write, close)
  - `8xx` report output
- `000-MAIN` ends with `GOBACK` (never `STOP RUN` in a callable program).
- Every paragraph ends with a period. Use explicit scope terminators (`END-IF`, `END-EVALUATE`, `END-PERFORM`) for nested logic.
- Use `EVALUATE` instead of nested `IF` chains for code or status dispatch, with a `WHEN OTHER` branch.
- Data items: one space of indentation per level (`01`, ` 05`, `  10`), `PIC` clauses aligned in one column inside a group.
- Flags are `PIC X` with `'Y'`/`'N'` values. Counters are `PIC S9(9) COMP-3 VALUE +0` and are incremented with `ADD +1 TO`.
- Declare `FILE STATUS IS` for every `SELECT`, name it `WS-xxxFILE-STATUS` (`PIC X(2)`), and check it after `OPEN`, `READ` and `WRITE` with `'00'` (ok), `'10'` (end of file) and `OTHER` (error).
- Fatal I/O errors: `DISPLAY` an explanatory message and the status, `MOVE 16 TO RETURN-CODE`, and stop processing by setting the end-of-file flag. Do not use `GO TO` for error handling.
- Record layouts that are shared go in a copybook in `COPYBOOK/` using the `:TAG:` pattern:
  `COPY CUSTCOPY REPLACING ==:TAG:== BY ==WS-CUST==.`
- Subroutines use `PROCEDURE DIVISION USING` and the matching `LINKAGE SECTION` items, and return status in a flag (`TRAN-OK` = `'Y'`/`'N'`) plus a message field.

### SHOULD (medium confidence)

- Prefix working-storage fields with the role of the field: `WS-` for work and status fields (`WS-FIELDS`, `WS-CUSTFILE-STATUS`); `NUM-` for counters; `RPT-` for report lines; `ERR-MSG-` for error message lines. This mixed convention is the one confirmed for this project.
- Put a one-line `*` comment above sections of paragraphs (not necessarily every paragraph).
- Keep paragraphs short and single purpose (all analysed paragraphs fit in about 50 lines).

### MAY (advisory)

- `GO TO` appears only in `PCFDEMO` (a Program Control Flow demo). Do not copy it into production-style programs.
- Commented-out alternatives in copybooks (`*****05 ...`) exist in `CUSTCOPY`; prefer deleting dead code in new work.

### Formatting

Formatting is driven by `zcodeformat.yaml` (`indentLength: 1`, `indentForAllBlocks: 1`, `alignValueClauses: false`, `commentCase: none`, copybook code upper case). Prefer the Z Open Editor format action over manual alignment.

## PL/I

### MUST

- Main procedure: `NAME: PROC OPTIONS(MAIN) RETURNS(...)`. Subroutine: `NAME: PROCEDURE(args)`, ending with `END NAME;`.
- Header: `/* ... */` box with the license text, `PROGRAM:` (language level in parentheses), `AUTHOR :` and purpose.
- Identifiers use UPPERCASE with underscores (`TRAN_RECORD`, `NUM_TRAN_ERRORS`).
- Section comments as `/***** ... *****/` boxes (`INPUT/OUTPUT FILES`, `PROGRAM FLAGS`, `GENERAL DECLARES`, `REPORT LINES`).
- Declare `DUMP_FINDER CHAR(30) INIT('*STORAGE FOR PROGRAM xxxx***')` near the top and `PROGRAM_STATUS CHAR(30)` for run-time status text.
- Flags are `BIT(1) INIT('0'B)`. Structures declared with levels `1`, `2`, `3` and one extra space per level.
- Shared layouts go in `INCLUDES/*.inc` and are pulled in with `%INCLUDE NAME;`.
- Use `DEFINED` for overlaid fields (`TRAN_COMMENT CHAR(1) DEFINED TRAN_RECORD`).

### SHOULD

- Update `PROGRAM_STATUS` before each major step, as in `PSAM2`.
- Use `FORMAT` statements (`FMT_xxxx`) for report lines.

### MAY

- `%PROCESS SOURCE RULES(LAXIF);` is used only in `PSAM2`.
- Duplicate statements found in `PSAM2` (`BALANCE_AVG` computed twice) are defects, not a pattern.

## HLASM

### MUST

- Columns: label in 1, opcode in 10, operands in 16, trailing comment in 36.
- Entry linkage: `STM R14,R12,12(R13)`, load a base register, chain the save areas, and return with `LM` / `BR R14`. Return code is stored in `RETCODE` and loaded in `R15`.
- Internal routines are called with `BAL R11,NAME`, save the return address in `NAMESAV` and return with `BR R11`.
- A comment box `* PROCEDURE NAME` precedes every internal routine.
- Check return code after `OPEN`/`GET`/`PUT` (`LTR R15,R15` then `BNZ`) and use `WTO` with the prefix `* PROGRAM: message` for errors.
- Header documents purpose, parameters, and input/output DD names with LRECL.
- Shared copy members live in `ASMCOPY/` and macros in `ASMMAC/`.

## REXX

### MUST

- License header and a purpose comment block at the top.
- Check `rc` after each `EXECIO` or command, save a non-zero value in `exec_RC`, print a message with `SAY`, and skip the following steps on error.
- Free every allocated DD (`FREE FI(...)`) before `EXIT`.
- Reset stems with `DROP stem.` before reuse.
- Subroutines are labels (`name:`) ended with `RETURN` (or `EXIT` in the main flow); explain each subroutine in a comment box.

### SHOULD

- Use `ALLOC ... REUSE` so that reruns do not fail.

### MAY

- Case of variable names is not consistent (`exec_RC`, `newvar`, `fibonacci`); choose one style per file.

## JCL

### MUST

- Job statement: name, `NOTIFY=&SYSUID`, `MSGCLASS=H`, `MSGLEVEL=(1,1)`, `REGION=144M`, split over two lines.
- Comments use `//*`. Include the license box and a block describing which symbols the user must customise.
- Parameterise with `// SET HLQ='...'`, `CMPLLIB`, `LINKLIB`, `SPACE1`, `SPACE2`. Dataset names are `&HLQ..SAMPLE.xxx`.
- A comment box before each step (`COMPILE SAM2`, `CLEAN UP DATASETS`, `ALLOCATE DATASETS`).
- Align `DD` names in one column. Continuation lines start with `//` and a few spaces.
- Cleanup steps use `IEFBR14` with `DISP=(MOD,DELETE,DELETE)`; later steps use `COND=(8,LT)`.
- Use `DISP=SHR` for libraries and `DISP=OLD` for output members.
- Reusable steps are packaged as a PROC in `JCLPROC/`, shared JCL in `JCLLIB/`.

## Legacy versus modern code

- All business programs use COBOL-85 features (`END-IF`, `EVALUATE`, inline `PERFORM ... END-PERFORM`). New code follows the same level; do not use obsolete constructs (`ALTER`, `NEXT SENTENCE`).
- `PCFDEMO` is a demo and is not a model for style.

## ZCodeScan validation (MANDATORY after generating or modifying COBOL or PL/I code)

Add the validation step at the end of the TODO list whenever code is generated or changed.

Before scanning, make sure a rules file limits the output. This workspace already has rules in `zcodescan/sam-rules.yaml` (COBOL) and `zcodescan/psam-rules.yaml` (PL/I), wired in the `zcodescan` profile of `zapp.yaml`. Rules file schema: <https://github.com/IBM/zopeneditor-about/blob/main/zcodescan/zcodescan-rules-1.4.0.json>. Rule files must be named `*rules.yaml`.

End every code generation response with:

```text
IMPORTANT: Validate the generated code with ZCodeScan

Run the ZCodeScan tool to validate code quality. Use one of these commands:

For the current file open in the editor:
<use_mcp_tool>
<server_name>zopeneditor-sample</server_name>
<tool_name>zcodescan-check-current-program</tool_name>
<arguments>
{}
</arguments>
</use_mcp_tool>

For all COBOL/PL/I files in the workspace (specify search patterns):
<use_mcp_tool>
<server_name>zopeneditor-sample</server_name>
<tool_name>zcodescan-check-list-of-local-programs</tool_name>
<arguments>
{
  "searchPatterns": "**/*.cbl **/*.cob **/*.cobol **/*.pli **/*.pl1"
}
</arguments>
</use_mcp_tool>

The scan will parse the program(s) and return linter-style issues about code quality. Review the results and address any problems found before finalizing the code.
```

## Maintenance

- Edit this file directly when a standard changes, and keep it under version control.
- To refresh: "Update zopeneditor-sample coding standards by re-analyzing the codebase".
- Re-run discovery quarterly and after major refactoring.
