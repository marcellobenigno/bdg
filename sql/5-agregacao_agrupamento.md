## 5. Agregação e Agrupamento (COUNT, SUM, AVG, MIN, MAX, GROUP BY, HAVING)

### Funções de Agregação

São funções de agregação:

* `AVG( )` — retorna o valor médio;
* `COUNT( )` — retorna o número de linhas;
* `MAX( )` — retorna o maior valor;
* `MIN( )` — retorna o menor valor;
* `SUM( )` — retorna a soma.

Se quisermos agrupar linhas com base nos valores de uma coluna, usamos as funções acima em conjunto com `GROUP BY`.

### Exemplo 1 — Estatísticas Simples (sem agrupamento)

```sql
-- Quantos lotes existem, qual a área média, mínima e máxima?
SELECT COUNT(*) AS qtde_lotes,
       ROUND(AVG(area_m2), 2) AS area_media,
       MIN(area_m2) AS area_minima,
       MAX(area_m2) AS area_maxima
FROM lote;
```

```
 qtde_lotes | area_media | area_minima | area_maxima
------------+------------+-------------+-------------
      8     |   592.56   |    300.00   |   1200.00
```

> 💡 Sem o `ROUND`, `AVG` retorna todas as casas decimais possíveis (`592.5625000000000000`). Usar `ROUND(expressao, 2)` deixa o resultado mais legível — o mesmo padrão que os módulos de PostGIS usam ao arredondar áreas com `::numeric(10,2)`.

### Exemplo 2 — Agrupando com GROUP BY

```sql
-- Qual é a área total de lotes por quadra?
SELECT quadra_id,
       SUM(area_m2) AS area_total_m2
FROM lote
GROUP BY quadra_id
ORDER BY quadra_id;
```

```
 quadra_id | area_total_m2
-----------+----------------
     1     |     1110.50
     2     |      980.00
     3     |     1450.00
     4     |     1200.00
```

```sql
-- Quantos postes existem em cada logradouro?
SELECT logradouro_id,
       COUNT(*) AS qtde_postes
FROM poste
GROUP BY logradouro_id
ORDER BY logradouro_id;
```

```
 logradouro_id | qtde_postes
---------------+--------------
       1       |      3
       2       |      3
       3       |      1
```

> ⚠️ Repare que o `logradouro_id = 4` (Travessa Nova) **não aparece** nesse resultado — ela não tem nenhum poste cadastrado, e o `GROUP BY` só mostra grupos que existem na tabela `poste`. No módulo 6 vamos ver como, usando `LEFT JOIN`, é possível incluir esse caso e mostrar `0` postes para a Travessa Nova.

```sql
-- Qual é a extensão total de rios por bacia hidrográfica?
SELECT bacia_id,
       SUM(extensao_km) AS extensao_total_km
FROM rio
GROUP BY bacia_id
ORDER BY extensao_total_km DESC;
```

```
 bacia_id | extensao_total_km
----------+---------------------
    1     |       508.50
    2     |       378.53
    3     |       175.00
```

### Filtrando Grupos com HAVING

O `WHERE` filtra **linhas antes** do agrupamento; o `HAVING` filtra **grupos depois** do agrupamento — por isso `HAVING` pode usar funções de agregação (`WHERE` não pode).

```sql
-- Quais quadras têm mais de 2 lotes cadastrados?
SELECT quadra_id,
       COUNT(*) AS qtde_lotes
FROM lote
GROUP BY quadra_id
HAVING COUNT(*) > 2;
```

```
 quadra_id | qtde_lotes
-----------+-------------
     1     |      3
```

```sql
-- Quais bacias hidrográficas têm mais de 400 km de rios somados?
SELECT bacia_id,
       SUM(extensao_km) AS extensao_total_km
FROM rio
GROUP BY bacia_id
HAVING SUM(extensao_km) > 400;
```

```
 bacia_id | extensao_total_km
----------+---------------------
    1     |       508.50
```

### Exercícios:

1. Qual é a quantidade de lotes e a área média (`area_m2`) por `uso_solo`?
2. Qual é a menor e a maior `extensao_km` entre todos os rios cadastrados?
3. Quantos lotes cada `quadra_id` possui? Ordene o resultado da maior para a menor quantidade.
4. Quais logradouros têm 3 ou mais postes cadastrados? Utilize `HAVING`.
5. Qual bacia hidrográfica tem a menor soma de `extensao_km` entre seus rios?
6. Existe alguma `quadra_id` cuja soma de `area_m2` dos lotes seja maior que 1000 m²? Utilize `HAVING`.
