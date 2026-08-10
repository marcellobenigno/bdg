## 3. Manipulação de Dados (INSERT, UPDATE, DELETE)

Com as tabelas já criadas, vamos agora popular o modelo com dados e aprender a atualizá-los e removê-los.

### Inserção de Dados (INSERT)

```sql
INSERT INTO nome_da_tabela (coluna_1, coluna_2, ..., coluna_n)
VALUES (valor_coluna_1, valor_coluna_2, ..., valor_coluna_n);
```

É possível inserir vários registros em um único comando, separando as tuplas de valores por vírgula. A ordem de inserção **importa**: como as tabelas têm chaves estrangeiras, é preciso popular primeiro o lado "1" do relacionamento.

```sql
-- 1) bacias hidrográficas
INSERT INTO bacia_hidrografica (nome, area_km2) VALUES
('Rio Paraíba',      20071.83),
('Rio Piranhas-Açu', 43681.50),
('Rio Mamanguape',    3958.31);

-- 2) rios (dependem de bacia_hidrografica.id)
INSERT INTO rio (nome, extensao_km, bacia_id) VALUES
('Rio Paraíba',    380.00, 1),
('Rio Taperoá',    128.50, 1),
('Rio Piranhas',   233.33, 2),
('Rio do Peixe',   145.20, 2),
('Rio Mamanguape',  175.00, 3);

-- 3) quadras
INSERT INTO quadra (codigo, zoneamento) VALUES
('Q-101', 'Residencial'),
('Q-102', 'Residencial'),
('Q-103', 'Comercial'),
('Q-201', 'Industrial');

-- 4) lotes (dependem de quadra.id)
INSERT INTO lote (numero, area_m2, uso_solo, quadra_id) VALUES
('01',  360.00, 'Residencial', 1),
('02',  450.50, 'Residencial', 1),
('03',  300.00, 'Residencial', 1),
('01',  500.00, 'Residencial', 2),
('02',  480.00, 'Residencial', 2),
('01',  800.00, 'Comercial',   3),
('02',  650.00, 'Comercial',   3),
('01', 1200.00, 'Industrial',  4);

-- 5) logradouros
INSERT INTO logradouro (nome, hierarquia) VALUES
('Av. Getúlio Vargas', 'Arterial'),
('Rua das Acácias',    'Local'),
('Rua do Comércio',    'Coletora'),
('Travessa Nova',      'Local');

-- 6) postes (dependem de logradouro.id)
INSERT INTO poste (tipo, potencia_watts, logradouro_id) VALUES
('Concreto', 250, 1),
('Concreto', 250, 1),
('Metálico', 150, 2),
('Metálico', 150, 2),
('Metálico', 150, 2),
('Concreto', 400, 3),
('Concreto', 250, 1);

-- 7) proprietarios
INSERT INTO proprietario (nome, cpf) VALUES
('Ana Beatriz Souza',     '11122233344'),
('Carlos Eduardo Lima',   '22233344455'),
('Fernanda Costa Melo',   '33344455566'),
('João Pedro Nascimento', '44455566677');

-- 8) lote_proprietario (dependem de lote.id e proprietario.id)
-- repare que os lotes 2 e 5 têm mais de um proprietário (relacionamento N:N)
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
```

> 💡 Todos esses comandos, junto com o `CREATE TABLE` do módulo anterior, estão reunidos em [`sql/script_criacao_dados.sql`](script_criacao_dados.sql).

### Atualização de Dados (UPDATE)

```sql
UPDATE nome_da_tabela
SET coluna1 = novo_valor
WHERE condicao;
```

**Sem a cláusula `WHERE`, o `UPDATE` altera TODAS as linhas da tabela** — sempre confira a condição antes de executar.

Exemplo: corrigir a área do lote 3, que foi cadastrada incorretamente:

```sql
UPDATE lote
SET area_m2 = 320.00
WHERE id = 3;
```

É possível atualizar mais de uma coluna no mesmo comando:

```sql
UPDATE poste
SET tipo = 'Concreto', potencia_watts = 250
WHERE id = 6;
```

### Exclusão de Dados (DELETE)

```sql
DELETE FROM nome_da_tabela
WHERE condicao;
```

Assim como no `UPDATE`, **sem `WHERE` o `DELETE` apaga todas as linhas da tabela**.

```sql
-- exemplo:
DELETE FROM poste
WHERE id = 6;
```

Se tentarmos apagar um registro que é referenciado por uma chave estrangeira em outra tabela — por exemplo, `DELETE FROM proprietario WHERE id = 1;`, sendo que o proprietário 1 possui registros em `lote_proprietario` — o PostgreSQL **recusa o comando por padrão**, para não deixar uma FK "órfã" apontando para um registro inexistente. Antes de apagar o proprietário, seria preciso apagar (ou reatribuir) suas linhas em `lote_proprietario`.

### Exercícios:

1. Insira uma nova bacia hidrográfica chamada `'Rio Camaratuba'`, com `area_km2 = 875.40`, e um rio associado a ela chamado `'Rio Camaratuba'`, com `extensao_km = 78.00`.
2. Insira um novo proprietário, `'Marcos Vinícius Alves'`, com CPF `'55566677788'`, e associe-o ao lote de `id = 4` com `percentual_posse = 100.00` na tabela `lote_proprietario`. O que acontece com o registro que já existia para o lote 4?
3. Atualize a área do lote de `id = 3` para `320.00`.
4. Escreva o `DELETE` que remove o proprietário `'Ana Beatriz Souza'` (id 1). Explique por que o PostgreSQL recusa esse comando enquanto existirem linhas em `lote_proprietario` referenciando esse proprietário, e o que seria necessário fazer antes.
5. O poste de `id = 6` foi cadastrado com `potencia_watts = 400`, mas o correto é `250`. Escreva o `UPDATE` que corrige esse valor.

---

**Navegação:** [⬅ Anterior: 2. Criação e Alteração de Tabelas](2-criacao_alteracao_tabelas.md) | [🏠 Índice](../README.md) | [Próximo: 4. Consultas Básicas ➡](4-consultas_basicas.md)
