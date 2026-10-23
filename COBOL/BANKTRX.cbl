      ****************************************************************
      * LICENSED MATERIALS - PROPERTY OF IBM
      * "RESTRICTED MATERIALS OF IBM"
      * (C) COPYRIGHT IBM CORPORATION 2026. ALL RIGHTS RESERVED
      * US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION,
      * OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE
      * CONTRACT WITH IBM CORPORATION
      ****************************************************************
      * PROGRAM:  BANKTRX
      * AUTHOR:   IBM
      * Simula o processamento de transacoes de conta bancaria
      * (deposito, saque e transferencia), exibindo cada etapa via
      * DISPLAY. Dados fixos em WORKING-STORAGE; sem arquivos.
      * RETURN-CODE: 0 = tudo efetuado, 4 = rejeicoes de negocio,
      *              8 = erro tecnico (estouro de tamanho).
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BANKTRX.

       ENVIRONMENT DIVISION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-CONTROLE.
        05 WS-IDX-TRX          PIC 9(02) VALUE 0.
        05 WS-QTD-TRX          PIC 9(02) VALUE 8.
        05 WS-QTD-CONTAS       PIC 9(02) VALUE 3.
        05 WS-IDX-AUX          PIC 9(02) VALUE 0.
        05 WS-POS-ORIGEM       PIC 9(02) VALUE 0.
        05 WS-POS-DESTINO      PIC 9(02) VALUE 0.
        05 WS-LIMITE-OPERACAO  PIC S9(09)V99 COMP-3
           VALUE 50000.00.
        05 WS-FLAG-VALIDA      PIC X(01) VALUE 'S'.
         88 TRX-VALIDA VALUE 'S'.
         88 TRX-INVALIDA VALUE 'N'.
        05 WS-FLAG-ERRO-TEC    PIC X(01) VALUE 'N'.
         88 ERRO-TECNICO VALUE 'S'.
         88 SEM-ERRO-TECNICO VALUE 'N'.
        05 WS-COD-ERRO         PIC X(03) VALUE SPACES.
        05 WS-MSG-ERRO         PIC X(34) VALUE SPACES.
        05 WS-RESULTADO        PIC X(10) VALUE SPACES.
        05 WS-DESC-TIPO        PIC X(14) VALUE SPACES.
        05 WS-RC-MAX           PIC 9(04) VALUE 0.

       01 WS-TABELA-CONTAS.
        05 WS-CONTA OCCURS 3 TIMES.
         10 WS-CTA-NUM         PIC 9(04).
         10 WS-CTA-TITULAR     PIC X(20).
         10 WS-CTA-SALDO       PIC S9(09)V99 COMP-3.

       01 WS-TABELA-TRX.
        05 WS-TRX OCCURS 8 TIMES.
         10 WS-TRX-TIPO        PIC X(01).
         10 WS-TRX-ORIGEM      PIC 9(04).
         10 WS-TRX-DESTINO     PIC 9(04).
         10 WS-TRX-VALOR       PIC S9(09)V99 COMP-3.

       01 WS-TRX-ATUAL.
        05 WS-ATU-TIPO         PIC X(01) VALUE SPACE.
         88 TRX-DEPOSITO VALUE 'D'.
         88 TRX-SAQUE VALUE 'S'.
         88 TRX-TRANSFER VALUE 'T'.
         88 TRX-TIPO-OK VALUE 'D' 'S' 'T'.
        05 WS-ATU-ORIGEM       PIC 9(04) VALUE 0.
        05 WS-ATU-DESTINO      PIC 9(04) VALUE 0.
        05 WS-ATU-VALOR        PIC S9(09)V99 COMP-3 VALUE 0.

       01 WS-AREA-TRABALHO.
        05 WS-SALDO-ANT-ORIG   PIC S9(09)V99 COMP-3 VALUE 0.
        05 WS-SALDO-ANT-DEST   PIC S9(09)V99 COMP-3 VALUE 0.
        05 WS-NOVO-SALDO-ORIG  PIC S9(09)V99 COMP-3 VALUE 0.
        05 WS-NOVO-SALDO-DEST  PIC S9(09)V99 COMP-3 VALUE 0.

       01 WS-CONTADORES.
        05 WS-QTD-EFETUADAS    PIC 9(02) VALUE 0.
        05 WS-QTD-REJEITADAS   PIC 9(02) VALUE 0.
        05 WS-TOT-DEPOSITOS    PIC S9(09)V99 COMP-3 VALUE 0.
        05 WS-TOT-SAQUES       PIC S9(09)V99 COMP-3 VALUE 0.
        05 WS-TOT-TRANSFER     PIC S9(09)V99 COMP-3 VALUE 0.

       01 WS-EDITADOS.
        05 WS-ED-VALOR         PIC ZZZ,ZZZ,ZZ9.99.

       PROCEDURE DIVISION.

       000-MAIN.
           PERFORM 100-INICIALIZAR
           PERFORM VARYING WS-IDX-TRX FROM 1 BY 1
              UNTIL WS-IDX-TRX > WS-QTD-TRX
            PERFORM 200-PROCESSAR-TRANSACAO
           END-PERFORM
           PERFORM 900-RESUMO-FINAL
           MOVE WS-RC-MAX TO RETURN-CODE
           GOBACK.

       100-INICIALIZAR.
           DISPLAY '=================================================='
           DISPLAY '*** SIMULACAO DE TRANSACOES BANCARIAS - BANKTRX ***'
           DISPLAY '=================================================='
           MOVE ZERO TO WS-QTD-EFETUADAS
           MOVE ZERO TO WS-QTD-REJEITADAS
           MOVE ZERO TO WS-TOT-DEPOSITOS
           MOVE ZERO TO WS-TOT-SAQUES
           MOVE ZERO TO WS-TOT-TRANSFER
           MOVE ZERO TO WS-RC-MAX
           PERFORM 110-CARREGAR-CONTAS
           PERFORM 120-CARREGAR-TRANSACOES.

       110-CARREGAR-CONTAS.
           MOVE 1001 TO WS-CTA-NUM(1)
           MOVE 'MARIA SILVA' TO WS-CTA-TITULAR(1)
           MOVE 1000.00 TO WS-CTA-SALDO(1)
           MOVE 1002 TO WS-CTA-NUM(2)
           MOVE 'JOAO SOUZA' TO WS-CTA-TITULAR(2)
           MOVE 2500.00 TO WS-CTA-SALDO(2)
           MOVE 1003 TO WS-CTA-NUM(3)
           MOVE 'ANA PEREIRA' TO WS-CTA-TITULAR(3)
           MOVE 150.00 TO WS-CTA-SALDO(3).

       120-CARREGAR-TRANSACOES.
      * 1 - Deposito valido
           MOVE 'D' TO WS-TRX-TIPO(1)
           MOVE 1001 TO WS-TRX-ORIGEM(1)
           MOVE 0 TO WS-TRX-DESTINO(1)
           MOVE 500.00 TO WS-TRX-VALOR(1)
      * 2 - Saque valido
           MOVE 'S' TO WS-TRX-TIPO(2)
           MOVE 1001 TO WS-TRX-ORIGEM(2)
           MOVE 0 TO WS-TRX-DESTINO(2)
           MOVE 200.00 TO WS-TRX-VALOR(2)
      * 3 - Transferencia valida
           MOVE 'T' TO WS-TRX-TIPO(3)
           MOVE 1001 TO WS-TRX-ORIGEM(3)
           MOVE 1002 TO WS-TRX-DESTINO(3)
           MOVE 300.00 TO WS-TRX-VALOR(3)
      * 4 - Saque com saldo insuficiente
           MOVE 'S' TO WS-TRX-TIPO(4)
           MOVE 1002 TO WS-TRX-ORIGEM(4)
           MOVE 0 TO WS-TRX-DESTINO(4)
           MOVE 5000.00 TO WS-TRX-VALOR(4)
      * 5 - Deposito com valor invalido
           MOVE 'D' TO WS-TRX-TIPO(5)
           MOVE 1003 TO WS-TRX-ORIGEM(5)
           MOVE 0 TO WS-TRX-DESTINO(5)
           MOVE 0.00 TO WS-TRX-VALOR(5)
      * 6 - Transferencia com origem igual ao destino
           MOVE 'T' TO WS-TRX-TIPO(6)
           MOVE 1001 TO WS-TRX-ORIGEM(6)
           MOVE 1001 TO WS-TRX-DESTINO(6)
           MOVE 100.00 TO WS-TRX-VALOR(6)
      * 7 - Transferencia para conta de destino inexistente
           MOVE 'T' TO WS-TRX-TIPO(7)
           MOVE 1001 TO WS-TRX-ORIGEM(7)
           MOVE 9999 TO WS-TRX-DESTINO(7)
           MOVE 100.00 TO WS-TRX-VALOR(7)
      * 8 - Tipo de operacao invalido
           MOVE 'X' TO WS-TRX-TIPO(8)
           MOVE 1001 TO WS-TRX-ORIGEM(8)
           MOVE 0 TO WS-TRX-DESTINO(8)
           MOVE 100.00 TO WS-TRX-VALOR(8).

       200-PROCESSAR-TRANSACAO.
           MOVE WS-TRX-TIPO(WS-IDX-TRX) TO WS-ATU-TIPO
           MOVE WS-TRX-ORIGEM(WS-IDX-TRX) TO WS-ATU-ORIGEM
           MOVE WS-TRX-DESTINO(WS-IDX-TRX) TO WS-ATU-DESTINO
           MOVE WS-TRX-VALOR(WS-IDX-TRX) TO WS-ATU-VALOR
           MOVE SPACES TO WS-RESULTADO
           SET SEM-ERRO-TECNICO TO TRUE
           PERFORM 220-LOCALIZAR-CONTAS
           PERFORM 210-EXIBIR-CABECALHO
           PERFORM 230-VALIDAR-TRANSACAO
           IF TRX-VALIDA
            PERFORM 300-EXECUTAR-OPERACAO
           ELSE
            PERFORM 810-REGISTRAR-REJEICAO
           END-IF
           PERFORM 400-EXIBIR-RESULTADO.

       210-EXIBIR-CABECALHO.
           DISPLAY '--------------------------------------------------'
           DISPLAY 'TRANSACAO ' WS-IDX-TRX ' DE ' WS-QTD-TRX
           EVALUATE TRUE
           WHEN TRX-DEPOSITO
            MOVE 'DEPOSITO' TO WS-DESC-TIPO
           WHEN TRX-SAQUE
            MOVE 'SAQUE' TO WS-DESC-TIPO
           WHEN TRX-TRANSFER
            MOVE 'TRANSFERENCIA' TO WS-DESC-TIPO
           WHEN OTHER
            MOVE 'INVALIDO' TO WS-DESC-TIPO
           END-EVALUATE
           IF TRX-TIPO-OK
            DISPLAY 'TIPO           : ' WS-DESC-TIPO
           ELSE
            DISPLAY 'TIPO           : '
                    WS-DESC-TIPO
                    ' ('
                    WS-ATU-TIPO
                    ')'
           END-IF
           IF WS-POS-ORIGEM > 0
            DISPLAY 'CONTA ORIGEM   : '
                    WS-ATU-ORIGEM
                    ' - '
                    WS-CTA-TITULAR(WS-POS-ORIGEM)
           ELSE
            DISPLAY 'CONTA ORIGEM   : ' WS-ATU-ORIGEM
           END-IF
           IF TRX-TRANSFER
            IF WS-POS-DESTINO > 0
             DISPLAY 'CONTA DESTINO  : '
                     WS-ATU-DESTINO
                     ' - '
                     WS-CTA-TITULAR(WS-POS-DESTINO)
            ELSE
             DISPLAY 'CONTA DESTINO  : ' WS-ATU-DESTINO
            END-IF
           END-IF
           MOVE WS-ATU-VALOR TO WS-ED-VALOR
           DISPLAY 'VALOR          : '
                   FUNCTION TRIM(WS-ED-VALOR LEADING).

       220-LOCALIZAR-CONTAS.
           MOVE 0 TO WS-POS-ORIGEM
           MOVE 0 TO WS-POS-DESTINO
           MOVE 0 TO WS-SALDO-ANT-ORIG
           MOVE 0 TO WS-SALDO-ANT-DEST
           PERFORM VARYING WS-IDX-AUX FROM 1 BY 1
              UNTIL WS-IDX-AUX > WS-QTD-CONTAS
            IF WS-CTA-NUM(WS-IDX-AUX) = WS-ATU-ORIGEM
             MOVE WS-IDX-AUX TO WS-POS-ORIGEM
            END-IF
            IF TRX-TRANSFER
             IF WS-CTA-NUM(WS-IDX-AUX) = WS-ATU-DESTINO
              MOVE WS-IDX-AUX TO WS-POS-DESTINO
             END-IF
            END-IF
           END-PERFORM
           IF WS-POS-ORIGEM > 0
            MOVE WS-CTA-SALDO(WS-POS-ORIGEM) TO WS-SALDO-ANT-ORIG
           END-IF
           IF WS-POS-DESTINO > 0
            MOVE WS-CTA-SALDO(WS-POS-DESTINO) TO WS-SALDO-ANT-DEST
           END-IF.

       230-VALIDAR-TRANSACAO.
           SET TRX-VALIDA TO TRUE
           MOVE SPACES TO WS-COD-ERRO
           MOVE SPACES TO WS-MSG-ERRO
           EVALUATE TRUE
           WHEN NOT TRX-TIPO-OK
            SET TRX-INVALIDA TO TRUE
            MOVE 'E01' TO WS-COD-ERRO
            MOVE 'TIPO DE OPERACAO INVALIDO' TO WS-MSG-ERRO
           WHEN WS-ATU-VALOR <= 0
            SET TRX-INVALIDA TO TRUE
            MOVE 'E02' TO WS-COD-ERRO
            MOVE 'VALOR INVALIDO' TO WS-MSG-ERRO
           WHEN WS-POS-ORIGEM = 0
            SET TRX-INVALIDA TO TRUE
            MOVE 'E03' TO WS-COD-ERRO
            MOVE 'CONTA ORIGEM INEXISTENTE' TO WS-MSG-ERRO
           WHEN TRX-TRANSFER AND WS-POS-DESTINO = 0
            SET TRX-INVALIDA TO TRUE
            MOVE 'E04' TO WS-COD-ERRO
            MOVE 'CONTA DESTINO INEXISTENTE' TO WS-MSG-ERRO
           WHEN TRX-TRANSFER AND WS-ATU-ORIGEM = WS-ATU-DESTINO
            SET TRX-INVALIDA TO TRUE
            MOVE 'E05' TO WS-COD-ERRO
            MOVE 'ORIGEM IGUAL AO DESTINO' TO WS-MSG-ERRO
           WHEN TRX-DEPOSITO AND WS-ATU-VALOR > WS-LIMITE-OPERACAO
            SET TRX-INVALIDA TO TRUE
            MOVE 'E07' TO WS-COD-ERRO
            MOVE 'LIMITE POR OPERACAO EXCEDIDO' TO WS-MSG-ERRO
           WHEN(TRX-SAQUE OR TRX-TRANSFER)
              AND WS-SALDO-ANT-ORIG < WS-ATU-VALOR
            SET TRX-INVALIDA TO TRUE
            MOVE 'E06' TO WS-COD-ERRO
            MOVE 'SALDO INSUFICIENTE' TO WS-MSG-ERRO
           WHEN OTHER
            CONTINUE
           END-EVALUATE.

       300-EXECUTAR-OPERACAO.
           EVALUATE TRUE
           WHEN TRX-DEPOSITO
            PERFORM 310-EXECUTAR-DEPOSITO
           WHEN TRX-SAQUE
            PERFORM 320-EXECUTAR-SAQUE
           WHEN TRX-TRANSFER
            PERFORM 330-EXECUTAR-TRANSFERENCIA
           WHEN OTHER
            CONTINUE
           END-EVALUATE
           IF ERRO-TECNICO
            PERFORM 810-REGISTRAR-REJEICAO
           ELSE
            ADD 1 TO WS-QTD-EFETUADAS
            MOVE 'EFETUADA' TO WS-RESULTADO
           END-IF.

       310-EXECUTAR-DEPOSITO.
           COMPUTE WS-NOVO-SALDO-ORIG =
              WS-SALDO-ANT-ORIG + WS-ATU-VALOR
           ON SIZE ERROR
            PERFORM 820-MARCAR-ERRO-TECNICO
           NOT ON SIZE ERROR
            MOVE WS-NOVO-SALDO-ORIG
               TO WS-CTA-SALDO(WS-POS-ORIGEM)
            ADD WS-ATU-VALOR TO WS-TOT-DEPOSITOS
            ON SIZE ERROR
             PERFORM 830-AVISAR-TOTAL-ESTOURADO
            END-ADD
           END-COMPUTE.

       320-EXECUTAR-SAQUE.
           COMPUTE WS-NOVO-SALDO-ORIG =
              WS-SALDO-ANT-ORIG - WS-ATU-VALOR
           ON SIZE ERROR
            PERFORM 820-MARCAR-ERRO-TECNICO
           NOT ON SIZE ERROR
            MOVE WS-NOVO-SALDO-ORIG
               TO WS-CTA-SALDO(WS-POS-ORIGEM)
            ADD WS-ATU-VALOR TO WS-TOT-SAQUES
            ON SIZE ERROR
             PERFORM 830-AVISAR-TOTAL-ESTOURADO
            END-ADD
           END-COMPUTE.

      * Transferencia atomica: calcula os dois novos saldos antes de
      * gravar qualquer um; em caso de estouro nenhum saldo muda.
       330-EXECUTAR-TRANSFERENCIA.
           COMPUTE WS-NOVO-SALDO-ORIG =
              WS-SALDO-ANT-ORIG - WS-ATU-VALOR
           ON SIZE ERROR
            PERFORM 820-MARCAR-ERRO-TECNICO
           END-COMPUTE
           IF SEM-ERRO-TECNICO
            COMPUTE WS-NOVO-SALDO-DEST =
               WS-SALDO-ANT-DEST + WS-ATU-VALOR
            ON SIZE ERROR
             PERFORM 820-MARCAR-ERRO-TECNICO
            END-COMPUTE
           END-IF
           IF SEM-ERRO-TECNICO
            MOVE WS-NOVO-SALDO-ORIG
               TO WS-CTA-SALDO(WS-POS-ORIGEM)
            MOVE WS-NOVO-SALDO-DEST
               TO WS-CTA-SALDO(WS-POS-DESTINO)
            ADD WS-ATU-VALOR TO WS-TOT-TRANSFER
            ON SIZE ERROR
             PERFORM 830-AVISAR-TOTAL-ESTOURADO
            END-ADD
           END-IF.

       400-EXIBIR-RESULTADO.
           IF TRX-TRANSFER
            PERFORM 410-EXIBIR-SALDO-ANT-TRANSF
           ELSE
            IF WS-POS-ORIGEM > 0
             MOVE WS-SALDO-ANT-ORIG TO WS-ED-VALOR
             DISPLAY 'SALDO ANTERIOR : '
                     FUNCTION TRIM(WS-ED-VALOR LEADING)
            ELSE
             DISPLAY 'SALDO ANTERIOR : N/A'
            END-IF
           END-IF
           IF TRX-VALIDA AND SEM-ERRO-TECNICO
            DISPLAY 'VALIDACAO      : OK'
           ELSE
            DISPLAY 'VALIDACAO      : ERRO ' WS-COD-ERRO
           END-IF
           DISPLAY 'RESULTADO      : '
                   FUNCTION TRIM(WS-RESULTADO TRAILING)
           IF WS-RESULTADO = 'REJEITADA'
            DISPLAY 'MOTIVO         : '
                    FUNCTION TRIM(WS-MSG-ERRO TRAILING)
           END-IF
           IF TRX-TRANSFER
            PERFORM 420-EXIBIR-SALDO-ATU-TRANSF
           ELSE
            IF WS-POS-ORIGEM > 0
             MOVE WS-CTA-SALDO(WS-POS-ORIGEM) TO WS-ED-VALOR
             DISPLAY 'SALDO ATUAL    : '
                     FUNCTION TRIM(WS-ED-VALOR LEADING)
            ELSE
             DISPLAY 'SALDO ATUAL    : N/A'
            END-IF
           END-IF.

       410-EXIBIR-SALDO-ANT-TRANSF.
           IF WS-POS-ORIGEM > 0
            MOVE WS-SALDO-ANT-ORIG TO WS-ED-VALOR
            DISPLAY 'SALDO ANT. ORIG: '
                    FUNCTION TRIM(WS-ED-VALOR LEADING)
           ELSE
            DISPLAY 'SALDO ANT. ORIG: N/A'
           END-IF
           IF WS-POS-DESTINO > 0
            MOVE WS-SALDO-ANT-DEST TO WS-ED-VALOR
            DISPLAY 'SALDO ANT. DEST: '
                    FUNCTION TRIM(WS-ED-VALOR LEADING)
           ELSE
            DISPLAY 'SALDO ANT. DEST: N/A'
           END-IF.

       420-EXIBIR-SALDO-ATU-TRANSF.
           IF WS-POS-ORIGEM > 0
            MOVE WS-CTA-SALDO(WS-POS-ORIGEM) TO WS-ED-VALOR
            DISPLAY 'SALDO ATU. ORIG: '
                    FUNCTION TRIM(WS-ED-VALOR LEADING)
           ELSE
            DISPLAY 'SALDO ATU. ORIG: N/A'
           END-IF
           IF WS-POS-DESTINO > 0
            MOVE WS-CTA-SALDO(WS-POS-DESTINO) TO WS-ED-VALOR
            DISPLAY 'SALDO ATU. DEST: '
                    FUNCTION TRIM(WS-ED-VALOR LEADING)
           ELSE
            DISPLAY 'SALDO ATU. DEST: N/A'
           END-IF.

       810-REGISTRAR-REJEICAO.
           ADD 1 TO WS-QTD-REJEITADAS
           MOVE 'REJEITADA' TO WS-RESULTADO
           IF ERRO-TECNICO
            MOVE 8 TO WS-RC-MAX
           ELSE
            IF WS-RC-MAX < 4
             MOVE 4 TO WS-RC-MAX
            END-IF
           END-IF.

       820-MARCAR-ERRO-TECNICO.
           SET ERRO-TECNICO TO TRUE
           MOVE 'E99' TO WS-COD-ERRO
           MOVE 'ERRO TECNICO - ESTOURO DE TAMANHO' TO WS-MSG-ERRO.

       830-AVISAR-TOTAL-ESTOURADO.
           DISPLAY '[ALERTA] TOTAL ACUMULADO ESTOUROU O TAMANHO'
           MOVE 8 TO WS-RC-MAX.

       900-RESUMO-FINAL.
           DISPLAY '=================================================='
           DISPLAY 'RESUMO DO PROCESSAMENTO'
           DISPLAY 'TRANSACOES LIDAS     : ' WS-QTD-TRX
           DISPLAY 'TRANSACOES EFETUADAS : ' WS-QTD-EFETUADAS
           DISPLAY 'TRANSACOES REJEITADAS: ' WS-QTD-REJEITADAS
           MOVE WS-TOT-DEPOSITOS TO WS-ED-VALOR
           DISPLAY 'TOTAL DEPOSITADO     : '
                   FUNCTION TRIM(WS-ED-VALOR LEADING)
           MOVE WS-TOT-SAQUES TO WS-ED-VALOR
           DISPLAY 'TOTAL SACADO         : '
                   FUNCTION TRIM(WS-ED-VALOR LEADING)
           MOVE WS-TOT-TRANSFER TO WS-ED-VALOR
           DISPLAY 'TOTAL TRANSFERIDO    : '
                   FUNCTION TRIM(WS-ED-VALOR LEADING)
           DISPLAY 'SALDOS FINAIS:'
           PERFORM VARYING WS-IDX-AUX FROM 1 BY 1
              UNTIL WS-IDX-AUX > WS-QTD-CONTAS
            MOVE WS-CTA-SALDO(WS-IDX-AUX) TO WS-ED-VALOR
            DISPLAY ' '
                    WS-CTA-NUM(WS-IDX-AUX)
                    ' '
                    FUNCTION TRIM(WS-CTA-TITULAR(WS-IDX-AUX)
               TRAILING)
                    ' .... '
                    FUNCTION TRIM(WS-ED-VALOR LEADING)
           END-PERFORM
           DISPLAY 'RETURN-CODE FINAL: ' WS-RC-MAX
           EVALUATE WS-RC-MAX
           WHEN 0
            DISPLAY '*** PROCESSAMENTO CONCLUIDO COM SUCESSO ***'
           WHEN 4
            DISPLAY
               '*** PROCESSAMENTO CONCLUIDO COM REJEICOES ***'
           WHEN OTHER
            DISPLAY
               '*** PROCESSAMENTO CONCLUIDO COM ERRO TECNICO ***'
           END-EVALUATE
           DISPLAY '=================================================='.