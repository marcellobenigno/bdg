## 6. Trabalhando com Projeções

![](../img/proj1.jpg)   

A função [`ST_Transform`](https://postgis.net/docs/ST_Transform.html) reprojeta os dados de um determinado [**SRID**](https://en.wikipedia.org/wiki/Spatial_reference_system) para outro, alguns exemplos de uso:

1. Exibir as coordenadas da sede de João Pessoa em coordenadas geográficas e em UTM.

**Obs:** João Pessoa está no fuso UTM 25 Sul ([SRID=31985](https://spatialreference.org/ref/epsg/31985/))

![](../img/utm.png)  

```sql
SELECT ST_X(geom) AS longitude,
       ST_Y(geom) AS latitude,
       -- utilizando a função ST_transform:
       ST_X(ST_Transform(geom, 31985)) AS este,
       ST_Y(ST_Transform(geom, 31985)) AS norte
FROM sedes
WHERE nome = 'João Pessoa';
```

```
longitude            |      latitude      |       este        |       norte
---------------------+--------------------+-------------------+-------------------
 -34.824651912797535 | -7.153792036382988 | 298498.7976416113 | 9208850.233116478

```

2. Converter o o polígono do município de **Patos** para UTM ([SRID=31984](https://spatialreference.org/ref/epsg/31984/))


```sql
SELECT id,
       nome,
       ST_Transform(geom, 31984) AS geom
FROM municipios
WHERE nome = 'Patos';
```

```
id  |  nome | geom
----+---------------------------------------------------------------------------------------------------
185 | Patos | 0106000020F07C000001000000010300000001000000390100007C42BE3E136B2541F646BE51C6996141AB...
```

OBS: Nos casos onde as feições encontram-se entre dois fusos UTM, o ideal é utilizar outra projeção, a exemplo da *[SIRGAS 2000 / Brazil Polyconic](https://epsg.io/5880)*


3. Exibir o polígono município de **Campina Grande** em WKT, com a função [ST_AsText](https://postgis.net/docs/ST_AsText.html) na projeção *SIRGAS 2000 / Brazil Polyconic* ([SRID=5880](https://epsg.io/5880)):

```sql
SELECT id,
       nome,
       ST_AsText(ST_Transform(geom, 5880)) AS geom
FROM municipios
WHERE nome = 'Campina Grande';
```

```
id  |  nome | geom
----+------------------------------------------------------------------------------------------------------------------------
185 | Patos | MULTIPOLYGON(((6984415.880751882 9168813.491909271,6984617.081563575,...,6984415.880751882 9168813.491909271)))

```


### Exercícios:

1. Exiba a geometria da sede de **Cabedelo** em WKT, reprojetando os dados para UTM (SRID=31985).

2. Exiba a geometria do trecho **PB-195/0010** em WKT, reprojetando os dados para UTM (SRID=31984).

3. Crie uma nova tabela com o nome `municipios_5880` a partir da tabela dos municípios com os dados na projeção *SIRGAS 2000 / Brazil Polyconic* (SRID=5880).

4. A partir da tabela `pocos`, realize uma consulta que mostre os seguintes dados:

```
  id  |             proprietar             |       long        |        lat        |         x          |         y
------+------------------------------------+-------------------+-------------------+--------------------+-------------------
 1793 | Prefeitura Municipal De Santa Rita | -34.9743701325759 | -7.12963082107352 |  281947.4151248357 |  9211454.42324967
 1796 | Prefeitura Municipal De Santa Rita | -34.9758701428972 | -7.12485300395984 |  281779.4253809983 | 9211982.194475273
 1801 | Prefeitura Municipal De Santa Rita | -34.9597032986761 | -7.07893597984643 |   283544.133283274 |  9217068.69532908
 1802 | Prefeitura Municipal De Santa Rita | -34.9612033123317 | -7.07904709083605 | 283378.44039492897 | 9217055.706149789
 1803 | Prefeitura Municipal De Santa Rita | -34.9831480732369 | -7.25082623039927 | 281035.68849366327 | 9198044.592548119
 1804 | Prefeitura Municipal De Santa Rita | -34.9698006607888 | -7.15016432216079 | 282461.97829699726 | 9209185.350488713
 1811 | Prefeitura Municipal De Santa Rita | -34.9697589779756 | -7.12707524816124 | 282455.66803903715 | 9211739.274739217
 1812 | Prefeitura Municipal De Santa Rita | -34.8751719161153 | -6.98746863474929 | 292843.68343975255 | 9227223.933036119
 1815 | Prefeitura Municipal De Santa Rita | -34.9835645562417 | -6.97549068848409 | 280859.07233702636 |  9228499.73700465
 1816 | Prefeitura Municipal De Santa Rita |  -34.903369439297 | -7.05540805107573 | 289758.02688657783 |  9219696.90533202

```

5. Converta todas as geometrias das sedes que estão no fuso 25 Sul para UTM - SIRGAS 2000.
