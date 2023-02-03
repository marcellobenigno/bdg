## 8. Relacionamentos Espaciais

Uma das características mais relevantes dos Bancos de Dados Geográficos, é a capacidade de comparar as relações espaciais entre as geometrias. Neste tópico iremos explorar alguns exemplos utilizando as funções topológicas mais usuais.


### [ST_Equals](https://postgis.net/docs/ST_Equals.html)

Testa se duas geometrias são iguais:

<div align=center>
	<img src="../img/img_st_equals.jpg" width="500px" />
</div>


```sql
/* Qual é a sede que possui a geometria igual ao ponto com
coordenadas x=-37.958771071678186 e y=-7.014295589558234 */
SELECT nome, ST_Astext(geom)
FROM sedes
WHERE ST_Equals(geom, ST_GeomFromText('POINT(-37.958771071678186 -7.014295589558234)', 4326));
```

```
  nome   |                   st_astext
---------+-----------------------------------------------
 Coremas | POINT(-37.958771071678186 -7.014295589558234)
```

![](../img/st_equals.jpg)


### [ST_Intersects](https://postgis.net/docs/ST_Intersects.html)

Compara duas geometrias e retorna verdadeiro se elas se intersectarem (se tiverem algum ponto em comum):

<div align=center>
	<img src="../img/img_st_intersects.jpg" width="500px" />
</div>

```sql
-- Quais são os trechos de rodovias que intersectam o município de Guarabira?
SELECT a.rodovia_nome, a.codigo
FROM malha_viaria a,
     municipios b
WHERE ST_Intersects(a.geom, b.geom)
  AND b.nome = 'Guarabira'
ORDER BY codigo;
```

```
 rodovia_nome |      codigo
--------------+-------------------
 Acesso       | AC1/PB-057/PB-073
 Acesso       | AC1/PB-073
 PB-057       | PB-057/0030
 PB-057       | PB-057/0040
 PB-073       | PB-073/0040
 PB-073       | PB-073/0050
 PB-073       | PB-073/0060
 PB-075       | PB-075/0030
```

![](../img/st_intersects.jpg)


### [ST_Disjoint](https://postgis.net/docs/ST_Disjoint.html)

É o oposto da função ST_Intersects, ST_Disjoint verifica se duas geometrias são disjuntas, ou seja, não possuem nenhum ponto em comum:

<div align=center>
	<img src="../img/img_st_disjoint.jpg" width="500px" />
</div>


```sql
-- Quais são os municípios que não fazem fronteira com o município de Taperoá?
SELECT a.id, a.nome
FROM municipios a,
     municipios b
WHERE ST_Disjoint(a.geom, b.geom)
  AND b.nome = 'Taperoá';
```

```
 id  |              nome
-----+--------------------------------
   1 | Baraúna
   2 | Barra de Santana
   3 | Bayeux
   4 | Boqueirão
   5 | Campina Grande
   6 | Itabaiana
   ... ...
```


![](../img/st_disjoint.jpg)


### [ST_Crosses](https://postgis.net/docs/ST_Crosses.html)

Compara duas geometria e retorna verdadeiro se sua interseção "cruzar espacialmente" a outra, ou seja, as geometrias possuem alguns, mas não todos os pontos internos em comum. A interseção dos interiores das geometrias não deve ser vazia e deve ter dimensão menor que a dimensão máxima das duas geometrias de entrada. Além disso, a interseção das duas geometrias não deve ser igual a nenhuma das geometrias de origem. Caso contrário, ele retorna falso.

<div align=center>
  <img src="../img/img_st_crosses.jpg" width="500px" />
</div>

```sql
/* Quais são os municípios que são cortados pela BR-230 e
   a quantidade de trechos dessa rodovia por município? */
SELECT a.nome, b.rodovia_nome, COUNT(b.codigo) AS qtde_trechos
FROM municipios a,
     malha_viaria b
WHERE ST_Crosses(b.geom, a.geom)
  AND b.rodovia_nome = 'BR-230'
GROUP BY b.rodovia_nome, a.nome
ORDER BY a.nome;
```

```
           nome           | rodovia_nome | qtde_trechos
--------------------------+--------------+--------------
 Aparecida                | BR-230       |            2
 Assunção                 | BR-230       |            1
 Boa Vista                | BR-230       |            1
 Bom Jesus                | BR-230       |            2
 Cabedelo                 | BR-230       |            1
 Cachoeira dos Índios     | BR-230       |            3
 ...                        ...                     ...
```

![](../img/st_crosses.jpg)

### [ST_Overlaps](https://postgis.net/docs/ST_Overlaps.html)

Retorna verdadeiro se as geometrias A e B possuírem uma sobreposição entre seus vértices.

<div align=center>
  <img src="../img/img_st_overlaps.jpg" width="350px" />
</div>

```sql
-- Quais são os trechos de rodovia que estão se sobrepondo?
SELECT a.id, a.codigo
FROM malha_viaria a,
     malha_viaria b
WHERE ST_Overlaps(a.geom, b.geom)
  AND a.id <> b.id;
```

```
 id  |   codigo
-----+-------------
  25 | BR-412/0050
 252 | PB-085/0070
 263 | PB-008/0040
 266 | AC0/PB-323
 349 | PB-148/0060
 403 | PB-069/0030
 529 | PB-018/0030
 561 | PB-323/0040
 561 | PB-323/0040
 625 | PB-325/0060
```

![](../img/st_overlaps.jpg)
