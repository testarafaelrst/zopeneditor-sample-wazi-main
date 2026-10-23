# Padrões Descobertos - Análise de Código COBOL

## Sumário da Descoberta
- **Diretório analisado**: `COBOL/` e copybooks associados (`COPYBOOK/`, `COPYLIB/`, `COPYLIB-MVS/`).
- **Arquivos analisados**: `SAM1.cbl`, `SAM2.cbl`, `SAM1LIB.cbl`, `PCFDEMO.cbl`, `CUSTCOPY.cpy`, `TRANREC.cpy`, `DATETIME.cpy`, `REPTTOTL.cpy`.
- **Subsistemas**: Batch / Subrotinas chamadas via `USING`.
- **Era**: IBM Enterprise COBOL (COBOL-85 com escopos explícitos `END-IF`, `END-EVALUATE`, `END-PERFORM`, `COMP-3`, `FUNCTION CURRENT-DATE`).

## Padrões Identificados e Confiança

### 1. Alta Confiança (80-100%)
- **Cabeçalho de Licença IBM**: Presente em 100% dos arquivos com bloco de 8 linhas.
- **Divisões e Margens**: Formato fixo (colunas 8-72), indicadores na coluna 7 (`*`).
- **Nomenclatura de Parágrafos**: Padrão numérico/hierárquico `NNN-VERBO-SUBSTANTIVO` (`000-MAIN`, `100-PROCESS-TRANSACTIONS`, `700-OPEN-FILES`, etc.).
- **Prefixos de Variáveis**: `WS-` para flags de status e controle, `RPT-` para relatórios, `ERR-MSG-` para erros, `NUM-` para contadores.
- **Tratamento de Arquivos e Status**: Verificação de `FILE STATUS` com `EVALUATE` após operações de I/O.
- **Copybooks com `:TAG:`**: Substituição por pseudo-texto (`COPY CUSTCOPY REPLACING ==:TAG:== BY ==CUST==.`).

### 2. Média Confiança (60-79%)
- **Chamada de Subrotinas**: `CALL` usando identificador literal ou variável com passagem via `USING` e mapeamento em `LINKAGE SECTION`.
- **Formatação de Dados**: Identação de 1 espaço por nível (`01`, ` 05`, `  10`).

### 3. Código Demo vs Produção
- `PCFDEMO.cbl` utiliza `GO TO` para fins didáticos de demonstração do Program Control Flow; para regras de produção, desconsiderar `GO TO` em favor de fluxo estruturado (`PERFORM`).
