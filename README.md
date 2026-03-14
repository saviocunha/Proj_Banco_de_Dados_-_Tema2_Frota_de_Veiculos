# Sistema de Gerenciamento de Frota de Veículos

Este projeto implementa um **sistema de gerenciamento de frota de veículos** utilizando **Python, SQLAlchemy ORM e PostgreSQL**.
O sistema permite gerenciar veículos, motoristas, abastecimentos, manutenções e viagens, além de demonstrar operações **CRUD (Create, Read, Update, Delete)** e **consultas com relacionamentos**.

---

# Tecnologias Utilizadas

* Python 3.10+
* PostgreSQL
* SQLAlchemy
* Psycopg2 (driver PostgreSQL para Python)

---

# Estrutura do Projeto

```
frota-veiculos/
│
├── Frota.py
├── README.md
├── Frota_Veiculos.sql
└── Proj_Banco_de_Dados_Etapa_7_—_ORM.ipynb # notebook do google colab
```

---

# Como Executar o Projeto (Passo a Passo)

## 1 — Instalar o Python

Verifique se o Python está instalado:

```bash
python --version
```

ou

```bash
python3 --version
```

---

## 2 — Criar um ambiente virtual (recomendado)

Linux / Mac:

```bash
python3 -m venv venv
source venv/bin/activate
```

Windows:

```bash
python -m venv venv
venv\Scripts\activate
```

---

## 3 — Instalar as dependências

```bash
pip install sqlalchemy psycopg2-binary
```

---

# Configuração do Banco de Dados

O projeto utiliza **PostgreSQL**.

## 1 — Criar o banco de dados

Acesse o PostgreSQL:

```bash
psql -U postgres
```

Crie o banco utilizando o script Frota_Veiculos.sql:

```sql
CREATE DATABASE frota_veiculos;
```

---

## 2 — Configurar conexão no código

No arquivo Python, localize a variável:

```python
DATABASE_URL = "postgresql+psycopg2://postgres:admin@localhost:5432/frota_veiculos"
```

Formato:

```
postgresql+psycopg2://USUARIO:SENHA@HOST:PORTA/BANCO
```

Exemplo:

```
postgresql+psycopg2://postgres:1234@localhost:5432/frota_veiculos
```

---

## 3 — Usando arquivo `.env` (opcional)

Você pode usar variáveis de ambiente para maior segurança.

Instale:

```bash
pip install python-dotenv
```

Crie um arquivo `.env`

```
DB_USER=postgres
DB_PASSWORD=admin
DB_HOST=localhost
DB_PORT=5432
DB_NAME=frota_veiculos
```

E altere a conexão no código:

```python
from dotenv import load_dotenv
import os

load_dotenv()

DATABASE_URL = f"postgresql+psycopg2://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
```

---

# Comandos de Execução

Execute o script principal:

```bash
python Frota.py
```

ou

```bash
python3 frota.py
```

Durante a execução o sistema irá:

1. Conectar ao PostgreSQL
2. Criar as tabelas automaticamente
3. Inserir dados de exemplo
4. Executar operações CRUD
5. Executar consultas com relacionamentos

---

# Exemplo de Saída no Terminal

Exemplo de execução do sistema:

