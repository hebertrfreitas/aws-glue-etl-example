### Glue Job Example

ATTENTION: this is a work in progress project !

O objetivo deste projeto é fornecer um exemplo de job etl do AWS Glue.

Neste exemplo, nossa fonte de dados será um bucket S3 com um arquivo no formato [parquet](https://parquet.apache.org/).

Nosso destino será uma tabela do DynamoDB. 

### Organização das pastas

 - parquet/ = script para converter um csv para parquet
 - terraform/ = arquivos para provisionar a infraestrutura automaticamente via terraform


### Requisitos
- python
- terraform
- uma conta com acesso a aws
- aws cli configurado (opcional mas altamente recomendável)


### Digrama arquitetural

![Diagrama](/docs/images/Glue_example.drawio.png)


### Getting started


#### Gerando arquivo parquet de exemplo 

Para gerar um arquivo parquet de exemplo foi disponibilizado um script em python que converte um csv para parquet em `/parquet/csv_to_parquet.py`.

Também foi disponibilizado um arquivo de teste em csv(`/parquet/input.csv`).

Para executar um script em python recomendamos que seja usado um virtual environment, para tal, execute os comandos à seguir:


```shell
cd parquet
pip install virtualenv #caso não tenha o virtual environment instalado
python virtualenv venv
source venv
```

Em seguida podemos executar o script

```python
pip install -r requirements.txt
python csv_to_parquet.py
```

O esperado é que seja gerado o arquivo output.parquet na raiz do projeto.

#### Provisionando a infraestrutura com terraform

O projeto contem arquivos terraform para gerar a infraestrurura necessária.

Serão provisionados os seguintes recursos:

1. S3 bucket com o arquivo `output.parquet`
2. Tabela do DynamoDB chamado `TargetTable` 

É necessário ter as credenciais da aws criadas no seu profile em `~/.aws/credentials`. Recomendamos que você configure o aws cli na sua máquina seguindo o [passo a passo da aws](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html).

Para provisionar a infraestrutura execute os seguintes comandos

```shell
terraform init
terraform apply
```

Caso queira destruir toda a infraestrutura basta executar

```shell
terraform destroy
```