# NYC Taxi Pipeline

Pipeline em Python + PySpark para ingestão e transformação de dados de corridas de táxi de NYC em arquitetura medallion.

## Estrutura do projeto

```text
src/
  main.py
  requirements.txt
  setup.py
  bronze/
    ingestor.py
  silver/
    processor.py
  gold/
    analytics.py
  config/
    settings.py
  utils/
    logger.py
    schema.py
    spark.py
```

## O que o projeto faz hoje

### Bronze
O módulo `bronze/ingestor.py`:
- lê arquivos parquet do path configurado em `PATHS["landing"]`
- usa Auto Loader (`cloudFiles`)
- adiciona metadados de ingestão
- grava em Delta no path `PATHS["bronze"]`
- usa checkpoint em `PATHS["checkpoints"]`
- particiona por:
  - `taxi_type`
  - `ingestion_year`
  - `ingestion_month`

### Silver
O módulo `silver/processor.py`:
- lê a camada bronze em Delta
- renomeia colunas inconsistentes com base em `RAW_COLUMN_MAPPING`
- alinha o DataFrame ao `SILVER_MASTER_SCHEMA`
- cria colunas de partição:
  - `ano`
  - `mes`
  - `dia`
- grava a camada silver em Delta particionada por:
  - `taxi_type`
  - `ano`
  - `mes`
  - `dia`

### Gold
Existe o arquivo `gold/analytics.py`, mas ele ainda não implementa processamento.

---

## Pré-requisitos

### Ambiente
Você precisa de:
- Python 3.10+
- acesso a um ambiente Databricks para execução distribuída
- acesso aos paths de dados configurados em `src/config/settings.py`

### Dependências Python
As dependências declaradas hoje são:

Arquivo `src/requirements.txt`:
```txt
watchtower==3.3.1
pyspark
boto3
botocore
```

Arquivo `src/setup.py`:
- `watchtower`
- `opentelemetry-api`
- `opentelemetry-sdk`
- `opentelemetry-exporter-otlp`

---

## Instalação

### Opção 1: ambiente virtual local

Na raiz do projeto:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r src/requirements.txt
pip install -e src
```

### Opção 2: Databricks
Suba a pasta `src/` para o workspace ou empacote conforme seu processo de deploy e configure um job para executar `main.py`.

---

## Configuração

O arquivo principal de configuração é:

```text
src/config/settings.py
```

Atualmente ele define:

- bucket: `55-taxi-data`
- base path: `s3://55-taxi-data`

### Paths atuais
```python
PATHS = {
    "landing": "s3://55-taxi-data/landing/",
    "bronze": "s3://55-taxi-data/bronze/bronze_nyc_taxi_trips/",
    "silver": "s3://55-taxi-data/silver/silver_nyc_taxi_trips/",
    "gold": "s3://55-taxi-data/gold/gold_nyc_taxi_monthly_summary/",
    "checkpoints": "s3://55-taxi-data/_metadata/checkpoints/"
}
```

### Tabelas lógicas atuais
```python
TABLE_NAMES = {
    "bronze": "bronze_nyc_taxi_trips",
    "silver": "silver_nyc_taxi_trips",
    "gold": "gold_nyc_taxi_monthly_summary"
}
```

### Schema mestre da silver
O `SILVER_MASTER_SCHEMA` já está definido no `settings.py` e é usado pelo `utils/schema.py` para alinhar os dados transformados.

---

## Como executar

### Execução direta
```bash
python src/main.py
```

### Execução com `--zip_path`
O `main.py` suporta receber um zip de código no argumento `--zip_path`:

```bash
python src/main.py --zip_path /caminho/do/codigo.zip
```

O script adiciona esse zip ao `sys.path` antes de importar os módulos.

---

## Fluxo de execução

A função principal é:

```python
run_production_pipeline()
```

Ela executa nesta ordem:

1. cria o logger
2. inicializa a SparkSession
3. executa a ingestão bronze
4. executa o processamento silver
5. encerra a execução

O período atualmente usado na silver é:

- início: `2023-01-01`
- fim: `2023-05-31`

---

## Detalhamento dos arquivos

### `src/main.py`
Arquivo orquestrador do pipeline Bronze -> Silver.

### `src/config/settings.py`
Centraliza:
- paths de entrada e saída
- nomes lógicos de tabelas
- schema mestre da silver
- mapeamento de colunas inconsistentes

### `src/bronze/ingestor.py`
Responsável por:
- leitura incremental com Auto Loader
- schemaLocation do Auto Loader
- checkpoint da stream
- escrita Delta particionada na bronze

### `src/silver/processor.py`
Responsável por:
- leitura da bronze
- renomeação de colunas
- alinhamento ao schema mestre
- criação de colunas de partição
- gravação particionada da silver

### `src/utils/schema.py`
Responsável por:
- renomear colunas inconsistentes
- alinhar o DataFrame ao schema mestre
- criar colunas de partição temporais

### `src/utils/spark.py`
Centraliza a criação da SparkSession com:
- `spark.databricks.delta.optimizeWrite.enabled = true`
- `spark.databricks.delta.autoCompact.enabled = true`
- `spark.sql.sources.partitionOverwriteMode = dynamic`

Também possui a função `run_delta_maintenance()` para:
- `OPTIMIZE`
- `VACUUM`

### `src/utils/logger.py`
Configura logging com:
- saída em stdout
- integração com CloudWatch via `watchtower`

### `src/gold/analytics.py`
Arquivo presente no projeto para a camada gold.

---

## Como usar

### 1. Disponibilize os arquivos de entrada
Coloque os arquivos parquet no path configurado em:

```python
PATHS["landing"]
```

### 2. Garanta acesso aos dados
A identidade de execução precisa ter acesso a:
- leitura em `landing`
- escrita em `bronze`
- leitura de `bronze`
- escrita em `silver`
- leitura/escrita em `checkpoints`

### 3. Execute o pipeline
```bash
python src/main.py
```

### 4. Valide as saídas
Bronze:
```python
spark.read.format("delta").load(PATHS["bronze"]).count()
```

Silver:
```python
spark.read.format("delta").load(PATHS["silver"]).count()
```

---

## Comandos úteis de desenvolvimento

Criar ambiente e instalar:
```bash
python -m venv .venv
source .venv/bin/activate
pip install -r src/requirements.txt
pip install -e src
```

Executar:
```bash
python src/main.py
```

---

## Observações de uso

- o projeto já possui estrutura modular para bronze e silver
- o schema da silver já está centralizado
- o mapeamento de colunas inconsistentes já está centralizado
- o logger já possui stdout e tentativa de integração com CloudWatch
- a função de manutenção Delta já existe em `utils/spark.py`

---

## Próximo passo natural de evolução

Para ampliar o pipeline, os pontos mais naturais são:
- implementar a camada gold em `gold/analytics.py`
- parametrizar período de processamento
- externalizar configurações de ambiente
- adicionar testes para transformação e schema alignment
