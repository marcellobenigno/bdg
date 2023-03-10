## 9. Funções que Geram Novas Geometrias

As funções de construção de geometria permitem a criação de objetos geométricos, como pontos, linhas e polígonos. Nesta seção iremos explorar o uso das principais funções que se destinam a esse propósito.

### [ST_Centroid](https://postgis.net/docs/ST_Centroid.html) / [ST_PointOnSurface](https://postgis.net/docs/ST_PointOnSurface.html)

![ST_Centroid - ST_PointOnSurface](../img/img_st_centroid.jpg)

A função `ST_Centroid` é usada para calcular o centróide (ou centro de massa) de um objeto geométrico. É importante ressaltar que o centróide não precisa estar localizado dentro do objeto geométrico em si.

```sql
-- Gere os centróides dos estados de Pernambuco, Paraíba e Rio Grande do Norte.
SELECT id, ST_Centroid(geom) AS geom
FROM estados_ne
WHERE abreviacao IN ('PE','PB','RN');
```

```
 id |                        geom
----+----------------------------------------------------
  5 | 0101000020E61000006133218C8C6A42C042214058F27B1CC0
  7 | 0101000020E6100000014A7A7B345642C06DE34150D45B17C0
  9 | 0101000020E6100000FA193B76CCFF42C025BEED1FF2A620C0
```

![ST_Centroid](../img/st_centroid.jpg)

Já a função `ST_PointOnSurface` gera um ponto central aproximado de uma geometria. Com esta função, é possível, por exemplo, encontrar um ponto que esteja dentro de um polígono e que possa ser usado como uma localização central para o mesmo.

```sql
-- Gere um ponto dentro da superfície para cada município por onde passa a BR-230.

SELECT DISTINCT a.id, a.nome, st_pointonsurface(a.geom) AS geom
FROM municipios a,
     malha_viaria b
WHERE ST_Intersects(b.geom, a.geom)
AND b.rodovia_nome = 'BR-230';
```

```
 id  |           nome           |                        geom
-----+--------------------------+----------------------------------------------------
   5 | Campina Grande           | 0101000020E61000003C481839B2F941C0E017409410151DC0
   8 | João Pessoa              | 0101000020E61000006E88200D326D41C0008ADF8F4F991CC0
  11 | Marizópolis              | 0101000020E6100000DF8BEA8E4F2B43C060321AC25E491BC0
  18 | Santa Rita               | 0101000020E6100000EAB0512AEE7D41C080E86654ED611CC0
  28 | Malta                    | 0101000020E610000083EF809EF7C342C0806E49C149881BC0
  38 | São João do Rio do Peixe | 0101000020E61000009AC5C94F1D3643C00013C5AC1C031BC0
  41 | Aparecida                | 0101000020E61000007CE923EDBA0943C0200B50A017221BC0
  ...
```

![ST_PointOnSurface](../img/st_pointonsurface.jpg)




### Exercícios:

1. Gere centróides para os municípios da microrregião do Piancó.

2. Gere pontos na superfície para os polígonos da camada `densidade_pb` que estão localizados na mesorregião do Sertão Paraibano.


