## 7. Cálculos de Área, Perímetro, Distância e Comprimento

A forma geométrica dos objetos pode ser codificada usando os tipos
 de dados **GEOMETRY** ou **GEOGRAPHY**:


 * **GEOMETRY**:
 	- Assume-se que a projeção já foi feita, e os cálculos são planares (cartesianos);
 	- Coordenadas: lat/long ou metros (UTM)
 	- Unidade de medida: a mesma do sistema de coordenadas
 
 * **GEOGRAPHY**:
 	- Os cálculos são geodésicos e feitos em um esferóide
 	- Coordenadas: sempre lat/long, GCS
 	- Unidade de medida: metros
 	

 	![](../img/cartesian_spherical.jpg)


### Exemplos de Cálculos de Área:
 
```sql
-- Qual é a área do município em João Pessoa:
SELECT nome,
       ST_Area(geom)
FROM municipios
WHERE nome = 'João Pessoa';
```

```
    nome     |       st_area
-------------+----------------------
 João Pessoa | 0.017312030628372724
```

Esta consulta retorna um valor de área em **graus ao quadrado**, o que não faz sentido algum. Isto acontece porque os dados originalmente estão armazenados em coordenadas geográficas (SRID=4326):

Para obter o valor de área em unidades métricas, podemos realizar um [casting](https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-cast/) da coluna do tipo `geometry` para `geography`:


```sql
-- Qual é a área do município em João Pessoa em km²:
SELECT nome,
       ST_Area(geom::geography) / 1000000 AS area_km2
FROM municipios
WHERE nome = 'João Pessoa';
```

```
    nome     |      area_km2
-------------+--------------------
 João Pessoa | 211.47480565570834
```


Pode-se também utilizar a função [ST_Transform](https://postgis.net/docs/ST_Transform.html) para projetar os dados, porém deve-se ter cuidado em relação a projeção a ser escolhida e o grau de precisão da medição.

```sql
-- Qual é a área do município em João Pessoa em km²:
SELECT nome,
       ST_Area(ST_Transform(geom, 31985)) / 1000000 AS area_km2
FROM municipios
WHERE nome = 'João Pessoa';
```

```
  nome       |     area_km2
-------------+-------------------
 João Pessoa | 211.5289234756967
```


```sql
-- Qual são as 4 maiores microrregiões do estado?
SELECT microregiao, SUM(ST_Area(geom::geography)) / 1000000 AS area_total_km
FROM municipios
GROUP BY microregiao
ORDER BY microregiao DESC
LIMIT 4
```

```
        microregiao        |   area_total_km
---------------------------+--------------------
 Umbuzeiro                 | 1181.3466039563002
 Sousa                     |  4803.692920970653
 Serra do Teixeira         | 2623.2868522739354
 Seridó Oriental Paraibano |  2604.822051787238
```

### Exemplos de Cálculos de Perímetro:

```sql
-- Qual é o perímetro do estado da Paraíba?
SELECT ST_Perimeter(geom::geography)/1000 AS perimetro_km
FROM estados_ne
WHERE nome = 'Paraíba';
```

```
    perimetro_km
--------------------
 2111.7086104387813
```

```sql
-- Qual é o perímetro do estado de Campina Grande?
SELECT ST_Perimeter(geom::geography)/1000 AS perimetro_km
FROM municipios
WHERE nome = 'Campina Grande';
```

```
    perimetro_km
--------------------
 169.69738106899214
```

### Exemplos de Cálculos de Distância:

```sql
-- Qual é a menor distância em quilômetros, entre os municípios de Patos e Campina Grande?
SELECT ST_Distance(a.geom::geography, b.geom::geography) / 1000 AS menor_dist_km
FROM municipios a, municipios b
WHERE a.nome = 'Patos'
AND b.nome = 'Campina Grande';
```

```
 menor_dist_km
----------------
 120.6210678785
```

```sql
/* Qual é a menor distância entre os poços onde o proprietário é
"Prefeitura Municipal De Pedras De Fogo" e a sede desta mesma prefeitura?
Ordene o resultado pela distância, exibindo os campos id e proprietar da tabela pocos */
SELECT
	p.id,
	p.proprietar,
	ST_Distance(p.geom::geography, s.geom::geography) AS menor_dist_m
FROM
	pocos p,
	sedes s
WHERE
	p.proprietar = 'Prefeitura Municipal De Pedras De Fogo'
AND 	s.nome = 'Pedras de Fogo'
ORDER BY 
	menor_dist_m;
```

```
  id  |               proprietar               | menor_dist_m
------+----------------------------------------+---------------
 1770 | Prefeitura Municipal De Pedras De Fogo |  534.92017141
 1764 | Prefeitura Municipal De Pedras De Fogo |  626.27787958
 1765 | Prefeitura Municipal De Pedras De Fogo | 1539.58728737
 1773 | Prefeitura Municipal De Pedras De Fogo | 8430.89631253
```

### Exemplos de Cálculos de Comprimento:

```sql
-- Qual é o comprimento total do Rio Piranhas?
SELECT nome, SUM(ST_Length(geom::geography)) / 1000 AS comp_total_km
FROM drenagem
WHERE nome = 'Rio Piranhas'
GROUP BY nome;
```

```
     nome     |   comp_total_km
--------------+--------------------
 Rio Piranhas | 233.33329621372087
```

```sql
-- Qual é o comprimento total das rodovias pavimentadas?
SELECT SUM(st_length(geom::geography)) / 1000 AS comp_total_km
FROM malha_viaria
WHERE sit_fisica = 'Pavimentada';
```

```
   comp_total_km
-------------------
 4689.500067302273
```

### Exercícios:

1. Qual é a área em hectares, do município de Patos?
2. Qual é a área total em km² dos estados da Paraíba e do Rio Grande do Norte?
3. Crie uma consulta que retorne os nomes das mesorregiões e seus valores de área em km², ordenadas de forma crescente.
4. Qual é o município de maior área do estado?
5. Calcule o valor da área do município de Santa Rita, projetando antes a sua geometria para UTM.
6. Qual a menor distância entre a sede de Areia e a de Campina Grande?
7. Exiba as cinco sedes mais próximas de Patos, com as suas respectivas distâncias.
8. Qual é o perímetro de Lagoa Seca? exiba os valores em km e em metros na mesma consulta.
9. Qual é o comprimento total da rodovia PB-008?
10. Exiba o comprimento total das rodovias, ordenadas pelo campo "jurisdicao".
11. Qual é a rodovia de menor extensão? 
