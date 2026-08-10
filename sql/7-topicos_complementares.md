## 7. Tópicos Complementares (CASE, NULL, CAST)

Este último módulo da revisão de SQL fecha algumas lacunas comuns ao trabalhar com dados reais, e termina com um conceito que será usado o tempo todo a partir do próximo módulo: o **cast** de tipos.

### CASE — Lógica Condicional em uma Consulta

`CASE` permite classificar valores dentro de uma consulta, criando uma nova coluna calculada:

```sql
CASE
    WHEN condicao_1 THEN resultado_1
    WHEN condicao_2 THEN resultado_2
    ELSE resultado_padrao
END
```

```sql
-- Classificar os lotes por porte, de acordo com a área:
SELECT numero,
       area_m2,
       CASE
           WHEN area_m2 < 400 THEN 'Pequeno'
           WHEN area_m2 BETWEEN 400 AND 800 THEN 'Médio'
           ELSE 'Grande'
       END AS porte
FROM lote
ORDER BY area_m2;
```

```
 numero | area_m2 |  porte  
--------+---------+---------
 03     |  300.00 | Pequeno
 01     |  360.00 | Pequeno
 02     |  450.50 | Médio
 02     |  480.00 | Médio
 01     |  500.00 | Médio
 02     |  650.00 | Médio
 01     |  800.00 | Médio
 01     | 1200.00 | Grande
```

Isso é especialmente útil em Geoprocessamento para criar categorias de análise (por exemplo, classificar poços por faixa de profundidade, ou municípios por faixa de densidade populacional) diretamente na consulta, sem precisar de uma coluna extra na tabela.

### Tratamento de Valores NULL

Um valor `NULL` representa a **ausência de informação** — não é igual a zero, nem a uma string vazia, e não pode ser comparado com `=`.

```sql
-- ERRADO — nunca retorna nada, mesmo que existam linhas com uso_solo nulo:
SELECT * FROM lote WHERE uso_solo = NULL;

-- CERTO:
SELECT * FROM lote WHERE uso_solo IS NULL;
SELECT * FROM lote WHERE uso_solo IS NOT NULL;
```

Suponha que, ao cadastrar um novo lote, o campo `uso_solo` ainda não tenha sido definido (ficou `NULL`). *Não é necessário executar este `INSERT` no seu banco — é apenas ilustrativo:*

```sql
INSERT INTO lote (numero, area_m2, quadra_id) VALUES ('03', 420.00, 2);
-- uso_solo não foi informado: fica NULL
```

A função `COALESCE` substitui um valor `NULL` por um valor padrão, o que é muito útil para exibir relatórios sem colunas em branco:

```sql
SELECT numero,
       COALESCE(uso_solo, 'Não informado') AS uso_solo
FROM lote;
```

Dados espaciais reais têm valores nulos com frequência (um poço sem proprietário registrado, um trecho de rodovia sem jurisdição informada) — saber tratá-los evita que esses registros "desapareçam" silenciosamente de agregações e filtros.

### CAST — Convertendo entre Tipos de Dados

O operador de conversão de tipo (*cast*) transforma um valor de um tipo para outro. No PostgreSQL, a forma mais usada é o operador `::`:

```sql
SELECT valor::tipo_desejado;
```

```sql
-- Convertendo um número para texto:
SELECT area_m2, area_m2::text AS area_texto
FROM lote
WHERE id = 2;
```

```
 area_m2 | area_texto 
---------+------------
  450.50 | 450.50
```

```sql
-- Convertendo (arredondando) um numeric para integer:
SELECT area_m2, area_m2::integer AS area_arredondada
FROM lote
WHERE id = 2;
```

```
 area_m2 | area_arredondada 
---------+------------------
  450.50 |              451
```

> 💡 **Por que isso importa para PostGIS**: a partir do próximo módulo, você vai usar o `CAST` o tempo inteiro, na forma `geometry::geography`, para poder calcular área, distância e comprimento em metros/quilômetros em vez de graus. É exatamente o mesmo operador `::` que acabamos de ver — só que convertendo entre dois tipos espaciais em vez de `numeric` e `text`.

### Nota: Funções de Janela (Window Functions)

Mais adiante, em alguns exemplos do PostGIS, você vai encontrar a função `ROW_NUMBER() OVER()`. Ela não é uma função de agregação nem faz parte do escopo desta revisão — fica aqui só a referência: ela numera sequencialmente as linhas do resultado.

```sql
SELECT ROW_NUMBER() OVER () AS id, nome
FROM proprietario;
```

### Exercícios:

1. Escreva uma consulta com `CASE` que classifique os rios em `'Curto'` (até 150 km) ou `'Longo'` (acima de 150 km).
2. Suponha que a coluna `uso_solo` de um lote esteja `NULL`. Escreva a consulta que lista todos os lotes cujo `uso_solo` **não** está preenchido.
3. Reescreva a consulta do exercício anterior usando `COALESCE` para exibir `'Sem uso definido'` no lugar do valor nulo.
4. Converta o valor de `potencia_watts` da tabela `poste` para `numeric` e divida por `1000`, para obter a potência em quilowatts (`kW`).
5. Combine `CASE` com `COUNT` e `GROUP BY` para contar quantos lotes são `'Pequeno'`, `'Médio'` e `'Grande'`, usando os mesmos critérios do exemplo desta seção.

---

Você concluiu a revisão de SQL convencional. Os comandos `CREATE`, `INSERT`, `SELECT`, `WHERE`, `JOIN`, `GROUP BY`, `HAVING` e o operador `::` (cast) que você praticou aqui são exatamente os mesmos que serão usados a partir de agora — a única novidade a partir do próximo módulo é um novo tipo de dado, o `geometry`, e um conjunto de funções (`ST_*`) que operam sobre ele.

**Navegação:** [⬅ Anterior: 6. Relacionamentos entre Tabelas (JOINs)](6-relacionamentos_joins.md) | [🏠 Índice](../README.md) | [Próximo: PostGIS 1. Introdução ➡](../postgis/1-introducao.md)
