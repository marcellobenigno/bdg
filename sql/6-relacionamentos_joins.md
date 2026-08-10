## 6. Relacionamentos entre Tabelas (JOINs, Subconsultas e CTEs)

Até agora consultamos uma tabela por vez. Neste módulo vamos combinar dados de tabelas relacionadas — exatamente o que faremos, mais adiante, para cruzar tabelas espaciais no PostGIS.

### Junção Implícita (estilo antigo)

Uma forma de unir tabelas é listá-las no `FROM`, separadas por vírgula, e informar a condição de igualdade entre chave primária e chave estrangeira no `WHERE`:

```sql
SELECT a.coluna_1, ..., b.coluna_1, ...
FROM tabela1 a, tabela2 b
WHERE a.chave_primaria = b.chave_estrangeira;
```

Essa forma **funciona**, mas mistura a lógica de junção com a lógica de filtro dentro do mesmo `WHERE`, o que fica confuso em consultas com várias tabelas e condições. Por isso, hoje se prefere a sintaxe explícita com `JOIN ... ON`.

### INNER JOIN (sintaxe explícita)

```sql
SELECT a.coluna_1, ..., b.coluna_1, ...
FROM tabela1 a
INNER JOIN tabela2 b ON a.chave_primaria = b.chave_estrangeira;
```

O `INNER JOIN` só retorna as linhas que **têm correspondência nas duas tabelas**.

```sql
-- Listar cada lote com o código da sua quadra:
SELECT q.codigo, l.numero, l.area_m2
FROM lote l
INNER JOIN quadra q ON l.quadra_id = q.id
ORDER BY q.codigo, l.numero;
```

```
 codigo | numero | area_m2
--------+--------+---------
 Q-101  |   01   |  360.00
 Q-101  |   02   |  450.50
 Q-101  |   03   |  300.00
 Q-102  |   01   |  500.00
 Q-102  |   02   |  480.00
 Q-103  |   01   |  800.00
 Q-103  |   02   |  650.00
 Q-201  |   01   | 1200.00
```

Visualmente, o `INNER JOIN` combina as duas tabelas pela condição `ON` e mantém **apenas** as linhas em que houve correspondência dos dois lados:

```
     lote              quadra             resultado (INNER JOIN)
┌────┬───────────┐   ┌────┬────────┐     ┌────────┬────────┬─────────┐
│ id │ quadra_id │   │ id │ codigo │     │ codigo │ numero │ area_m2 │
├────┼───────────┤   ├────┼────────┤     ├────────┼────────┼─────────┤
│ 1  │     1     │ ⋈ │ 1  │ Q-101  │ ──► │ Q-101  │   01   │ 360.00  │
│ 4  │     2     │   │ 2  │ Q-102  │     │ Q-102  │   01   │ 500.00  │
└────┴───────────┘   └────┴────────┘     └────────┴────────┴─────────┘
```

### LEFT JOIN

O `LEFT JOIN` retorna **todas as linhas da tabela à esquerda**, mesmo quando não há correspondência na tabela à direita (nesse caso, as colunas da tabela à direita vêm como `NULL`). É o recurso certo para responder perguntas do tipo *"quais feições NÃO têm nenhuma correspondência?"*.

```sql
-- Quantos postes cada logradouro tem, incluindo os que não têm nenhum?
SELECT lg.nome,
       COUNT(p.id) AS qtde_postes
FROM logradouro lg
LEFT JOIN poste p ON p.logradouro_id = lg.id
GROUP BY lg.nome
ORDER BY lg.nome;
```

```
         nome         | qtde_postes
-----------------------+--------------
 Av. Getúlio Vargas    |      3
 Rua das Acácias       |      3
 Rua do Comércio       |      1
 Travessa Nova         |      0
```

Visualmente, o `LEFT JOIN` mantém **todas** as linhas da tabela à esquerda (`logradouro`); quando não há poste correspondente, as colunas de `poste` entram como `NULL` em vez de a linha simplesmente desaparecer:

