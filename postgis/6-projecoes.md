## 6. Trabalhando com Projeções

A função [`ST_Transform`](https://postgis.net/docs/ST_Transform.html) reprojeta os dados de um determinado [**SRID**](https://en.wikipedia.org/wiki/Spatial_reference_system) para outro, alguns exemplos de uso:

1. Exibir as coordenadas da sede de João Pessoa em coordenadas geográficas e em UTM.

**Obs:** João Pessoa está no fuso UTM 25 Sul ([SRID=31985](https://spatialreference.org/ref/epsg/31985/))

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