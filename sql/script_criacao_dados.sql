-- ============================================================
-- Script de criação e carga do schema de exemplo
-- Banco de Dados Geográficos - Revisão de SQL Convencional
-- Domínio: cadastro urbano (quadras, lotes, logradouros, postes)
--          e dados ambientais (bacias hidrográficas, rios)
--
-- Este script reúne os comandos apresentados nos módulos
-- sql/2-criacao_alteracao_tabelas.md e sql/3-manipulacao_dados.md.
-- Pode ser executado diretamente com psql, pgAdmin ou QGIS.
-- ============================================================

-- Remove as tabelas, caso já existam, para permitir reexecução do script
DROP TABLE IF EXISTS lote_proprietario CASCADE;
DROP TABLE IF EXISTS poste CASCADE;
DROP TABLE IF EXISTS logradouro CASCADE;
DROP TABLE IF EXISTS lote CASCADE;
DROP TABLE IF EXISTS quadra CASCADE;
DROP TABLE IF EXISTS rio CASCADE;
DROP TABLE IF EXISTS bacia_hidrografica CASCADE;
DROP TABLE IF EXISTS proprietario CASCADE;

-- ============================================================
-- CRIAÇÃO DAS TABELAS
-- ============================================================

-- ambiental: bacia hidrográfica (1) -> rio (N)
CREATE TABLE bacia_hidrografica (
    id       serial PRIMARY KEY,
    nome     varchar(80) NOT NULL,
    area_km2 numeric(10,2) CHECK (area_km2 > 0)
);

CREATE TABLE rio (
    id           serial PRIMARY KEY,
    nome         varchar(80) NOT NULL,
    extensao_km  numeric(10,2) CHECK (extensao_km > 0),
    bacia_id     integer NOT NULL REFERENCES bacia_hidrografica (id)
);

-- cadastral: quadra (1) -> lote (N)
CREATE TABLE quadra (
    id          serial PRIMARY KEY,
    codigo      varchar(10) NOT NULL UNIQUE,
    zoneamento  varchar(20) CHECK (zoneamento IN ('Residencial', 'Comercial', 'Industrial'))
);

CREATE TABLE lote (
    id         serial PRIMARY KEY,
    numero     varchar(5) NOT NULL,
    area_m2    numeric(10,2) CHECK (area_m2 > 0),
    uso_solo   varchar(20),
    quadra_id  integer NOT NULL REFERENCES quadra (id)
);

-- infraestrutura: logradouro (1) -> poste (N)
CREATE TABLE logradouro (
    id          serial PRIMARY KEY,
    nome        varchar(80) NOT NULL,
    hierarquia  varchar(20) CHECK (hierarquia IN ('Arterial', 'Coletora', 'Local'))
);

CREATE TABLE poste (
    id              serial PRIMARY KEY,
    tipo            varchar(20),
    potencia_watts  integer,
    logradouro_id   integer NOT NULL REFERENCES logradouro (id)
);

-- relacionamento N:N: lote <-> proprietario, via tabela associativa
CREATE TABLE proprietario (
    id    serial PRIMARY KEY,
    nome  varchar(80) NOT NULL,
    cpf   char(11) NOT NULL UNIQUE
);

CREATE TABLE lote_proprietario (
    lote_id           integer NOT NULL REFERENCES lote (id),
    proprietario_id   integer NOT NULL REFERENCES proprietario (id),
    percentual_posse  numeric(5,2) NOT NULL CHECK (percentual_posse > 0 AND percentual_posse <= 100),
    PRIMARY KEY (lote_id, proprietario_id)
);

-- ============================================================
-- INSERÇÃO DE DADOS
-- ============================================================

INSERT INTO bacia_hidrografica (nome, area_km2) VALUES
('Rio Paraíba',       20071.83),
('Rio Piranhas-Açu',  43681.50),
('Rio Mamanguape',     3958.31);

INSERT INTO rio (nome, extensao_km, bacia_id) VALUES
('Rio Paraíba',    380.00, 1),
('Rio Taperoá',    128.50, 1),
('Rio Piranhas',   233.33, 2),
('Rio do Peixe',   145.20, 2),
('Rio Mamanguape',  175.00, 3);

INSERT INTO quadra (codigo, zoneamento) VALUES
('Q-101', 'Residencial'),
('Q-102', 'Residencial'),
('Q-103', 'Comercial'),
('Q-201', 'Industrial');

INSERT INTO lote (numero, area_m2, uso_solo, quadra_id) VALUES
('01',  360.00, 'Residencial', 1),
('02',  450.50, 'Residencial', 1),
('03',  300.00, 'Residencial', 1),
('01',  500.00, 'Residencial', 2),
('02',  480.00, 'Residencial', 2),
('01',  800.00, 'Comercial',   3),
('02',  650.00, 'Comercial',   3),
('01', 1200.00, 'Industrial',  4);

INSERT INTO logradouro (nome, hierarquia) VALUES
('Av. Getúlio Vargas', 'Arterial'),
('Rua das Acácias',    'Local'),
('Rua do Comércio',    'Coletora'),
('Travessa Nova',      'Local');

INSERT INTO poste (tipo, potencia_watts, logradouro_id) VALUES
('Concreto', 250, 1),
('Concreto', 250, 1),
('Metálico', 150, 2),
('Metálico', 150, 2),
('Metálico', 150, 2),
('Concreto', 400, 3),
('Concreto', 250, 1);

INSERT INTO proprietario (nome, cpf) VALUES
('Ana Beatriz Souza',     '11122233344'),
('Carlos Eduardo Lima',   '22233344455'),
('Fernanda Costa Melo',   '33344455566'),
('João Pedro Nascimento', '44455566677');

-- lote 2 e lote 5 têm mais de um proprietário: exemplo prático de relacionamento N:N
INSERT INTO lote_proprietario (lote_id, proprietario_id, percentual_posse) VALUES
(1, 1, 100.00),
(2, 1,  50.00),
(2, 2,  50.00),
(3, 2, 100.00),
(4, 3, 100.00),
(5, 3,  60.00),
(5, 4,  40.00),
(6, 4, 100.00),
(7, 1, 100.00),
(8, 2, 100.00);
