CREATE DATABASE Restaurante;

USE Restaurante;

-- Tabela Clientes
CREATE TABLE Cliente (
    id_cliente INT NOT NULL PRIMARY KEY AUTO_INCREMENT,  
    nome VARCHAR(100) NOT NULL,
    telefone VARCHAR(20),
    email VARCHAR(100),
    gasto DECIMAL(10,2) DEFAULT 0.00,
    tipo ENUM('Premium', 'Comum') DEFAULT 'Comum'
);

-- Tabela Mesas
CREATE TABLE Mesa (
    id_mesa INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
    numero INT NOT NULL,
    capacidade TINYINT NOT NULL,
    disponibilidade_mesa ENUM('Disponível', 'Ocupada', 'Reservada') DEFAULT 'Disponível'
);

-- Tabela Menu
CREATE TABLE Menu (
    id_menu INT NOT NULL PRIMARY KEY AUTO_INCREMENT,  
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10,2) NOT NULL,
    disponibilidade_menu ENUM('Disponível', 'Não Disponível') DEFAULT 'Disponível'
);

-- Tabela Atendentes (substituindo Funcionarios)
CREATE TABLE Atendente (
    id_atendente INT NOT NULL PRIMARY KEY AUTO_INCREMENT,  
    nome VARCHAR(100) NOT NULL,
    telefone VARCHAR(20),
    email VARCHAR(100),
    salario DECIMAL(10,2) NOT NULL CHECK (salario >= 2000)
);

-- Tabela Pedidos
CREATE TABLE Pedido (
    id_pedido INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
    id_cliente INT,
    id_mesa INT,
    id_atendente INT,
    inicio TIMESTAMP NOT NULL,
    fim TIMESTAMP NOT NULL,
    duracao INT GENERATED ALWAYS AS (TIMESTAMPDIFF(SECOND, inicio, fim)) STORED,
    status ENUM('Aberto', 'Fechado', 'Cancelado') DEFAULT 'Aberto',
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    FOREIGN KEY (id_mesa) REFERENCES Mesa(id_mesa),
    FOREIGN KEY (id_atendente) REFERENCES Atendente(id_atendente),
    CHECK (fim > inicio)
);

-- Tabela Itens_Pedido
CREATE TABLE Itens_Pedido (
    id_item_pedido INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
    id_pedido INT NOT NULL,
    id_menu INT NOT NULL,
    quantidade INT NOT NULL CHECK (quantidade > 0),
    FOREIGN KEY (id_pedido) REFERENCES Pedido(id_pedido),
    FOREIGN KEY (id_menu) REFERENCES Menu(id_menu)
);
