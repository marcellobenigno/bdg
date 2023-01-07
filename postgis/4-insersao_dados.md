## 4 - Inserção de Dados

Neste tópico serão apresentados exemplos de inserção de dados em tabelas espaciais, bem como a utilização da função `ST_GeomFromText()` que permite esta ação, exemplos:

- Para uma tabela de **pontos**:

```sql
CREATE TABLE sede ( 
	id serial PRIMARY KEY, 
	nome_sede varchar(50), 
	geom geometry('POINT', 4674) 
);
SELECT Populate_Geometry_Columns('public.sede'::regclass);

-- ************** Inserindo duas sedes: ************** --

INSERT INTO sede (nome_sede, geom) VALUES 
( 'Aparecida', ST_GeomFromText('POINT(-38.0863 -6.7870)', 4674)), 
('São Domingos', ST_GeomFromText('POINT(-37.9375 -6.8154)', 4674));
```

- Para uma tabela de **linhas**:

```sql
CREATE TABLE adutora ( 
	id serial PRIMARY KEY, 
	nome_adutora varchar(50), 
	geom geometry('LINESTRING', 4674) 
);
SELECT Populate_Geometry_Columns('public.adutora'::regclass);

-- Inserindo uma adutora:
INSERT INTO adutora (nome_adutora, geom) VALUES
(
	'Nova Obra',
	 ST_GeomFromText(
	 	'LINESTRING( -37.9824 -7.0070, -37.9041 -6.8928, -37.9170 -6.8060)', 4674
	 )
);
```

- Para uma tabela de **polígonos**:

```sql
CREATE TABLE area_estudo (
    id   serial PRIMARY KEY,
    geom geometry('POLYGON', 4674)
);
SELECT populate_geometry_columns('public.area_estudo'::regclass);

INSERT INTO area_estudo (geom)
VALUES (st_geomfromtext(
'POLYGON((-38.11057930070635535 -6.81695358721672307,
          -38.1184928413115145 -6.90993768932727548,
          -38.03540066495740035 -6.92378638538629421,
          -38.0294655095035381 -6.82684551297316489,
          -38.11057930070635535 -6.81695358721672307))', 4674)
);

```