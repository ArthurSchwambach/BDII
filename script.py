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
with open('clientes.csv', 'r') as file:
    next(file)  # Pula o cabeçalho
    for line in file:
        data = line.strip().split(',')
        cursor.execute("INSERT INTO Clientes (id_cliente, nome, telefone, email) VALUES (%s, %s, %s, %s)", data)

# Importando a tabela Mesas
with open('mesas.csv', 'r') as file:
    next(file)  # Pula o cabeçalho
    for line in file:
        data = line.strip().split(',')
        cursor.execute("INSERT INTO Mesas (id_mesa,numero, capacidade, disponibilidade_mesa) VALUES (%s, %s, %s, %s)", data)

# Importando a tabela Menu
with open('menu.csv', 'r') as file:
    next(file)  # Pula o cabeçalho
    for line in file:
        data = line.strip().split(',')
        cursor.execute("INSERT INTO Menu (id_menu, nome, descricao, preco, disponibilidade) VALUES (%s, %s, %s, %s, %s)", data)

# Importando a tabela Funcionarios
with open('funcionarios.csv', 'r') as file:
    next(file)  # Pula o cabeçalho
    for line in file:
        data = line.strip().split(',')
        cursor.execute("INSERT INTO Funcionarios (id_funcionario, nome, cargo, salario) VALUES (%s, %s, %s, %s)", data)

# Importando a tabela Pedidos
with open('pedidos.csv', 'r') as file:
    next(file)  # Pula o cabeçalho
    for line in file:
        data = line.strip().split(',')
        cursor.execute("INSERT INTO Pedidos (id_pedido, data_hora, status) VALUES (%s, %s, %s)", data)

# Commit para salvar as mudanças
db_connection.commit()

# Fechando o cursor e a conexão
cursor.close()
db_connection.close()
