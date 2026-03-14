-- ==================================================================================================
-- Projeto de Banco de Dados - TEMA 2 - Sistema de Gerenciamento de Frota de Veículos
-- FRANCISCO SÁVIO SOUSA DA CUNHA | MAT. Nº 2025013352
-- ==================================================================================================


-- Cria o banco de dados executar na primeira vez e depois é necessário comentar a linha abaixo para reexecutar
-- create database frota_veiculos;

-- Remove o schema criado a seguir permitindo que o script rode várias vezes
drop schema if exists frota cascade;

create schema if not exists frota;
set search_path to frota;

-- Remove as tabelas criadas permitindo que o script rode várias vezes
drop table if exists tipo_veiculo CASCADE;
drop table if exists status_veiculo CASCADE;
drop table if exists veiculo CASCADE;
drop table if exists manutencao CASCADE;
drop table if exists abastecimento CASCADE;
drop table if exists motorista CASCADE;
drop table if exists alocacao_viagem CASCADE;



-- Tabela: Tipo_Veiculo
-- Tabela de apoio para classificar o porte/tipo do veículo
create table tipo_veiculo(
	id_tipo_veiculo serial primary key,
	descricao varchar (20)
		-- Restringe a descrição a apenas 3 tipos de veiculos.
		check (descricao in ('Carro', 'Caminhão','Moto'))
);


-- Tabela: Status_Veiculo
-- Tabela de apoio para classificar o status do veículo
create table status_veiculo(
	id_status_veiculo serial primary key,
	descricao varchar (20)
		-- Restringe a descrição a apenas 3 status possiveis.
		check (descricao in  ('Ativo', 'Manutenção', 'Inativo'))
);


-- Tabela: Veiculo
-- Cadastro principal de veículos com validação de placa (Mercosul/Antiga)
create table veiculo(
	id_veiculo serial primary key,
	placa varchar(7) not null unique,
	marca varchar(20) not null,
	modelo varchar(20) not null,
	ano integer not null,
	consumo_medio_padrao decimal (5,2)
		-- Verifica se o valor do consumo médio padrão é maior que 0
		check (consumo_medio_padrao > 0),
	quilometragem decimal (10,2) not null
		-- Verifica se a quilometragem é maior ou igual a 0
		check (quilometragem >= 0),
	id_tipo_veiculo integer not null,
	id_status_veiculo integer not null,
    
	constraint fk_tipo_veiculo
		foreign key (id_tipo_veiculo)
		references tipo_veiculo(id_tipo_veiculo)
		on update cascade
		on delete restrict,
	    
	constraint fk_status_veiculo
		foreign key(id_status_veiculo)
		references status_veiculo(id_status_veiculo)
		on update cascade
		on delete restrict,

	-- Garante as placas informadas tenham o formado adequado:
	-- padrão antigo (AAA1234) ou o Mercosul (AAA1A23).
	constraint check_placa_formato 
		check (placa ~ '^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$') -- Expressão regular que verifica o formato da placa
         
);


-- Tabela: Abastecimento
-- Registro de despesas com combustível
create table abastecimento(
	id_abastecimento serial primary key,
	placa varchar(7) not null,
	data_abastecimento date not null default current_date, -- Define como padrão a data atual
	tipo_combustivel varchar(20)
		-- Restringe os tipos de combustiveis possiveis de abastecimento.
		check (tipo_combustivel in('Alcóol', 'Diesel', 'Gasolina')),
	litros decimal(5,2) not null 
		-- Verifica se o volume abastecido é maior que 0
		check (litros > 0),
	valor_pago decimal(10,2) not null
		-- Verifica se o valor gasto é maior ou igual a 0
		check (valor_pago >=0),
	quilometragem_no_abastecimento decimal(10,2) not null
		-- Verifica se a quilometragem no abastecimento é maior que 0.
		check (quilometragem_no_abastecimento > 0),
	
	constraint fk_abastecimento_veiculo
		foreign key(placa)
		references veiculo (placa)
		on update cascade
		on delete restrict

);