```
Conectado!
 PostgreSQL 17.8 on x86_64-windows, compiled by msvc-19.44.35222, 64-bit
Tabelas criadas!
Session aberta e pronta.
Dados inseridos com sucesso!
--- Criando Tipos de Veículo ---
Tipos de Veículo criados: TipoVeiculo(id_tipo_veiculo=4, descricao=<TipoVeiculoEnum.CARRO: 'Carro'>) TipoVeiculo(id_tipo_veiculo=5, descricao=<TipoVeiculoEnum.CAMINHAO: 'Caminhão'>) TipoVeiculo(id_tipo_veiculo=6, descricao=<TipoVeiculoEnum.MOTO: 'Moto'>)

--- Criando Status de Veículo ---
Status de Veículo criados: StatusVeiculo(id_status_veiculo=4, descricao=<StatusVeiculoEnum.ATIVO: 'Ativo'>) StatusVeiculo(id_status_veiculo=5, descricao=<StatusVeiculoEnum.INATIVO: 'Inativo'>) StatusVeiculo(id_status_veiculo=6, descricao=<StatusVeiculoEnum.MANUTENCAO: 'Em Manutenção'>)

--- Criando Veículos (3 registros) ---
Veículos criados: Veiculo(id_veiculo = 5, placa = 'NEW1111', modelo = 'Corolla') Veiculo(id_veiculo = 6, placa = 'NEW2222', modelo = 'R450') Veiculo(id_veiculo = 7, placa = 'NEW3333', modelo = 'Factor')

--- Listando Veículos (Ordenados por placa, 2 por página) ---
Página 1: [Veiculo(id_veiculo = 1, placa = 'ABC1234', modelo = 'Toro'), Veiculo(id_veiculo = 4, placa = 'CAR7777', modelo = 'Onix')]
Página 2: [Veiculo(id_veiculo = 3, placa = 'MOT5555', modelo = 'BROS'), Veiculo(id_veiculo = 5, placa = 'NEW1111', modelo = 'Corolla')]

--- Atualizando Veículo (Quilometragem) ---
Veículo NEW1111 quilometragem atualizada para 20000 km

--- Removendo Veículo (Soft Delete) ---
Veículo NEW3333 desativado. Novo status: StatusVeiculoEnum.INATIVO

--- Listando Veículos Novamente ---
Placa: ABC1234, Modelo: Toro, KM: 45000, Status: StatusVeiculoEnum.ATIVO
Placa: CAR7777, Modelo: Onix, KM: 5000, Status: StatusVeiculoEnum.INATIVO
Placa: MOT5555, Modelo: BROS, KM: 12000, Status: StatusVeiculoEnum.ATIVO
Placa: NEW1111, Modelo: Corolla, KM: 20000, Status: StatusVeiculoEnum.ATIVO
Placa: NEW2222, Modelo: R450, KM: 200000, Status: StatusVeiculoEnum.ATIVO
Placa: NEW3333, Modelo: Factor, KM: 5000, Status: StatusVeiculoEnum.INATIVO
Placa: XYZ9876, Modelo: FH, KM: 150000, Status: StatusVeiculoEnum.MANUTENCAO

--- Criando Motorista e Abastecimento ---
Motorista criado: Motorista(id_motorista = 5, cpf = '11122233344', nome = 'Novo Motorista')
Abastecimento criado: Abastecimento(id_abastecimento = 4, placa = 'NEW1111', litros = Decimal('40.00'))

--- Removendo Veículo (Hard Delete - exemplo) ---
Abastecimento do veículo NEW1111 removido antes do hard delete.
Veículo com placa NEW1111 removido fisicamente.

--- Verificando se o Veículo foi removido ---
Veículo NEW1111 não encontrado no banco de dados após a remoção física.

--- Consultas ORM com Relacionamentos e Filtros ---

1. Veículos com Tipo e Status:

Placa: ABC1234, Marca: Fiat, Modelo: Toro, Tipo: Carro, Status: Ativo
Placa: XYZ9876, Marca: Volvo, Modelo: FH, Tipo: Caminhão, Status: Em Manutenção
Placa: MOT5555, Marca: Honda, Modelo: BROS, Tipo: Moto, Status: Ativo
Placa: CAR7777, Marca: Chevrolet, Modelo: Onix, Tipo: Carro, Status: Inativo
Placa: NEW2222, Marca: Scania, Modelo: R450, Tipo: Caminhão, Status: Ativo
Placa: NEW3333, Marca: Yamaha, Modelo: Factor, Tipo: Moto, Status: Inativo

2. Motoristas e suas Viagens Alocadas:

Motorista: Antonio Pedro Cunha (CPF: 12345678901)
  - Viagem: Sobral -> Fortaleza (Veículo: ABC1234)
Motorista: Francisco Jose Sousa (CPF: 45678912300)
  - Viagem: Itapipoca -> Umirim (Veículo: MOT5555)
Motorista: Pedro Ferreira Inacio (CPF: 32165498700)
  - Viagem: Fortaleza -> Itapipoca (Veículo: CAR7777)

3. Top 3 Veículos Ativos por Quilometragem:

Placa: ABC1234, Modelo: Toro, Quilometragem: 45000 km
Placa: MOT5555, Modelo: BROS, Quilometragem: 12000 km

--- Consultas Concluídas ---
```

OBS.: Também é possivel a execução direta no Gooogle Colab. Para isso acesse o Colab e abra o arquivo Proj_Banco_de_Dados_Etapa_7_—_ORM.ipynb

---

# Funcionalidades Demonstradas

O projeto demonstra:

* Criação automática de tabelas via ORM
* Inserção de dados
* Atualização de registros
* Exclusão lógica e física
* Paginação de resultados
* Relacionamentos entre tabelas
* Consultas com JOIN

---

# Modelo de Dados

Principais entidades do sistema:

* **Veículo**
* **Motorista**
* **Abastecimento**
* **Manutenção**
* **Alocação de Viagem**
* **Tipo de Veículo**
* **Status do Veículo**

Relacionamentos principais:

* Veículo → TipoVeiculo
* Veículo → StatusVeiculo
* Veículo → Abastecimentos
* Veículo → Manutenções
* Veículo → Viagens
* Motorista → Viagens

---

# Possíveis Melhorias Futuras

* API REST com Flask ou FastAPI
* Interface Web
* Autenticação de usuários
* Dashboard de relatórios
* Integração com GPS ou telemetria

---

# Autor

Francisco Sávio Sousa da Cunha

