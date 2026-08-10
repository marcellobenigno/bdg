## 2. Criação e Alteração de Tabelas

Neste módulo vamos implementar no PostgreSQL o modelo apresentado no módulo anterior, usando os comandos `CREATE TABLE`, `ALTER TABLE` e `DROP TABLE`.

### Tipos de Dados no PostgreSQL

Antes de criar uma tabela, é preciso escolher o tipo de dado de cada coluna. Os mais usados neste curso são:

**Cadeia de caracteres:**

| Tipo | Descrição |
|---|---|
| `varchar(n)` | comprimento variável, com limite de `n` caracteres |
| `char(n)` | comprimento fixo, completado com espaços |
| `text` | comprimento variável, sem limite |

**Números inteiros:**

| Tipo | Tamanho | Faixa |
|---|---|---|
| `smallint` | 2 bytes | -32768 até 32767 |
| `integer` | 4 bytes | -2147483648 até 2147483647 |
| `serial` | 4 bytes | 1 até 2147483647 (autoincremental) |

**Números fracionários:**

| Tipo | Descrição |
|---|---|
| `numeric(p,s)` | precisão exata, com `p` dígitos no total e `s` casas decimais — ideal para área, distância, valores monetários |
| `real` / `double precision` | ponto flutuante, precisão aproximada |

**Outros tipos usados neste curso:**

| Tipo | Descrição |
|---|---|
| `boolean` | verdadeiro (`true`) ou falso (`false`) |
| `date` | somente data (ex: `'2024-03-15'`) |

O tipo `serial` é o mais comum para chaves primárias: o PostgreSQL gera automaticamente um valor inteiro sequencial a cada `INSERT`, sem precisarmos informá-lo.

### Criação de Tabelas (CREATE TABLE)

```sql
CREATE TABLE nome_da_tabela (
    coluna_1 tipo_de_dado CONSTRAINT,
    coluna_2 tipo_de_dado CONSTRAINT,
    ...
    coluna_n tipo_de_dado CONSTRAINT
);
```

### Restrições ou *Constraints*

*Constraints* são regras agregadas a colunas ou tabelas para garantir a integridade dos dados:

* **`NOT NULL`**: a coluna não pode ter valor nulo;
* **`UNIQUE`**: o valor da coluna não pode se repetir entre os registros (aceita nulos);
* **`DEFAULT`**: define um valor padrão quando nenhum for informado;
* **`CHECK`**: define uma restrição de domínio (ex: um número que deve ser sempre positivo);
* **`PRIMARY KEY`**: combinação de `NOT NULL` + `UNIQUE`; só pode ser usada uma vez por tabela (mas pode envolver mais de uma coluna — chave primária composta);
* **`FOREIGN KEY` / `REFERENCES`**: define uma chave estrangeira, obrigando o valor a existir na tabela referenciada.

### Criando o Modelo Completo

Seguindo o modelo do módulo 1, vamos criar as oito tabelas na ordem correta — sempre criando primeiro a tabela do lado "1" de um relacionamento, antes da tabela que a referencia. Antes do código, veja o modelo relacional completo que vamos implementar, com as colunas de cada tabela e a indicação de qual é chave primária (`PK`) e qual é chave estrangeira (`FK`):

```
 bacia_hidrografica (1)                         rio (N)
┌────┬──────┬──────────┐         ┌────┬──────┬─────────────┬──────────┐
│ id │ nome │ area_km2 │         │ id │ nome │ extensao_km │ bacia_id │
├────┼──────┼──────────┤         ├────┼──────┼─────────────┼──────────┤
│ PK │ ...  │   ...    │ ──────< │ PK │ ...  │     ...     │    FK    │
└────┴──────┴──────────┘         └────┴──────┴─────────────┴──────────┘

         quadra (1)                                      lote (N)
┌────┬────────┬────────────┐         ┌────┬────────┬─────────┬──────────┬───────────┐
│ id │ codigo │ zoneamento │         │ id │ numero │ area_m2 │ uso_solo │ quadra_id │
├────┼────────┼────────────┤         ├────┼────────┼─────────┼──────────┼───────────┤
│ PK │  ...   │    ...     │ ──────< │ PK │  ...   │   ...   │   ...    │    FK     │
└────┴────────┴────────────┘         └────┴────────┴─────────┴──────────┴───────────┘

      logradouro (1)                                 poste (N)
┌────┬──────┬────────────┐         ┌────┬──────┬────────────────┬───────────────┐
│ id │ nome │ hierarquia │         │ id │ tipo │ potencia_watts │ logradouro_id │
├────┼──────┼────────────┤         ├────┼──────┼────────────────┼───────────────┤
│ PK │ ...  │    ...     │ ──────< │ PK │ ...  │      ...       │      FK       │
└────┴──────┴────────────┘         └────┴──────┴────────────────┴───────────────┘

   lote (N)                       lote_proprietario                    proprietario (N)
┌────┬────────┐    ┌─────────┬─────────────────┬──────────────────┐    ┌────┬──────┐
│ id │ numero │    │ lote_id │ proprietario_id │ percentual_posse │    │ id │ nome │
├────┼────────┤    ├─────────┼─────────────────┼──────────────────┤    ├────┼──────┤
│ PK │  ...   │◄───│   FK    │       FK        │       ...        │───►│ PK │ ...  │
└────┴────────┘    └─────────┴─────────────────┴──────────────────┘    └────┴──────┘
```

