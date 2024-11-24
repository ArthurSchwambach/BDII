import mysql.connector

db_connection = mysql.connector.connect(
    host="localhost",
    user="root",
    password="123456",
    database="Restaurante"
)

cursor = db_connection.cursor()

with open('cliente.csv', 'r') as file:
    next(file)
    for line in file:
        data = line.strip().split(',')
        cursor.execute("INSERT INTO Cliente (nome, telefone, email, gasto, tipo) VALUES (%s, %s, %s, %s, %s)", data)

with open('mesa.csv', 'r') as file:
    next(file)
    for line in file:
        data = line.strip().split(',')
        cursor.execute("INSERT INTO Mesa (capacidade, numero, disponibilidade_mesa) VALUES (%s, %s, %s)", data)

with open('menu.csv', 'r') as file:
    next(file) 
    for line in file:
        data = line.strip().split(',')
        cursor.execute("INSERT INTO Menu (nome, descricao, preco, disponibilidade_menu) VALUES (%s, %s, %s, %s)", data)

with open('atendente.csv', 'r') as file:
    next(file)
    for line in file:
        data = line.strip().split(',')
        cursor.execute("INSERT INTO Atendente (nome, telefone, email, salario) VALUES (%s, %s, %s, %s)", data)

db_connection.commit()

cursor.close()
db_connection.close()
