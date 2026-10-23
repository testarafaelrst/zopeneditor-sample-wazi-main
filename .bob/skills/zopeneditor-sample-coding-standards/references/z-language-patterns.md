# Padrões de Linguagens IBM Z - Biblioteca de Detecção

## COBOL
- **Convenção de Variáveis**:
  - `WS-*`: Variáveis de status, switches de controle e buffers da Working-Storage.
  - `NUM-*`: Contadores e acumuladores.
  - `RPT-*`: Linhas e campos editados para relatórios.
  - `ERR-MSG-*`: Mensagens de erro e formatação de log.
- **Convenção de Parágrafos**:
  - `000-MAIN`: Ponto de entrada do driver principal.
  - `100-xxx` / `200-xxx`: Lógica de negócio / processamento de transações.
  - `299-xxx`: Rotinas comuns de tratamento de erro.
  - `700-xxx` a `790-xxx`: Operações de entrada e saída (Open, Read, Write, Close).
  - `800-xxx` a `890-xxx`: Inicialização e emissão de relatórios/estatísticas.
- **Estruturas de Dados e Copybooks**:
  - Inclusão com tag genérica: `COPY CUSTCOPY REPLACING ==:TAG:== BY ==CUST==.`
  - Níveis de dados: `01` na Área A, `05`, `10`, etc. na Área B com identação uniforme.
- **Tratamento de I/O**:
  - Definição obrigatória de `FILE STATUS IS WS-...-STATUS`.
  - Avaliação de retorno com `EVALUATE` após `READ`, `WRITE`, `OPEN` e `CLOSE`.
