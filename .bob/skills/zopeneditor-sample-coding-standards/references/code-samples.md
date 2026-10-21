# Code samples - zopeneditor-sample

Snippets come from the analysed files. Lines are shortened where marked with `...`.

## COBOL

### Header (SAM2.cbl)

```cobol
      ****************************************************************
      * LICENSED MATERIALS - PROPERTY OF IBM
      * ...
      ****************************************************************
      * PROGRAM:  SAM2
      *
      * AUTHOR :  Doug Stout
      *
      * SUBROUTINE TO PROCESS "UPDATE" TRANSACTIONS AGAINST CUST RECS
      *****************************************************************
      * Linkage:
      *      parameters:
      *        1: Customer Record    (passed)
      *        2: Transaction Record (passed)
      *        3: tran-ok flag       (returned)
      *              Return values:    Y  = transaction was processed
      *                                N  = error processing transaction
      *        4: message            (returned)
      *****************************************************************
```

### Good: tagged copybook reuse (SAM1.cbl)

```cobol
       COPY CUSTCOPY REPLACING ==:TAG:== BY ==WS-CUST==.
```

### Good: file status handling (SAM1.cbl)

```cobol
       730-READ-CUSTOMER-FILE.
           READ CUSTOMER-FILE
           AT END
            MOVE 'Y' TO WS-CUST-FILE-EOF.
           EVALUATE WS-CUSTFILE-STATUS
           WHEN '00'
           WHEN '04'
            CONTINUE
           WHEN '10'
            MOVE 'Y' TO WS-CUST-FILE-EOF
           WHEN OTHER
            MOVE 'Customer input File I/O Error on Read.  RC: '
               TO ERR-MSG-DATA1
            MOVE WS-CUSTFILE-STATUS TO ERR-MSG-DATA2
            PERFORM 299-REPORT-BAD-TRAN
           END-EVALUATE.
```

### Good: fatal open error (SAM1.cbl)

```cobol
           IF WS-CUSTFILE-STATUS NOT = '00'
            DISPLAY 'ERROR OPENING CUSTOMER INPUT FILE. RC:'
                    WS-CUSTFILE-STATUS
            DISPLAY 'Terminating Program due to File Error'
            MOVE 16 TO RETURN-CODE
            MOVE 'Y' TO WS-TRAN-EOF
           END-IF.
```

### Good: subroutine call and linkage (SAM1 / SAM2)

```cobol
           CALL SAM2 USING CUST-REC,
                           TRANSACTION-RECORD,
                           WS-TRAN-OK,
                           WS-TRAN-MSG
```

```cobol
       PROCEDURE DIVISION USING CUST-REC,
                                TRANSACTION-RECORD,
                                TRAN-OK,
                                TRAN-MSG.
```

### Good: data layout alignment

```cobol
       01 REPORT-TOTALS.
        05 NUM-TRAN-RECS         PIC S9(9) COMP-3 VALUE +0.
        05 NUM-TRAN-ERRORS       PIC S9(9) COMP-3 VALUE +0.
```

### Bad (do not copy)

```cobol
      * GO TO based control flow (demo only, PCFDEMO.cbl)
       MAIN-PARA.
           PERFORM SHARED-PARA
           GO TO GOTO-PARA.
```

```cobol
      * Wrong file status reported (SAM1.cbl, 710-READ-TRAN-FILE)
            MOVE WS-CUSTFILE-STATUS TO ERR-MSG-DATA2
      * should be WS-TRANFILE-STATUS
```

Before/after for the defect above:

```cobol
      * Before
            MOVE 'Error on tran file read.  Code:' TO ERR-MSG-DATA1
            MOVE WS-CUSTFILE-STATUS TO ERR-MSG-DATA2
      * After
            MOVE 'Error on tran file read.  Code:' TO ERR-MSG-DATA1
            MOVE WS-TRANFILE-STATUS TO ERR-MSG-DATA2
```

## PL/I

### Header and declarations (PSAM1.pli)

```pli
 PSAM1: PROC OPTIONS(MAIN) RETURNS(DEC(12,2));
 /****************************************************************
  * LICENSED MATERIALS - PROPERTY OF IBM
  * ...
  * PROGRAM:  PSAM1    (PLI FOR MVS AND VM)
  *
  * AUTHOR :  DOUG STOUT
  *           IBM PD TOOLS
  *
  * READS A FILE AND WRITES A REPORT
  ****************************************************************/

   DCL DUMP_FINDER CHAR(30) INIT('*STORAGE FOR PROGRAM PSAM1***');

   /**********************/
   /* INPUT/OUTPUT FILES */
   /**********************/
   DCL CUSTFILE FILE INPUT RECORD SEQUENTIAL
              ENV(FB RECSIZE(80) BLKSIZE(0));
```

### Good: include and flags

```pli
      %INCLUDE CUSTPLI;
   DCL  TRANFILE_EOF BIT(1) INIT ('0'B);
```

### Bad

```pli
   BALANCE_AVG = BALANCE_TOTAL / BALANCE_COUNT;
   BALANCE_AVG = BALANCE_TOTAL / BALANCE_COUNT;   /* duplicated */
```

## HLASM (ASAM1.asm)

```hlasm
START    STM   R14,R12,12(R13)     SAVE REGISTERS IN PASSED SAVE AREA
         LR    R12,R15             USE R12 AS THE BASE REGISTER
         ...
*******************************************
* PROCEDURE OPENFILS
*
OPENFILS ST    R11,OPENFSAV
         OPEN  (FILEOUT,OUTPUT)       OPEN DDNAME
         LTR   R15,R15                OPEN RC = 0 ?
         BNZ   BADOPENI                 IF NO - THEN ERROR
BADOPENI WTO   '* ASAM1: ERROR OPENING INPUT FILE    '
```

## REXX (RSAM1.rexx)

```rexx
"EXECIO * DISKR myindd1 (STEM newvar. FINIS"  /* Read all records  */
IF rc = 0 THEN                  /* If read was successful          */
  DO
    CALL file1
  END
ELSE
  DO
    exec_RC = RC               /* Save exec return code         */
    SAY "Error during 1st EXECIO DISKR, return code is " RC
  END
...
"FREE FI(myindd1)"
```

## JCL (RUN.jcl / ALLOCATE.jcl)

```jcl
//SAMRUN  JOB ,NOTIFY=&SYSUID,
// MSGCLASS=H,MSGLEVEL=(1,1),REGION=144M
//*****************************************************************
...
//    SET HLQ='IBMUSER'                       *TSO USER ID
//    SET CMPLLIB='IGY.V6R5M0.SIGYCOMP'       *COMPILER LIBRARY
//***************************
//*                         *
//*  COMPILE SAM2          **
//*                         *
//***************************
//CMPLSAM2 EXEC PGM=IGYCRCTL,PARM='LIST,MAP,NODYN'
//STEPLIB  DD DISP=SHR,DSN=&CMPLLIB
//SYSIN    DD DISP=SHR,DSN=&HLQ..SAMPLE.COBOL(SAM2)
```

### Bad

```jcl
//SYSIN DD DISP=SHR,DSN=IBMUSER.SAMPLE.COBOL(SAM2)   user ID hard-coded
```
