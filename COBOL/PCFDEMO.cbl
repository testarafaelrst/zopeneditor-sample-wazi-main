      ****************************************************************
      * LICENSED MATERIALS - PROPERTY OF IBM
      * "RESTRICTED MATERIALS OF IBM"
      * (C) COPYRIGHT IBM CORPORATION 2026. ALL RIGHTS RESERVED
      * US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION,
      * OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE
      * CONTRACT WITH IBM CORPORATION
      ****************************************************************
      * This program is for demonstration purposes for the Program
      * Control Flow Browser.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. PCFDEMO.

       ENVIRONMENT DIVISION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-PROGRAM-VARS.
        05 WS-COUNTER       PIC 9(02) VALUE 0.
        05 WS-MAX-COUNTER   PIC 9(02) VALUE 99.
        05 WS-SHARED-LOOPS  PIC 9(02) VALUE 3.
        05 WS-CURRENT-DATE  PIC X(08) VALUE SPACES.
        05 WS-STATUS        PIC X(10) VALUE 'INITIAL'.
        05 WS-MESSAGE       PIC X(40) VALUE
           'DEMO PCF PROGRAM EXECUTION RUNNING'.

       PROCEDURE DIVISION.

       000-START-PARA.
           DISPLAY '=================================================='
           DISPLAY '*** INICIO DA DEMO - PROGRAMA PCF-EDGE-STYLES ***'
           DISPLAY '=================================================='
      * TODO: Implementar validacao de seguranca no header
      * FIXME: Substituir ACCEPT DATE por rotina padrao corporativa
           ACCEPT WS-CURRENT-DATE FROM DATE
           DISPLAY 'DATA DE PROCESSAMENTO: ' WS-CURRENT-DATE
           DISPLAY 'STATUS ATUAL: ' WS-STATUS
           DISPLAY WS-MESSAGE
           PERFORM 100-SETUP-PARA
           PERFORM 200-BUSINESS-LOGIC-PARA
           GO TO 900-FINISH-PARA.

       100-SETUP-PARA.
           DISPLAY '--------------------------------------------------'
           DISPLAY '[SETUP] INICIALIZANDO RECURSOS E CONTADORES...'
           MOVE 10 TO WS-COUNTER
           MOVE 'READY' TO WS-STATUS
           DISPLAY '[SETUP] STATUS ATUALIZADO: ' WS-STATUS
           DISPLAY '[SETUP] CONTADOR INICIAL: ' WS-COUNTER.

       200-BUSINESS-LOGIC-PARA.
           DISPLAY '--------------------------------------------------'
           DISPLAY '[LOGICA] EXECUTANDO ROTINAS DE DEMO...'
           PERFORM 300-SHARED-PARA WS-SHARED-LOOPS TIMES
           IF WS-COUNTER > WS-MAX-COUNTER
            DISPLAY '[ALERTA] VALOR LIMITE ULTRAPASSADO'
           END-IF
           DISPLAY '[LOGICA] PROCESS. DA REGRA DE NEGOCIO CONCLUIDO'.

       300-SHARED-PARA.
           ADD 1 TO WS-COUNTER
           DISPLAY '[SHARED] EXECUCAO COMPARTILHADA. CONTADOR: '
                   WS-COUNTER.

       900-FINISH-PARA.
           DISPLAY '=================================================='
           DISPLAY '*** FIM DA DEMO - FINALIZANDO COM GOBACK ***'
           DISPLAY '=================================================='
           MOVE 'FINISHED' TO WS-STATUS
           DISPLAY 'STATUS FINAL: ' WS-STATUS
           GOBACK.