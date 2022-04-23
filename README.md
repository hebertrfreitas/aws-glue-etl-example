### Glue Job Example

ATTENTION: this is a work in progress project !

O objetivo deste projeto é fornecer um exemplo de job etl do AWS Glue.

Neste exemplo, nossa fonte de dados será um bucket S3 com um arquivo no formato [parquet](https://parquet.apache.org/).

Nosso destino será uma tabela do DynamoDB. 

### Organização das pastas

 - parquet/ = script para converter um csv para parquet
 - iac/ = arquivos terraform para provisionar a infraestrutura automaticamente
 - glue_job = script executado pelo job do glue escrito em python


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
pip3 install virtualenv #caso não tenha o virtual environment instalado
python3 -m venv .venv
source .venv/bin/activate
```

Em seguida podemos executar o script

```python
pip3 install -r requirements.txt
python3 csv_to_parquet.py
```

O esperado é que seja gerado o arquivo output.parquet na raiz do projeto.

#### Provisionando a infraestrutura com terraform

O projeto contem arquivos terraform para gerar a infraestrurura necessária.

Serão provisionados os seguintes recursos:

1. S3 bucket com o arquivo `output.parquet`

2. Tabela do DynamoDB chamado `TargetTable` 

É necessário ter as credenciais da aws criadas no seu profile em `~/.aws/credentials`. Recomendamos que você configure o aws cli na sua máquina seguindo o [passo a passo da aws](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html).

Para provisionar a infraestrutura execute os seguintes comandos dentro da pasta `/iac`

```shell
terraform init
terraform apply
```

Caso queira destruir toda a infraestrutura basta executar

```shell
terraform destroy
```

### Script do job

O script do job etl foi feito em python e está na pasta `glue_job`.

#### Como testar o script localmente

A aws fornece algumas possibilidades para desenvolver e testar o script na sua [documentação](https://docs.aws.amazon.com/glue/latest/dg/aws-glue-programming-etl-libraries.html), para este exemplo optei por utilizar a [imagem docker](https://docs.aws.amazon.com/glue/latest/dg/aws-glue-programming-etl-libraries.html#develop-local-docker-image) disponibilizada pela aws para subir um ambiente pyspark com suporte ao glue localmente.

Para executar localmente primeiro entre na pasta `glue_job` e em seguida execute o seguinte comando:

```sh
docker run -it \
-v ~/.aws:/home/glue_user/.aws \
-v ${PWD}:/home/glue_user/workspace/ \
-e DISABLE_SSL=true --rm -p 4040:4040 -p 18080:18080 \
--name glue_spark_submit amazon/aws-glue-libs:glue_libs_3.0.0_image_01 \
spark-submit /home/glue_user/workspace/glue_job_script.py \
--JOB_NAME "test_job"

```

Alguns detalhes sobre o comando:

 01. `-v ~/.aws:/home/glue_user/.aws` aqui estamos mapeando a pasta com as credenciais e configurações da aws para dentro do container. É importante que você tenha as credenciais configuradas, se você tem o aws cli configurado provavelmente este passo já está realizado.

 00. `-v ${PWD}:/home/glue_user/workspace/`, neste ponto estamos mapeando um segundo volume que disponibiliza dentro do container os scripts da nossa pasta `glue_job`, `${PWD}` é um comando que resolve o caminho absoluto da pasta onde você está no momento.

 00. `--name glue_spark_submit` estamos informando ao docker qual nome do container, neste caso queremos que se chame glue_spark_submit

 00. `amazon/aws-glue-libs:glue_libs_3.0.0_image_01` imagem docker disponibilizada pela aws contendo tudo necessário para executar um script do glue localmente.

 00. `spark-submit /home/glue_user/workspace/glue_job_script.py --JOB_NAME "test_job"` comando que será executado dentro do container, `spark-submit` é um executável que aceita um script como parâmetro, este executável dispara uma aplicação spark dentro do container. o parâmetro `--JOB_NAME` é um dos parâmetros esperados dentro do script.

<br/>
Importante entender que mesmo rodando o job localmente, os recursos da aws consumidos como fonte e destino(no nosso caso do S3 como fonte e o dynamo como destino) serão provinentes da aws.

TODO: configurar um exemplo usando a localstack


### Informações sobre o aws glue


#### Introdução

Entre as varias funcionalidades fornecidas pelo AWS GLUE, os jobs se destinam a fazer o papel de ETL(Extract, Transform and Load).

Jobs do glue são executados em cima do [Spark](https://spark.apache.org/) e estão disponíveis para uso serverless, ou seja, você não precisa se preocupar em provisionar a infraestrutura para rodar o job, a aws fará isso para você. 

Um job do glue pode ser escrito usando `python (usando pyspark)` , ou `scala`.

Antes de escrever um job é necessário ter em mente três princípios básicos:

__1 - de onde os dados serão extraídos__

Todo job do glue precisa de uma fonte de dados, no nosso caso esta fonte de dados é um arquivo em formato parquet armazenado em um bucket s3.

__2 - qual transformação será feita nos dados__

Uma vez extraídos os dados da fonte pode ser necessário fazer algum transformação no mesmo para que ele se adeque ao formato desejado no destino.

Os jobs do glue aceitam várias fontes de origem e destino como buckets do S3, bases de dados como Postgres e Mysql, tabelas do dynamo, tópicos do Kafka entre outros.

A etapa de de transformações é onde faremos este mapeamento das informações entre origem e destino. Transformações comuns são ações como filtros, renomear colunas, unir dados, ou qualquer outra operação que você possa descrever no seu código, lembre-se que aqui você estará escrevendo um script em python ou scala, logo praticamente qualquer coisa que possa ser codificada pode ser usada como transformação.

__3 - destino onde os dados serão inseridos__

A última etapa de um job é o destino onde os dados serão inseridos. 

Uma vez que o dado foi carregado e transformado resta fazer o carregamento dos mesmos em algum local, e aqui novamente temos uma gama grande de opções como bases de dados, streaming, etc.


#### Como construir um job

Atualmente a aws fornece uma interface visual chamada Glue Studio, onde é possível construir o job iteragindo com componentes visuais e ao final a aws gera um script do mesmo para você.

![Glue studio](/docs/images/glue_studio.png)

Não ficamos limitados ao script gerado pelo Glue Studio, sendo possível alterar o mesmo ou até mesmo construir um script from scratch e fazer o upload do mesmo.

O script precisa estar em um bucket do s3 para que o glue possa ler o mesmo e executar o seu job.

Para este exemplo o script construído está no arquivo `glue_job/glue_job_script.py`. 

Importante ter em mente que o job do glue precisará ter acesso a origem e destino dos dados, logo precisamos fornecer uma role iam que possua permissões na origem e destino.
Esta role será assumida pelo job do glue no momento da execução.



