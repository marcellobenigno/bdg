## 8. Relacionamentos Espaciais

Uma das características mais relevantes dos Bancos de Dados Geográficos, é a capacidade de comparar as relações espaciais entre as geometrias. Neste tópico iremos explorar alguns exemplos utilizando algumas das funções topológicas mais usuais.


### [ST_Equals](https://postgis.net/docs/ST_Equals.html)

Testa se duas geometrias são iguais:

<div align=center>
	<img src="../img/img_st_equals.jpg" width="600px" />
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
	<img src="../img/img_st_intersects.jpg" width="600px" />
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
	<img src="../img/img_st_disjoint.jpg" width="600px" />
</div>


```sql
-- Quais são os municípios que não fazem fronteira com o município de Taperoá?
SELECT a.id, a.nome
FROM municipios a,
     municipios b
WHERE ST_Disjoint(a.geom, b.geom)
  AND b.nome = 'Taperoá';
```

![](../img/st_disjoint.jpg)






