## 7. Cálculos de Área, Distância e Comprimento

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

Esta consulta retorna um valor de área em **graus ao quadrado**, o que não faz sentido algum. Isto acontece porque os dados originalmente estão armazenados em coordenadas geográficas (SRID=4326):

```
    nome     |       st_area
-------------+----------------------
 João Pessoa | 0.017312030628372724
```

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

### Exemplos de Cálculos de Distância:

```sql
-- Qual é a menor distância em quilômetros, entre os municípios de Patos e Campina Grande?
SELECT ST_Distance(a.geom::geography, b.geom::geography) / 1000 AS menor_dist_km
FROM municipios a, municipios b
WHERE a.nome = 'Patos'
AND b.nome = 'Campina Grande';
```

```sql
/* Qual é a menor distância entre os poços cujo proprietário é
"Prefeitura Municipal De Pedras De Fogo" e a Sede desta mesma prefeitura?
Ordene o resultado pela distância */
SELECT p.id,
	   p.proprietar,
	   ST_Distance(p.geom::geography, s.geom::geography) AS menor_dist_m
FROM pocos p,
     sedes s
WHERE p.proprietar = 'Prefeitura Municipal De Pedras De Fogo'
  AND s.nome = 'Pedras de Fogo'
ORDER BY menor_dist_m;
```

```
  id  |               proprietar               | menor_dist_m
------+----------------------------------------+---------------
 1770 | Prefeitura Municipal De Pedras De Fogo |  534.92017141
 1764 | Prefeitura Municipal De Pedras De Fogo |  626.27787958
 1765 | Prefeitura Municipal De Pedras De Fogo | 1539.58728737
 1773 | Prefeitura Municipal De Pedras De Fogo | 8430.89631253
```

