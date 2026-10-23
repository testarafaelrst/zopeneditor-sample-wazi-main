# Exemplos de Código COBOL - Padrões do Projeto

## 1. Estrutura de Programa e Cabeçalho
```cobol
       ****************************************************************
       * LICENSED MATERIALS - PROPERTY OF IBM
       * "RESTRICTED MATERIALS OF IBM"
       * (C) COPYRIGHT IBM CORPORATION 2026. ALL RIGHTS RESERVED
       * US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION,
       * OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE
       * CONTRACT WITH IBM CORPORATION
       ****************************************************************
       * PROGRAM:  SAM1
       * AUTHOR :  Doug Stout
       * PURPOSE:  READS A TRANSACTION FILE AND UPDATES CUSTOMER RECORDS
       *****************************************************************
        IDENTIFICATION DIVISION.
        PROGRAM-ID. SAM1.
        ENVIRONMENT DIVISION.
        INPUT-OUTPUT SECTION.
        FILE-CONTROL.
            SELECT CUSTOMER-FILE ASSIGN TO CUSTFILE
                ACCESS IS SEQUENTIAL
                FILE STATUS IS WS-CUSTFILE-STATUS.
```

## 2. Inclusão de Copybook com `:TAG:`
```cobol
        DATA DIVISION.
        FILE SECTION.
        FD  CUSTOMER-FILE
            RECORDING MODE IS V
            RECORD IS VARYING FROM 69 TO 387 CHARACTERS.
        COPY CUSTCOPY REPLACING ==:TAG:== BY ==CUST==.

        WORKING-STORAGE SECTION.
        COPY CUSTCOPY REPLACING ==:TAG:== BY ==WS-CUST==.
```

## 3. Tratamento de Arquivo e FILE STATUS
```cobol
        730-READ-CUSTOMER-FILE.
            READ CUSTOMER-FILE
            AT END
             MOVE 'Y' TO WS-CUST-FILE-EOF
            END-READ.
            EVALUATE WS-CUSTFILE-STATUS
            WHEN '00'
            WHEN '04'
             CONTINUE
            WHEN '10'
             MOVE 'Y' TO WS-CUST-FILE-EOF
            WHEN OTHER
             MOVE 'CUSTOMER FILE READ ERROR' TO ERR-MSG-DATA1
             MOVE WS-CUSTFILE-STATUS TO ERR-MSG-DATA2
             PERFORM 299-REPORT-BAD-TRAN
            END-EVALUATE.
```

## 4. Estrutura de Driver e Subrotinas
```cobol
        PROCEDURE DIVISION.
        000-MAIN.
            PERFORM 700-OPEN-FILES.
            PERFORM 730-READ-CUSTOMER-FILE.
            PERFORM 100-PROCESS-TRANSACTIONS
               UNTIL WS-TRAN-EOF = 'Y'.
            PERFORM 790-CLOSE-FILES.
            GOBACK.
```
