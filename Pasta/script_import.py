import mysql.connector
from datetime import datetime

# Conectar ao banco de dados MySQL
db_connection = mysql.connector.connect(
    host="localhost",
    user="root",
    password="11534728",
    database="comercioDB2"
)

cursor = db_connection.cursor()

# Ler os dados do arquivo CSV
with open('MOCK_DATA_CLIENTE.CSV', 'r') as csv_file:
    next(csv_file)  # Pule o cabeçalho
    for line in csv_file:
        data = line.strip().split(',')
        # Converter a data para o formato esperado pelo MySQL (YYYY-MM-DD), pois gerei no formato (dd.mm.yyyy)
        data[5] = datetime.strptime(data[5], '%d.%m.%Y').strftime('%Y-%m-%d')
        cursor.execute("INSERT INTO Cliente (cliente_id, nome, endereco, telefone, email, data_registro) VALUES (%s, %s, %s, %s, %s, %s)", data)

# Ler os dados do arquivo CSV
with open('MOCK_DATA_VENDEDOR.CSV', 'r') as csv_file:
    next(csv_file)  # Pule o cabeçalho
    for line in csv_file:
        data = line.strip().split(',')
        # Converter a data para o formato esperado pelo MySQL (YYYY-MM-DD), pois gerei no formato (dd.mm.yyyy)
        data[4] = datetime.strptime(data[4], '%d.%m.%Y').strftime('%Y-%m-%d')
        cursor.execute("INSERT INTO Vendedor (vendedor_id, nome, telefone, email, data_contratacao) VALUES (%s, %s, %s, %s, %s)", data)

# Ler os dados do arquivo CSV
with open('MOCK_DATA_PRODUTO.CSV', 'r') as csv_file:
    next(csv_file)  # Pule o cabeçalho
    for line in csv_file:
        data = line.strip().split(';')
        cursor.execute("INSERT INTO Produto (produto_id, nome, preco_compra, preco_venda, estoque) VALUES (%s, %s, %s, %s, %s)", data)


# Confirmar as transações
db_connection.commit()

# Fechar a conexão
cursor.close()
db_connection.close()


# DIOGO FRANCIS BELSHOFF
# GUSTAVO SUTER GONÇALVES
# LUCAS DAMASCENO BERNARDES