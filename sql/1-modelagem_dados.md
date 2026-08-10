## 1. Modelagem de Dados e Conceitos Relacionais

Antes de criar qualquer tabela no PostgreSQL — espacial ou não — é preciso entender como os dados são organizados em um **banco de dados relacional**. Esta é a base conceitual que vamos usar durante toda a disciplina, inclusive quando começarmos a armazenar geometrias no PostGIS.

### Tabela Relacional

Uma tabela relacional organiza os dados em **linhas** (registros) e **colunas** (atributos). Cada coluna tem um **domínio**, ou seja, um tipo de dado e um conjunto de valores válidos.

```
                        quadra
 ┌────┬─────────┬──────────────┐
 │ id │ codigo  │ zoneamento   │
 ├────┼─────────┼──────────────┤
 │  1 │ Q-101   │ Residencial  │  ← linha (registro)
 │  2 │ Q-102   │ Residencial  │
 │  3 │ Q-103   │ Comercial    │
 └────┴─────────┴──────────────┘
        ↑
     coluna (atributo)
```

### Chave Primária (Primary Key)

É a coluna (ou conjunto de colunas) que identifica **de forma única** cada linha de uma tabela. Não pode se repetir e não pode ser nula. Na tabela `quadra` acima, `id` é a chave primária.

### Chave Estrangeira (Foreign Key)

É a coluna que **referencia a chave primária de outra tabela**, criando um relacionamento entre elas. Por exemplo, se cada lote pertence a uma quadra, a tabela `lote` terá uma coluna `quadra_id` que aponta para `quadra.id`:

```
     quadra                          lote
 ┌────┬─────────┐            ┌────┬────────┬───────────┐
 │ id │ codigo  │            │ id │ numero │ quadra_id │
 ├────┼─────────┤            ├────┼────────┼───────────┤
 │  1 │ Q-101   │ ◄──────────┤  1 │   01   │     1     │
 │  2 │ Q-102   │ ◄──┐       │  2 │   02   │     1     │
 └────┴─────────┘    └───────┤  3 │   01   │     2     │
                              └────┴────────┴───────────┘
                                (quadra_id é FK para quadra.id)
```

### Cardinalidade dos Relacionamentos

Ao modelar um relacionamento entre duas tabelas, precisamos definir **quantas linhas de uma se relacionam com quantas linhas da outra**:

* **1:1** — uma linha de A se relaciona com no máximo uma linha de B (pouco comum; ex: um imóvel e sua matrícula única no cartório).
* **1:N** — uma linha de A se relaciona com várias linhas de B, mas cada linha de B se relaciona com apenas uma linha de A. É o caso mais comum e é resolvido com uma FK **na tabela do lado N**. Exemplos: uma `quadra` tem vários `lote`; uma `bacia_hidrografica` tem vários `rio`; um `logradouro` tem vários `poste`.
* **N:N** — várias linhas de A se relacionam com várias linhas de B. Não pode ser resolvido com uma FK simples em nenhuma das duas tabelas — exige uma **tabela associativa** (também chamada de tabela de ligação ou tabela de junção).

### Relacionamentos N:N e a Tabela Associativa

Um exemplo real do nosso domínio: um **lote** pode ter mais de um **proprietário** (co-propriedade), e um **proprietário** pode possuir mais de um **lote**. Isso é um relacionamento N:N e precisa de uma terceira tabela — `lote_proprietario` — que contém as chaves estrangeiras das duas tabelas envolvidas:

```
   lote (N)                lote_proprietario                proprietario (N)
 ┌────┬────────┐    ┌───────────┬─────────────────┬──────────────────┐    ┌────┬──────────────┐
 │ id │ numero │    │ lote_id   │ proprietario_id  │ percentual_posse │    │ id │ nome         │
 ├────┼────────┤    ├───────────┼─────────────────┼──────────────────┤    ├────┼──────────────┤
 │  2 │   02   │◄───┤     2     │        1         │      50.00       ├───►│  1 │ Ana Beatriz  │
 │  2 │   02   │◄───┤     2     │        2         │      50.00       ├───►│  2 │ Carlos       │
 └────┴────────┘    └───────────┴─────────────────┴──────────────────┘    └────┴──────────────┘
```

Note que `lote_proprietario` tem duas FKs (`lote_id` e `proprietario_id`) — juntas, elas formam a chave primária composta dessa tabela — e ainda pode ter atributos próprios, que pertencem ao **relacionamento em si**, e não a nenhuma das duas tabelas originais. Aqui, `percentual_posse` é um exemplo: não faz sentido colocá-lo em `lote` nem em `proprietario`, porque ele só existe no contexto da relação entre um lote específico e um proprietário específico.

Essa é exatamente a lacuna que normalmente falta nos cursos introdutórios de SQL, mas que é essencial em Banco de Dados Geográficos: feições do mundo real frequentemente se relacionam em N:N (um poço pode abastecer vários setores censitários e um setor pode ser abastecido por vários poços; uma rodovia pode passar por vários municípios e um município pode ser cortado por várias rodovias).

### O Modelo de Dados que Usaremos

Nos próximos módulos vamos criar, popular e consultar o seguinte modelo, que reaparecerá do início ao fim da revisão de SQL:

```
bacia_hidrografica (1) ──────< (N) rio
      PK: id                        PK: id
                                     FK: bacia_id → bacia_hidrografica.id

quadra (1) ──────< (N) lote
   PK: id                    PK: id
                              FK: quadra_id → quadra.id

logradouro (1) ──────< (N) poste
    PK: id                        PK: id
                                   FK: logradouro_id → logradouro.id

lote (N) >────── lote_proprietario ──────< (N) proprietario
 PK: id         PK: (lote_id, proprietario_id)      PK: id
                FK: lote_id → lote.id
                FK: proprietario_id → proprietario.id
                atributo próprio: percentual_posse
```

* `bacia_hidrografica` → `rio`: 1:N (dado ambiental)
* `quadra` → `lote`: 1:N (dado cadastral urbano)
* `logradouro` → `poste`: 1:N (infraestrutura urbana)
* `lote` ↔ `proprietario`: N:N, resolvido pela tabela associativa `lote_proprietario`

No próximo módulo vamos implementar esse modelo no PostgreSQL com `CREATE TABLE`, definindo os tipos de dados e as *constraints* (chave primária, chave estrangeira, `CHECK`, `UNIQUE`) que garantem a integridade de cada um desses relacionamentos.

### Exercícios:

1. Classifique a cardinalidade de cada um dos quatro relacionamentos do modelo apresentado (bacia–rio, quadra–lote, logradouro–poste, lote–proprietario).
2. Explique, com suas palavras, por que o relacionamento entre `lote` e `proprietario` não pode ser resolvido com uma única chave estrangeira em uma das duas tabelas.
3. Quais colunas, no mínimo, a tabela `lote_proprietario` precisa ter para representar corretamente o relacionamento N:N entre `lote` e `proprietario`?
4. Considere o seguinte cenário: *"cada poste pode iluminar mais de um trecho de rua, e cada trecho de rua pode ser iluminado por mais de um poste"*. Desenhe (ou descreva em texto, como no exemplo acima) o modelo necessário para representar esse relacionamento, incluindo a tabela associativa.
5. No modelo `lote_proprietario`, identifique o atributo que não pertence nem a `lote` nem a `proprietario`, mas sim ao relacionamento entre os dois. Justifique.
