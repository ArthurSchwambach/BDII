import mysql.connector

# Conectar ao banco de dados
db_connection = mysql.connector.connect(
    host="localhost",
    user="root",
    password="123456",
    database="Restaurante"
)

cursor = db_connection.cursor()

# Importando a tabela Clientes
with open('clientes100.csv', 'r') as file:
    next(file)  # Pula o cabeçalho
    for line in file:
        data = line.strip().split(',')
        cursor.execute("INSERT INTO Cliente (nome, telefone, email, gasto) VALUES (%s, %s, %s, %s)", data)

# Importando a tabela Clientes
with open('mesa.csv', 'r') as file:
    next(file)  # Pula o cabeçalho
    for line in file:
        data = line.strip().split(',')
        cursor.execute("INSERT INTO Mesa (numero, capacidade) VALUES (%s, %s)", data)

# Importando a tabela Menu
with open('menu.csv', 'r') as file:
    next(file)  # Pula o cabeçalho
    for line in file:
        data = line.strip().split(',')
        cursor.execute("INSERT INTO Menu (nome, descricao, preco) VALUES (%s, %s, %s)", data)

# Importando a tabela Funcionarios
with open('atendente.csv', 'r') as file:
    next(file)  # Pula o cabeçalho
    for line in file:
        data = line.strip().split(',')
        cursor.execute("INSERT INTO Atendente (nome, telefone, email, salario) VALUES (%s, %s, %s, %s)", data)

# Commit para salvar as mudanças
db_connection.commit()

# Fechando o cursor e a conexão
cursor.close()
db_connection.close()
