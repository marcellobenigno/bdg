## 4. Consultas Básicas (SELECT, WHERE, ORDER BY, LIMIT, DISTINCT)

As consultas são realizadas através do comando `SELECT`:

```sql
SELECT lista_de_colunas
FROM tabela
WHERE condicao;
```

### Exemplo 1 — Listando Todos os Dados

```sql
SELECT id, nome, area_km2
FROM bacia_hidrografica;
```

```
 id |       nome        | area_km2
----+--------------------+-----------
  1 | Rio Paraíba        | 20071.83
  2 | Rio Piranhas-Açu   | 43681.50
  3 | Rio Mamanguape     |  3958.31
```

```sql
-- ou, utilizando o * (corresponde a todas as colunas):
SELECT * FROM bacia_hidrografica;
```

### Operadores Relacionais e Lógicos

* maior que: `>`
* maior ou igual que: `>=`
* menor que: `<`
* menor ou igual que: `<=`
* diferente de: `<>` ou `!=`
* interseção: `AND`
* união: `OR`
* negação: `NOT`
* intervalo: `BETWEEN valor1 AND valor2`
* lista de valores: `IN (valor1, valor2, ...)`

### Exemplo 2 — Filtrando com WHERE

```sql
-- Quais lotes têm área maior que 500 m²?
SELECT numero, area_m2, uso_solo
FROM lote
WHERE area_m2 > 500;
```

```
 numero | area_m2 |  uso_solo
--------+---------+------------
   01   |  800.00 | Comercial
   02   |  650.00 | Comercial
   01   | 1200.00 | Industrial
```

```sql
-- Quais lotes têm área entre 400 e 700 m²?
SELECT numero, area_m2
FROM lote
WHERE area_m2 BETWEEN 400 AND 700;
```

```
 numero | area_m2
--------+---------
   02   |  450.50
   01   |  500.00
   02   |  480.00
   02   |  650.00
```

```sql
-- Quais lotes são comerciais ou industriais?
SELECT numero, area_m2, uso_solo
FROM lote
WHERE uso_solo IN ('Comercial', 'Industrial');
```

### Operador LIKE

O operador `LIKE` é utilizado em uma cláusula `WHERE` para procurar um padrão de texto, e possui dois curingas:

* `_`: marca uma posição específica (um único caractere);
* `%`: qualquer sequência de caracteres a partir da posição especificada.

```sql
-- Quais logradouros começam com "Rua"?
SELECT nome, hierarquia
FROM logradouro
WHERE nome LIKE 'Rua%';
```

```
        nome        | hierarquia
---------------------+------------
 Rua das Acácias     | Local
 Rua do Comércio      | Coletora
```

### Aliases

Podemos renomear colunas (ou tabelas) no resultado de uma consulta usando `AS`:

```sql
SELECT nome AS nome_logradouro, hierarquia AS classe_via
FROM logradouro;
```

`AS` também funciona para apelidar tabelas — o que se torna essencial quando combinamos várias tabelas na mesma consulta (ver módulo 6).

### Ordenando o Resultado (ORDER BY)

Após realizar uma consulta, podemos ordenar o resultado com `ORDER BY`. Por padrão a ordem é crescente (`ASC`); para decrescente usamos `ORDER BY coluna DESC`.

```sql
-- Os 3 lotes de maior área:
SELECT numero, area_m2
FROM lote
ORDER BY area_m2 DESC
LIMIT 3;
```

```
 numero | area_m2
--------+---------
   01   | 1200.00
   01   |  800.00
   02   |  650.00
```

O `LIMIT` restringe a quantidade de linhas retornadas — muito útil para *rankings*, como "as 3 sedes mais próximas" ou, aqui, "os lotes de maior área".

### DISTINCT

`DISTINCT` remove linhas duplicadas do resultado — útil para descobrir quais valores diferentes existem em uma coluna:

```sql
-- Quais são os usos de solo cadastrados?
SELECT DISTINCT uso_solo
FROM lote;
```

```
   uso_solo
--------------
 Residencial
 Comercial
 Industrial
```

Sem o `DISTINCT`, a mesma consulta retornaria 8 linhas (uma por lote), com valores repetidos.

### Exercícios:

1. Liste o nome e a extensão de todos os rios com `extensao_km` maior que 150.
2. Liste os postes do tipo `'Metálico'`.
3. Liste, em ordem alfabética, o nome de todos os logradouros.
4. Quais são os 2 rios de menor extensão? Ordene o resultado e utilize `LIMIT`.
5. Liste, sem repetição, todos os zoneamentos cadastrados na tabela `quadra`.
6. Quais lotes têm `numero` igual a `'01'` **e** `uso_solo` igual a `'Residencial'`?
7. Liste o nome de todas as bacias hidrográficas cujo nome comece com a letra `'R'`.

---

**Navegação:** [⬅ Anterior: 3. Manipulação de Dados](3-manipulacao_dados.md) | [🏠 Índice](../README.md) | [Próximo: 5. Agregação e Agrupamento ➡](5-agregacao_agrupamento.md)