```sql
-- ambiental: bacia hidrográfica (1) -> rio (N)
CREATE TABLE bacia_hidrografica (
    id       serial PRIMARY KEY,
    nome     varchar(80) NOT NULL,
    area_km2 numeric(10,2) CHECK (area_km2 > 0)
);

CREATE TABLE rio (
    id           serial PRIMARY KEY,
    nome         varchar(80) NOT NULL,
    extensao_km  numeric(10,2) CHECK (extensao_km > 0),
    bacia_id     integer NOT NULL REFERENCES bacia_hidrografica (id)
);

-- cadastral: quadra (1) -> lote (N)
CREATE TABLE quadra (
    id          serial PRIMARY KEY,
    codigo      varchar(10) NOT NULL UNIQUE,
    zoneamento  varchar(20) CHECK (zoneamento IN ('Residencial', 'Comercial', 'Industrial'))
);

CREATE TABLE lote (
    id         serial PRIMARY KEY,
    numero     varchar(5) NOT NULL,
    area_m2    numeric(10,2) CHECK (area_m2 > 0),
    uso_solo   varchar(20),
    quadra_id  integer NOT NULL REFERENCES quadra (id)
);

-- infraestrutura: logradouro (1) -> poste (N)
CREATE TABLE logradouro (
    id          serial PRIMARY KEY,
    nome        varchar(80) NOT NULL,
    hierarquia  varchar(20) CHECK (hierarquia IN ('Arterial', 'Coletora', 'Local'))
);

CREATE TABLE poste (
    id              serial PRIMARY KEY,
    tipo            varchar(20),
    potencia_watts  integer,
    logradouro_id   integer NOT NULL REFERENCES logradouro (id)
);

-- relacionamento N:N: lote <-> proprietario
CREATE TABLE proprietario (
    id    serial PRIMARY KEY,
    nome  varchar(80) NOT NULL,
    cpf   char(11) NOT NULL UNIQUE
);

CREATE TABLE lote_proprietario (
    lote_id           integer NOT NULL REFERENCES lote (id),
    proprietario_id   integer NOT NULL REFERENCES proprietario (id),
    percentual_posse  numeric(5,2) NOT NULL CHECK (percentual_posse > 0 AND percentual_posse <= 100),
    PRIMARY KEY (lote_id, proprietario_id)
);
```

Repare que `lote_proprietario` **não tem uma coluna `id` própria**: sua chave primária é a combinação `(lote_id, proprietario_id)` — o par não pode se repetir, ou seja, o mesmo proprietário não pode aparecer duas vezes para o mesmo lote.

> 💡 O script completo de criação e carga de dados está disponível em [`sql/script_criacao_dados.sql`](script_criacao_dados.sql), caso você queira executar tudo de uma vez.

### Modificação de Tabelas (ALTER TABLE)

O comando `ALTER TABLE` é usado para adicionar, apagar ou renomear colunas em uma tabela já existente:

```sql
-- Adicionando uma coluna:
ALTER TABLE nome_tabela
ADD novo_campo tipo_de_dado;

-- Apagando uma coluna:
ALTER TABLE nome_tabela
DROP COLUMN nome_do_campo;

-- Renomeando uma coluna:
ALTER TABLE nome_tabela
RENAME nome_coluna TO novo_nome;

-- Renomeando uma tabela:
ALTER TABLE nome_tabela
RENAME TO novo_nome_tabela;
```

Exemplo: adicionar a informação de se um logradouro tem ou não pavimentação:

```sql
ALTER TABLE logradouro
ADD pavimentado boolean DEFAULT true;
```

### Exclusão de Tabelas (DROP TABLE)

```sql
-- Apagando uma tabela:
DROP TABLE nome_tabela;

-- Apagando uma tabela que possui FK apontando para ela em outra tabela:
DROP TABLE nome_tabela CASCADE;
```

Se tentarmos `DROP TABLE quadra;` sem `CASCADE`, o PostgreSQL vai recusar o comando, porque a tabela `lote` tem uma `FOREIGN KEY` que depende de `quadra`. O `CASCADE` remove também os objetos que dependem da tabela apagada (nesse caso, a *constraint* de chave estrangeira em `lote` — não a tabela `lote` inteira).

### Exercícios:

1. Crie a tabela `bairro`, com as colunas `id` (chave primária), `nome` (obrigatório) e `populacao` (número inteiro).
2. Usando `ALTER TABLE`, adicione a coluna `zona_urbana` do tipo `boolean`, com valor padrão `true`, na tabela `bairro`.
3. Crie a tabela `poco` (poço de captação de água), com `id`, `profundidade_m` (com uma `CHECK` garantindo que seja maior que zero) e uma chave estrangeira para `bacia_hidrografica`.
4. O que acontece se você tentar `DROP TABLE bacia_hidrografica;` depois de já ter criado a tabela `rio`? Reescreva o comando para que ele funcione.
5. Renomeie a coluna `nome` da tabela `bairro` para `nome_bairro`.

---

**Navegação:** [⬅ Anterior: 1. Modelagem de Dados e Conceitos Relacionais](1-modelagem_dados.md) | [🏠 Índice](../README.md) | [Próximo: 3. Manipulação de Dados ➡](3-manipulacao_dados.md)
