import mysql.connector
from datetime import datetime

# Conectar ao banco de dados MySQL
db_connection = mysql.connector.connect(
    host="localhost",
    user="root",
    password="11534728",
    database="teste"
)

cursor = db_connection.cursor()

# Ler os dados do arquivo CSV
with open('MOCK_DATA_VENDEDOR.CSV', 'r') as csv_file:
    next(csv_file)  # Pule o cabeçalho, se houver
    for line in csv_file:
        data = line.strip().split(',')
        # Converter a data para o formato esperado pelo MySQL (YYYY-MM-DD)
        data[4] = datetime.strptime(data[4], '%d.%m.%Y').strftime('%Y-%m-%d')
        cursor.execute("INSERT INTO Vendedor (vendedor_id, nome, telefone, email, data_contratacao) VALUES (%s, %s, %s, %s, %s)", data)

# Confirmar as transações
db_connection.commit()

# Fechar a conexão
cursor.close()
db_connection.close()