-- Tabela: Manutenção
-- Registro de serviços de manutenção/mecânicos
create table manutencao(
	id_manutencao serial primary key,
	placa varchar(7) not null,
	data_inicio_manutencao date not null,
	tipo_manutencao varchar(20)
		-- Restringe os tipos de manunteção a 2: Preventiva ou Corretiva.
		check(tipo_manutencao in('Preventiva', 'Corretiva')),
	data_fim_manutencao date not null
	-- Verifica se a data de fim da manutenção é posterior ou igual a data de inicio.
	check (data_fim_manutencao >= data_inicio_manutencao ),
	custo_manutencao decimal(10,2) not null
		-- Verifica se o custo da manutenção é maior ou igual a 0
		check (custo_manutencao >= 0),
	descricao text not null,
	
	constraint fk_manutencao_veiculo
		foreign key (placa)
		references veiculo(placa)
		on update cascade
		on delete restrict
);

-- Tabela: Motorista
-- Cadastro de condutores com validação de CPF
create table motorista(
	id_motorista serial primary key,
	cpf char(11) not null unique,
	nome varchar (200) not null,
	categoria_cnh char(1) not null
		-- Restringe a categoria da CNH aos 5 tipos possiveis.
		check(categoria_cnh in('A', 'B', 'C', 'D', 'E')),
	data_primeira_habilitacao date not null,
	data_expiracao_cnh date not null
		-- verifica se a data da expiração da CNH é posterior a data da primeira habilitação
		check (data_expiracao_cnh > data_primeira_habilitacao),
	disponibilidade boolean not null default true,

	-- Garante que o CPF tenha apenas 11 digitos numéricos
	constraint check_cpf_numerico 
		check (cpf ~ '^[0-9]{11}$')
);


-- Tabela: Alocação_Viagem
-- Controle de viagens e deslocamentos
create table alocacao_viagem(
	id_viagem serial primary key,
	placa varchar(7) not null,
	cpf_motorista char (11) not null,
	data_saida timestamp  not null,
	origem varchar(100) not null,
	destino varchar(100) not null,
	data_chegada timestamp
		-- Verifica se a data de chegada é posterior a data da saída
		check (data_chegada > data_saida),
	quilometragem_inicial decimal (10,2) not null
		-- Verifica se a quilimetragem inicial é maior que 0
		check (quilometragem_inicial >= 0),
	quilometragem_final decimal (10,2) not null
		-- Verica se a quilometragem final é maior que a inicial.
		check(quilometragem_final > quilometragem_inicial),
	
	constraint fk_viagem_veiculo
		foreign key (placa)
		references veiculo (placa)
		on update cascade 
		on delete restrict,
		
	constraint fk_viagem_motorista
		foreign key (cpf_motorista)
		references motorista(cpf)
		on update cascade
		on delete restrict	
	         
);


-- Tabela: Log_Manutencao
-- Tabela para auditoria automática de manutenções via Trigger
create table log_manutencao (
    id_log serial primary key,
    placa varchar(7),
    data_registro timestamp default current_timestamp,
    mensagem text
);


--===================================================================================================
-- Etapa 5: Views, Triggers e Procedure
-- ==================================================================================================

-- ===============================
-- VIEW
-- ===============================

-- View para consulta rápida de veículos com seus respectivos status e tipos
CREATE OR REPLACE VIEW vw_detalhamento_veiculos AS
	SELECT 
	    v.id_veiculo,
	    v.marca,
	    v.modelo,
	    v.placa,
	    v.ano,
	    tv.descricao AS "Tipo_Veiculo",
	    sv.descricao AS "Status_Veiculo"
	FROM veiculo AS v
	JOIN tipo_veiculo AS tv 
	    ON v.id_tipo_veiculo = tv.id_tipo_veiculo
	JOIN status_veiculo AS sv 
	    ON v.id_status_veiculo = sv.id_status_veiculo;


-- ===============================
-- VIEW MATERIALIZADA
-- ===============================

