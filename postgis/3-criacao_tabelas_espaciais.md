## 3. Criação de Tabelas Espaciais

A criação de tabelas com o PostGIS, pode ser feita de duas formas, sendo exemplificadas a seguir:

* Criando a coluna com o tipo de geometria **após** a criação da tabela, com o comando [`AddGeometryColumn`](https://postgis.net/docs/AddGeometryColumn.html):


```sql
CREATE TABLE pontos (
	id serial PRIMARY KEY
);
SELECT AddGeometryColumn('public', 'pontos', 'geom', 4326, 'POINT', 2);
```

Os parâmetros do comando [`AddGeometryColumn`](https://postgis.net/docs/AddGeometryColumn.html) são:

```sql
SELECT AddGeometryColumn(
	'esquema', -- esquema do banco de dados onde foi criada a tabela
	'nome_da_tabela', -- nome da tabela onde será adicionada a coluna
	'nome_da_coluna', -- nome da coluna espacial
	srid, -- Sistema de Refeência dos Dados
	'tipo_geometria', -- Tipo de Geometria: POINT, POLYGON, LINESTRING, etc.
	dimensao -- 2 para 2D ou 3 para 3D
);
```


* Ou, informando diretamente o tipo de geometria na instrução SQL do `CREATE`:

```sql
CREATE TABLE pontos (
	id serial PRIMARY KEY,
	geom geometry(POINT, 4326)
);
```

Recomenda-se rodar o comando [`Populate_Geometry_Columns`](https://postgis.net/docs/Populate_Geometry_Columns.html) para que a tabela seja registrada de forma correta na **view** de metadados `geometry_columns`.

Quando é adicionado ao comando `Populate_Geometry_Columns` a *flag* `false`, como mostra o exemplo abaixo:

```sql
SELECT Populate_Geometry_Columns('public.minha_tabela_espacial'::regclass, false);
```

São criadas as `constraints` a seguir:

* `enforce_dims_geom`: garante que cada geometria tenha a mesma dimensão;

* `enforce_geotype_geom`: garante que cada geometria seja do mesmo tipo;

* `enforce_srid_geom`: garante que cada geometria esteja no mesmo sistema de referência (SRID).

### Tabela `spatial_ref_sys` e View `geometry_columns`:

![relações](../img/table_relationships.png)

Em conformidade com a especificação *Simple Features for SQL (SFSQL)*, o PostGIS fornece uma tabela (`spatial_ref_sys`) e uma *view* para rastrear e relatar os tipos de geometria disponíveis em um determinado banco de dados.

A tabela, `spatial_ref_sys`, define todos os Sistemas de Referência, e estes podem ser identificados através de um código chamado *Spatial Reference System Identifier - SRID*.

Toda geometria armazenada no PostGIS possui um identificador de referência espacial ou "SRID".

Os valores de SRID ≠ -1 indicam que os dados estão associados a um sistema de referência.

Para encontrar mais informações sobre Sistemas de Referência Espacial, acesse o site: http://spatialreference.org/.

Alguns Exemplos de SRID:

- SIRGAS 2000 LAT/LONG = 4674
- WGS-84 LAT/LONG = 4326
- SIRGAS 2000 / UTM zone 24S = 31984
- SIRGAS 2000 / UTM zone 25S = 31985

Já a *view* `geometry_columns` fornece uma listagem de todas as tabelas espaciais registradas e informações básicas sobre as mesmas.


### Tipos de Geometria

![tipos de geometria](../img/tipos_geometria.png)

### Representação de geometrias nos formatos Well-known Binary e Well-known text (WKT)

A especificação da OGC define duas formas padrão de expressar objetos espaciais: *Well-Known Text (WKT)* e *Well-Known Binary (WKB)*:

* A representação WKB é mais compacta e aparece nas colunas geométricas das tabelas PostGIS:

![](../img/wkb.png)

* A representação WKT separa vértices com vírgulas e parênteses para envolver os vértices. A quantidade de parênteses utilizado vai depender do tipo de geometria:

![](../img/geometry_primitives.png)
![](../img/multipart.png)


### Exemplos:

#### Crie as tabelas a seguir:

![Tabelas de Exemplo](../img/tabelas_exemplo.jpg)

```sql
CREATE TABLE pnt_interesse (
    id serial PRIMARY KEY,
    nome varchar(100),
    dt_coleta date
);
SELECT AddGeometryColumn('public', 'pnt_interesse', 'geom', 4326, 'POINT', 2);

-- **************************************************************************** --

CREATE TABLE adutora (
    id serial PRIMARY KEY,
    descricao varchar(50)
);
SELECT AddGeometryColumn('public', 'adutora', 'geom', 4326, 'LINESTRING', 2);

-- **************************************************************************** --

CREATE TABLE area_estudo (
    id serial PRIMARY KEY,
    nome varchar(50)
);
SELECT AddGeometryColumn('public', 'area_estudo', 'geom', 4326, 'POLYGON', 2);

```

Ou, através do segundo método:

```sql
CREATE TABLE pnt_interesse (
    id serial PRIMARY KEY,
    nome varchar(100),
    dt_coleta date,
    geom geometry(POINT, 4326)
);

-- **************************************************************************** --

CREATE TABLE adutora (
    id serial PRIMARY KEY,
    descricao varchar(50),
    geom geometry(LINESTRING, 4326)
);

-- **************************************************************************** --

CREATE TABLE area_estudo (
    id serial PRIMARY KEY,
    nome varchar(50),
    geom geometry(POLYGON, 4326)
);
```

### Exercícios:

1. Para as tabelas a seguir:

![Exercício](../img/fig_exercicio.jpg)

1.1 - Crie as tabelas utilizando a função `AddGeometryColumn`.

1.2 - Apague as tabelas criadas anteriormente e as recrie com o segundo método, em seguida utilize a função `Populate_Geometry_Columns` para cada uma das tabelas criadas.



