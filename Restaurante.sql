CREATE DATABASE Restaurante;

USE Restaurante;

-- Tabela Clientes
CREATE TABLE Clientes (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,  
    nome VARCHAR(100) NOT NULL,
    telefone VARCHAR(20),
    email VARCHAR(100)
);

-- Tabela Mesas
CREATE TABLE Mesas (
    id_mesa INT PRIMARY KEY AUTO_INCREMENT,  
    numero INT NOT NULL,
    capacidade INT NOT NULL,
    disponibilidade_mesa VARCHAR(50)
);

-- Tabela Menu
CREATE TABLE Menu (
    id_menu INT PRIMARY KEY AUTO_INCREMENT,  
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10,2) NOT NULL,
    disponibilidade VARCHAR(50)
);

-- Tabela Funcionarios
CREATE TABLE Funcionarios (
    id_funcionario INT PRIMARY KEY AUTO_INCREMENT,  
    nome VARCHAR(100) NOT NULL,
    cargo VARCHAR(50),
    salario DECIMAL(10,2)
);

-- Tabela Pedidos
CREATE TABLE Pedidos (
    id_pedido INT PRIMARY KEY AUTO_INCREMENT, 
    id_cliente INT,
    id_mesa INT,
    data_hora DATETIME,
    status VARCHAR(50),
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente),
    FOREIGN KEY (id_mesa) REFERENCES Mesas(id_mesa)
);

-- Tabela Itens_Pedido
CREATE TABLE Itens_Pedido (
    id_item_pedido INT PRIMARY KEY AUTO_INCREMENT, 
    id_pedido INT NOT NULL,
    id_menu INT NOT NULL,
    quantidade INT NOT NULL,
    FOREIGN KEY (id_pedido) REFERENCES Pedidos(id_pedido),
    FOREIGN KEY (id_menu) REFERENCES Menu(id_menu)
);