-- View Materializada para performance em relatórios financeiros de abastecimento
CREATE MATERIALIZED VIEW mv_relatorio_abastecimento AS
	SELECT 
	    v.placa,
	    v.modelo AS "Veículo",
	    COUNT(a.id_abastecimento) AS "Nº de Abastecimentos",
	    SUM(a.litros) AS "Total Abastecido",
	    SUM(a.valor_pago) AS "Valor Total Gasto",
	    ROUND(SUM(a.valor_pago) / NULLIF(SUM(a.litros), 0), 2) AS "Custo Médio / Litro"
	FROM veiculo v
	JOIN abastecimento a 
	    ON v.placa = a.placa
	GROUP BY v.placa, v.modelo;


-- ===============================
-- TRIGGERS
-- ===============================

-- 3.1 Trigger before

-- Trigger 1: Padroniza o nome do motorista para CAIXA ALTA antes de salvar

-- Cria a função que altera o nome para caixa alta
CREATE OR REPLACE FUNCTION fn_padroniza_nome()
RETURNS TRIGGER AS $$
BEGIN
    NEW.nome := UPPER(NEW.nome);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Remove a trigger se ela já existir, assim o script poderá rodar várias vezes
DROP TRIGGER IF EXISTS trg_padroniza_nome ON motorista;

-- Cria a trigger 
CREATE TRIGGER trg_padroniza_nome
BEFORE INSERT OR UPDATE ON motorista
FOR EACH ROW
EXECUTE FUNCTION fn_padroniza_nome();

--3.2 Trigger after

-- Trigger 2: Gera log automático após a inserção de uma manutenção

-- Cria a função
CREATE OR REPLACE FUNCTION 	fn_log_manutencao()
RETURNS TRIGGER AS $$
BEGIN
	INSERT INTO log_manutencao (placa, mensagem)
	VALUES(
		NEW.placa,
		NEW.descricao
	);
	RETURN NEW;
END
$$ LANGUAGE plpgsql;


-- Remove a trigger se ela já existir, assim o script poderá rodar várias vezes
DROP TRIGGER IF EXISTS trg_log_manucencao ON manutencao;

-- Cria a trigger 
CREATE TRIGGER trg_log_manutencaoALTER 
AFTER INSERT ON	manutencao 
FOR EACH ROW 
EXECUTE FUNCTION fn_log_manutencao();

-- ===============================
-- PROCEDURE
-- ===============================

-- Procedure: Facilita a alteração de status de disponibilidade do motorista
CREATE OR REPLACE PROCEDURE alterar_disponibilidade_motorista(
	p_cpf char (11),
	p_disponivel boolean
)
LANGUAGE plpgsql 
AS $$
BEGIN
	UPDATE motorista
	SET disponibilidade = p_disponivel
	WHERE cpf = p_cpf;
END;
$$;


-- OBS.: Os testes das funcionalidades estão no final do arquivo.

-- ==================================================================================================
-- Carga de dados (INSERTs)
-- ==================================================================================================

-- Populando a tabela: tipo_veiculo
INSERT INTO tipo_veiculo (descricao) VALUES
('Carro'),
('Caminhão'),
('Moto');


-- Populando a tabela: Status_Veiculo
INSERT INTO status_veiculo (descricao) VALUES
('Ativo'),
('Manutenção'),
('Inativo');


-- Populando a tabela: Veiculo
INSERT INTO veiculo (placa, marca, modelo, ano, consumo_medio_padrao, quilometragem, id_tipo_veiculo, id_status_veiculo) VALUES 
('ABC1234', 'Fiat', 'Toro', 2021, 10.50, 45000.00, 1, 1),   -- Carro Ativo
('XYZ9876', 'Volvo', 'FH', 2019, 5.00, 150000.00, 2, 2),    -- Caminhão em Manutenção
('MOT5555', 'Honda', 'BROS', 2022, 28.00, 12000.00, 3, 1),-- Moto Ativa
('CAR7777', 'Chevrolet', 'Onix', 2023, 12.00, 5000.00, 1, 3);-- Carro Inativo


