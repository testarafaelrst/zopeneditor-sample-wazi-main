# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## Workspace Type

**Application platform: IBM Z**
**Type:** IBM Enterprise COBOL for z/OS sample workspace for IBM Z Open Editor
**Detected Languages:** COBOL, PL/I, HLASM, REXX, JCL, C++

Sample/tutorial repository: there is no local compiler or test framework. Code is built and run on z/OS (JCL, Zowe CLI, or DBB), never locally.

## Build / Run / Test Commands

- Run all scripts from the workspace root (e.g. `zowe/zowecli-cobol-upload-run-simple.sh`); paths inside are relative.
- Zowe CLI upload + compile + run (COBOL SAM1/SAM2): `zowe/zowecli-cobol-upload-run-simple.sh` (submits `JCL/ALLOCATE.jcl`, uploads to `${HLQ}.SAMPLE.*`, submits `JCL/RUN.jcl`). Clean up with `zowe/zowecli-cobol-clean.sh`.
- Set `HLQ=` (default `IBMUSER`, JCL samples use `USER1`) and `FILES_CMD`/`JOBS_CMD` (`rse` by default; use `files`/`zos-jobs` for z/OSMF) at the top of each script before running.
- Single-program build: DBB user build, configured by the `userbuild`/`dbb` profiles in `zapp.yaml` and `dbb-app.yaml` (one program at a time, via the `userbuild-run-user-build` MCP tool or editor command). First build of a file needs a full upload so copybooks/includes reach the host.
- DBB user build prerequisite on USS: `zowe/dbb-prepare-uss-folder.sh` (clones `dbb-zappbuild`, uploads `application-conf/datasets-sandbox.properties`); remove with `zowe/dbb-remove-uss-folder.sh`.
- Full application build: `groovy/dbb-sam-prepare-and-build.sh`, then `groovy/dbb-sam-run.sh`. Ansible equivalents are in `ansible/` (run from inside that folder: `ansible-playbook -i inventories --extra-vars "host=sandbox1" dbb-sam-build.ansible.yaml`) and as VS Code tasks `COBOL-1..4` in `.vscode/tasks.json`.
- Automation scripts only cover COBOL `SAM1`/`SAM2`; PL/I, HLASM, REXX use their own JCL (`PLIALLOC`/`RUNPSAM1`, `ASMALLOC`/`RUNASAM1`, `REXALLOC`) and are run manually.
- "Test" = running the app on z/OS: `groovy/dbb-sam-run.groovy` (also used by the `unit-test-job` in `.gitlab-ci.yml`). Debug/coverage: `JCL/DEBUG.jcl`, `JCL/DEBUGASM.jcl`, `JCL/DEBUGPLI.jcl`, `JCL/COVERAGE.jcl`.
- Lint: ZCodeScan (MCP tools `zcodescan-check-current-program` / `zcodescan-check-list-of-local-programs`), configured in the `zcodescan` profile of `zapp.yaml`. Rule files must match `*rules.yaml` (YAML schema association in `.vscode/settings.json`).
- Custom Java ZCodeScan rules: `cd zcodescan/customrules && mvn clean package`; the resulting `target/*.jar` is referenced from `zapp.yaml` (`customRuleJars`) — rebuild and reload VS Code after changes.
- Local COBOL/PL/I preprocessors (Java, under `preprocessor/`) are referenced by jar path in `zapp.yaml` and must be built before use.

## Code Style / Conventions