```
     logradouro                   poste                     resultado (LEFT JOIN)
┌────┬─────────────────┐   ┌──────┬───────────────┐     ┌─────────────────┬─────────────┐
│ id │      nome       │   │  id  │ logradouro_id │     │      nome       │ qtde_postes │
├────┼─────────────────┤   ├──────┼───────────────┤     ├─────────────────┼─────────────┤
│ 3  │ Rua do Comércio │ ⟕ │  6   │       3       │ ──► │ Rua do Comércio │      1      │
│ 4  │  Travessa Nova  │   │ NULL │     NULL      │     │  Travessa Nova  │      0      │
└────┴─────────────────┘   └──────┴───────────────┘     └─────────────────┴─────────────┘
```

> ⚠️ Usamos `COUNT(p.id)` e não `COUNT(*)`. Com `LEFT JOIN`, a linha da Travessa Nova existe no resultado mesmo sem poste, mas todas as colunas de `poste` vêm `NULL` — `COUNT(coluna)` ignora `NULL`s e conta corretamente `0`, enquanto `COUNT(*)` contaria `1` (a própria linha) mesmo sem poste algum.

### Subconsultas

Uma subconsulta é um `SELECT` dentro de outro `SELECT`, útil quando o filtro depende do resultado de outra consulta.

```sql
-- Quais lotes têm um único proprietário (não são co-propriedade)?
SELECT numero, area_m2
FROM lote
WHERE id IN (
    SELECT lote_id
    FROM lote_proprietario
    GROUP BY lote_id
    HAVING COUNT(*) = 1
)
ORDER BY id;
```

```
 numero | area_m2
--------+---------
   01   |  360.00
   03   |  300.00
   01   |  500.00
   01   |  800.00
   02   |  650.00
   01   | 1200.00
```

(os lotes 2 e 5 ficam de fora, pois são os dois casos de co-propriedade do nosso modelo)

O PostgreSQL executa a subconsulta primeiro, obtém uma lista de valores, e só então usa essa lista para filtrar a consulta externa:

```
  ┌───────────────────────────────────────┐  
  │ 1) A subconsulta roda primeiro:       │  
  │                                       │  
  │ SELECT lote_id FROM lote_proprietario │  
  │ GROUP BY lote_id HAVING COUNT(*) = 1  │  
  │                                       │  
  │ resultado: 1, 3, 4, 6, 7, 8           │  
  └───────────────────────────────────────┘  
                      │                      
               usado dentro de               
                      ▼                      
┌───────────────────────────────────────────┐
│ 2) a consulta externa usa esse resultado: │
│                                           │
│ SELECT numero, area_m2 FROM lote          │
│ WHERE id IN (1, 3, 4, 6, 7, 8)            │
└───────────────────────────────────────────┘
```

### CTE — Common Table Expression (WITH)

Uma CTE nomeia uma subconsulta com `WITH`, permitindo referenciá-la como se fosse uma tabela no restante da consulta. Isso deixa consultas complexas muito mais legíveis — e é a mesma construção que usaremos depois para compor buffers e uniões espaciais no PostGIS.

```sql
-- Área total efetivamente possuída por cada proprietário,
-- considerando o percentual de posse de cada lote:
WITH posse AS (
    SELECT lp.proprietario_id,
           l.area_m2 * (lp.percentual_posse / 100) AS area_possuida
    FROM lote_proprietario lp
    INNER JOIN lote l ON l.id = lp.lote_id
)
SELECT pr.nome,
       ROUND(SUM(posse.area_possuida), 2) AS area_total_m2
FROM posse
INNER JOIN proprietario pr ON pr.id = posse.proprietario_id
GROUP BY pr.nome
ORDER BY area_total_m2 DESC;
```

```
          nome          | area_total_m2
-------------------------+-----------------
 Carlos Eduardo Lima     |    1725.25
 Ana Beatriz Souza       |    1235.25
 João Pedro Nascimento   |     992.00
 Fernanda Costa Melo     |     788.00
```

> 💡 Assim como no módulo anterior, o `SUM` de uma expressão com divisão retorna muitas casas decimais (`1725.2500000000000000000000`); o `ROUND(expressao, 2)` deixa o resultado legível.