-- Populando a tabela: Motorista
INSERT INTO motorista (cpf, nome, categoria_cnh, data_primeira_habilitacao, data_expiracao_cnh, disponibilidade) VALUES 
('12345678901', 'Antonio Pedro Cunha', 'B', '2018-05-10', '2028-05-10', true),
('98765432100', 'Maria Joana Silva', 'E', '2015-10-20', '2025-10-20', true),
('45678912300', 'Francisco Jose Sousa','A', '2021-01-15', '2031-01-15', false), -- Motorista indisponível
('32165498700', 'Pedro Ferreira Inacio','C', '2010-03-30', '2030-03-30', true);


-- Populando a tabela: Abastecimento
INSERT INTO abastecimento (placa, data_abastecimento, tipo_combustivel, litros, valor_pago, quilometragem_no_abastecimento) VALUES 
('ABC1234', '2026-01-05', 'Gasolina', 45.00, 270.00, 45100.00),
('XYZ9876', '2026-01-06', 'Diesel', 200.00, 1000.00, 150500.00),
('MOT5555', '2026-02-09', 'Gasolina', 10.00, 50.00, 12050.00);


-- Populando a tabela: Manutenção
INSERT INTO manutencao (placa, data_inicio_manutencao, tipo_manutencao, data_fim_manutencao, custo_manutencao, descricao) VALUES 
('XYZ9876', '2026-01-20', 'Corretiva', '2026-02-10', 2500.00, 'Troca de embreagem e revisão de freios'),
('MOT5555', '2026-02-08', 'Preventiva', '2026-02-08', 30.00, 'Troca de óleo e calibragem dos pneus'),
('CAR7777', '2026-02-09', 'Preventiva', '2026-02-09', 400.00, 'Troca de óleo');


-- Populando a tabela: Alocação_Viagem
INSERT INTO alocacao_viagem (placa, cpf_motorista, data_saida, origem, destino, data_chegada, quilometragem_inicial, quilometragem_final) VALUES 
('CAR7777','32165498700', '2025-12-10 07:30:00', 'Fortaleza', 'Itapipoca', '2025-12-10 10:30:00', 5000.00, 5150.00),
('ABC1234', '12345678901', '2025-12-12 08:00:00', 'Sobral', 'Fortaleza', '2025-12-12 11:30:00', 45000.00, 45250.00),
('MOT5555', '45678912300', '2026-02-05 14:00:00', 'Itapipoca', 'Umirim', '2026-02-05 14:45:00', 12050.00, 12190.00);

-- ==================================================================================================
-- 5. Desmostração das funcionalidades (Testes) - Retirar os comentários para executar
-- ==================================================================================================

-- -- I) Testando View e View Materializada 
-- SELECT * FROM vw_detalhamento_veiculos;
-- REFRESH MATERIALIZED VIEW mv_relatorio_abastecimento;
-- SELECT * FROM mv_relatorio_abastecimento;

-- -- II) Testando Trigger de Padronização (Inserindo em minúsculo)
-- INSERT INTO motorista (cpf, nome, categoria_cnh, data_primeira_habilitacao, data_expiracao_cnh) 
-- VALUES ('11122233344', 'Danilo dos santos gois', 'B', '2020-01-01', '2030-01-01');
-- SELECT * FROM motorista WHERE cpf = '11122233344'; -- O nome aparecerá em MAIÚSCULO

-- -- III) Testando Trigger de Log de Manutenção
-- INSERT INTO manutencao (placa, data_inicio_manutencao, tipo_manutencao, data_fim_manutencao, custo_manutencao, descricao)
-- VALUES ('ABC1234', '2026-02-27', 'Preventiva', '2026-02-27', 150.00, 'Troca de Óleo');
-- SELECT * FROM log_manutencao; -- Verifique o log gerado automaticamente

-- -- -- IV) Testando Procedure de Disponibilidade
-- -- CALL alterar_disponibilidade_motorista('98765432100', false);
-- SELECT nome, disponibilidade FROM motorista WHERE cpf = '98765432100';