- `editor.formatOnSave` is on; COBOL formatting is driven by `zcodeformat.yaml` (indent 1, no value-clause alignment, comment case untouched, copybook code upper-case). Use the `zopeneditor-cobol-format-file` MCP tool instead of hand-formatting.
- COBOL fixed format: code in columns 8-72; `*` in column 7 is a comment. Keep source/copybook lines ≤ 72 columns.
- Copybooks use `COPY CUSTCOPY REPLACING ==:TAG:== BY ==CUST==.` pseudo-text tagging; keep the `:TAG:` convention when adding record layouts.
- Library-qualified copies (`COPY X IN MYLIB` / `MYFILE`) are resolved via `libraries` names in `zapp.yaml` property groups — the name after `IN` must match a `libraries: name`.
- Every file carries the IBM license header block; preserve it when editing.
- Source file extensions expected by tooling: `.cbl` (COBOL), `.cpy` (copybooks), `.pli`, `.inc` (PL/I includes), `.asm`, `.jcl`.
- Do not hardcode user IDs: use `${HLQ}` / ZAPP variables (`zopeneditor.zapp.variables`) in `zapp.yaml`; JCL samples are templates that need `HLQ` and compiler library names adjusted.

## Directory Layout (non-obvious)

- Copybook/include folders have distinct roles resolved by `zapp.yaml`: `COPYBOOK` (default syslib), `COPYLIB` (local `MYFILE` library), `COPYLIB-MVS` (local mirror of members that live on MVS as `MYLIB`); same pattern for `INCLUDES`/`INCLUDELIB`/`INCLUDELIB-MVS` (PL/I), `ASMCOPY`/`ASMMAC` (HLASM), `REXXINC`/`REXXLIB`, `JCLLIB`/`JCLPROC`.
- `application-conf/` holds dbb-zappbuild properties (`datasets-sandbox.properties` has Wazi Sandbox defaults; adjust for other z/OS systems). `dbb-app.yaml` defines DBB zBuilder tasks and dependency search paths per language.
- `multiroot/` is a separate multi-root workspace example; `zapp-example.json` / `zcodeformat-example.json` are reference examples, not active config (`zapp.yaml` and `zcodeformat.yaml` are).
- Source data files for datasets live in `RESOURCES/` (`SAMPLE.*.txt`).
- MCP server `zopeneditor-sample` (`.bob/mcp.json`, `http://localhost:3005/mcp`) provides Zowe/z/OS, user build, ZCodeScan and COBOL tooling and requires a configured Zowe profile.

## Data Dictionary

No data dictionary (`bobz/DD.json`) exists in this workspace; omit data-dictionary steps unless one is generated.

## Coding Standards

Coding standards are available in the workspace and can be applied using the coding standard skill when one is installed. Do not reference coding standards files directly.

## Technical Documentation Location

**Documentation:** `README.md` (root), `zcodescan/README.md`, `zcodescan/customrules/README.md`, `multiroot/README.md`, `preprocessor/README.md`. There is no `docs/` folder.

**Program Documentation Mapping:**

| Program Name | Documentation File(s) | Description/Purpose |
|--------------|----------------------|---------------------|
| SAM1 / SAM2 / SAM1LIB (COBOL) | README.md ("Running COBOL sample files") | Customer file update from transactions (ADD/UPDATE/DELETE); SAM1 calls SAM2 for UPDATE; SAM1LIB shows library copybook resolution |
| PSAM1 / PSAM2 / PSAM1LIB (PL/I) | README.md ("Running PL/I sample files") | Customer report with totals; PSAM1LIB shows include resolution |
| ASAM1 (HLASM) | README.md ("Running HLASM sample files") | Reads a file and writes record/column output |
| RSAM1 (REXX) | README.md ("Running REXX sample files") | Reads input data sets and writes combined output |
| COBOL/PL/I preprocessors | preprocessor/README.md | Local and remote preprocessor examples |
| ZCodeScan rules | zcodescan/README.md, zcodescan/customrules/README.md | Rule selection, baselines, custom Java rules |

**Auto-Update Rules:**
1. When code is modified, check whether it appears in the mapping table above and review the referenced documentation.
2. If documentation is out of sync, prompt the user to update it.
3. When analyzing a program, read its mapped documentation for context.
4. Update the mapping table when new programs or documentation are added.