A CTE `posse` funciona como uma tabela temporária, que só existe durante a execução desta consulta, e é referenciada normalmente no `FROM` da consulta principal:

```
        ┌─────────────────────────────────────────────┐        
        │ WITH posse AS ( ... )                       │        
        │                                             │        
        │ cria uma "tabela temporária" chamada posse, │        
        │ que existe só durante esta consulta         │        
        └─────────────────────────────────────────────┘        
                               │                               
                usada como se fosse uma tabela                 
                               ▼                               
┌─────────────────────────────────────────────────────────────┐
│ SELECT pr.nome, SUM(posse.area_possuida)                    │
│ FROM posse                                                  │
│ INNER JOIN proprietario pr ON pr.id = posse.proprietario_id │
│ GROUP BY pr.nome                                            │
└─────────────────────────────────────────────────────────────┘
```

### Relacionamento N:N na Prática

Para consultar um relacionamento N:N, unimos as duas tabelas principais **através** da tabela associativa — normalmente com três tabelas na mesma consulta:

```sql
-- Quem são os co-proprietários do lote de id = 2, e qual o percentual de cada um?
SELECT l.numero,
       q.codigo,
       pr.nome,
       lp.percentual_posse
FROM lote l
INNER JOIN quadra q ON q.id = l.quadra_id
INNER JOIN lote_proprietario lp ON lp.lote_id = l.id
INNER JOIN proprietario pr ON pr.id = lp.proprietario_id
WHERE l.id = 2
ORDER BY lp.percentual_posse DESC;
```

```
 numero | codigo |        nome        | percentual_posse
--------+--------+---------------------+-------------------
   02   | Q-101  | Ana Beatriz Souza   |      50.00
   02   | Q-101  | Carlos Eduardo Lima |      50.00
```

Visualmente, é o mesmo caso de N:N que vimos no módulo 1 — a consulta acima passa **através** de `lote_proprietario` para conectar `lote` e `proprietario`:

```
   lote (N)                       lote_proprietario                    proprietario (N)
┌────┬────────┐    ┌─────────┬─────────────────┬──────────────────┐    ┌────┬──────────────┐
│ id │ numero │    │ lote_id │ proprietario_id │ percentual_posse │    │ id │     nome     │
├────┼────────┤    ├─────────┼─────────────────┼──────────────────┤    ├────┼──────────────┤
│ 2  │   02   │◄───│    2    │        1        │      50.00       │───►│ 1  │ Ana Beatriz  │
│ 2  │   02   │◄───│    2    │        2        │      50.00       │───►│ 2  │    Carlos    │
└────┴────────┘    └─────────┴─────────────────┴──────────────────┘    └────┴──────────────┘
```

### Exercícios:

1. Reescreva a consulta do "Exemplo 1" do `INNER JOIN` acima usando a sintaxe antiga (junção implícita com vírgula e `WHERE`), e compare a legibilidade das duas versões.
2. Usando `LEFT JOIN`, liste todas as bacias hidrográficas e a quantidade de rios de cada uma, incluindo bacias que eventualmente não tenham nenhum rio cadastrado.
3. Liste o nome de cada proprietário e a quantidade de lotes que ele possui (mesmo que parcialmente), usando `JOIN` entre `proprietario` e `lote_proprietario`.
4. Utilizando uma subconsulta, liste os proprietários que possuem **3 ou mais** lotes (mesmo que em regime de co-propriedade).
5. Reescreva a consulta da CTE de "área possuída por proprietário" acima, mas filtrando (com `HAVING`) apenas os proprietários cuja área total possuída seja maior que 1000 m².
6. Escreva uma consulta com três tabelas (`lote`, `lote_proprietario`, `proprietario`) que mostre todos os lotes que têm mais de um proprietário, com o nome de cada um e seu percentual de posse.

---

**Navegação:** [⬅ Anterior: 5. Agregação e Agrupamento](5-agregacao_agrupamento.md) | [🏠 Índice](../README.md) | [Próximo: 7. Tópicos Complementares ➡](7-topicos_complementares.md)
