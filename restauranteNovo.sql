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
    disponibilidade_mesa ENUM('Disponível', 'Ocupada', 'Reservada') DEFAULT 'Disponível',
    UNIQUE (numero)  -- Garantir que o número da mesa seja único
);

-- Tabela Menu
CREATE TABLE Menu (
    id_menu INT NOT NULL PRIMARY KEY AUTO_INCREMENT,  
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10,2) NOT NULL,
    disponibilidade_menu ENUM('Disponível', 'Não Disponível') DEFAULT 'Disponível'
);

-- Tabela Atendentes
CREATE TABLE Atendente (
    id_atendente INT NOT NULL PRIMARY KEY AUTO_INCREMENT,  
    nome VARCHAR(100) NOT NULL,
    telefone VARCHAR(20),
    email VARCHAR(100),
    salario DECIMAL(10,2) NOT NULL CHECK (salario >= 2000)  -- Garante salário mínimo de R$2000
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
    FOREIGN KEY (id_menu) REFERENCES Menu(id_menu),
    UNIQUE (id_pedido, id_menu)  -- Garante que o item não seja duplicado no pedido
);

-- 2. Popular o Banco de Dados
DELIMITER $$

CREATE PROCEDURE PopularPedidos(
    IN num_pedidos INT
)
BEGIN
    -- Declaração de variáveis
    DECLARE cliente_id_val INT;
    DECLARE mesa_id_val INT;
    DECLARE atendente_id_val INT;
    DECLARE pedido_id_val INT;
    DECLARE menu_id_val INT;
    DECLARE contador INT DEFAULT 0;
    DECLARE done INT DEFAULT 0;

    DECLARE cur_menu CURSOR FOR 
        SELECT id_menu FROM Menu;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur_menu;

    pedido_loop: LOOP
        IF contador >= num_pedidos THEN
            LEAVE pedido_loop;
        END IF;

        -- Seleção aleatória de cliente, mesa e atendente
        SET cliente_id_val = (SELECT id_cliente FROM Cliente ORDER BY RAND() LIMIT 1);
        SET mesa_id_val = (SELECT id_mesa FROM Mesa WHERE disponibilidade_mesa = 'Disponível' ORDER BY RAND() LIMIT 1);
        SET atendente_id_val = (SELECT id_atendente FROM Atendente ORDER BY RAND() LIMIT 1);

        -- Inserção de novo pedido
        INSERT INTO Pedido (id_cliente, id_mesa, id_atendente, inicio, fim, status)
        VALUES (cliente_id_val, mesa_id_val, atendente_id_val, CURRENT_TIMESTAMP, DATE_ADD(CURRENT_TIMESTAMP, INTERVAL FLOOR(RAND() * 120 + 30) MINUTE), 'Aberto');

        SET pedido_id_val = LAST_INSERT_ID();

        SET done = 0;
        menu_loop: LOOP
            FETCH cur_menu INTO menu_id_val;
            IF done THEN
                LEAVE menu_loop;
            END IF;

            -- Inserção de itens de pedido
            INSERT INTO Itens_Pedido (id_pedido, id_menu, quantidade)
            VALUES (pedido_id_val, menu_id_val, FLOOR(RAND() * 5) + 1);
        END LOOP;

        SET contador = contador + 1;
    END LOOP;

    CLOSE cur_menu;
END$$

DELIMITER ;

-- 3. Consultas

-- 1º Qual o prato mais vendido
SELECT 
    m.nome AS prato,
    SUM(ip.quantidade) AS total_vendido
FROM 
    Itens_Pedido ip
JOIN 
    Menu m ON ip.id_menu = m.id_menu
WHERE 
    m.disponibilidade_menu = 'Disponível'
GROUP BY 
    m.nome
ORDER BY 
    total_vendido DESC
LIMIT 1;

-- 2º Cliente que mais comprou
SELECT 
    c.nome AS cliente,
    SUM(ip.quantidade * m.preco) AS total_gasto
FROM 
    Pedido p
JOIN 
    Cliente c ON p.id_cliente = c.id_cliente
JOIN 
    Itens_Pedido ip ON p.id_pedido = ip.id_pedido
JOIN 
    Menu m ON ip.id_menu = m.id_menu
GROUP BY 
    c.id_cliente
ORDER BY 
    total_gasto DESC
LIMIT 1;

-- 3º Atendente que mais atendeu
SELECT 
    a.nome AS atendente,
    COUNT(p.id_pedido) AS total_atendimentos
FROM 
    Pedido p
JOIN 
    Atendente a ON p.id_atendente = a.id_atendente
WHERE 
    p.status IN ('Fechado', 'Aberto')  -- Considerando pedidos fechados e abertos
GROUP BY 
    a.id_atendente
ORDER BY 
    total_atendimentos DESC
LIMIT 1;

-- 4. Otimizar

-- Índices para otimizar consultas
CREATE INDEX idx_cliente_id ON Pedido(id_cliente);
CREATE INDEX idx_mesa_id ON Pedido(id_mesa);
CREATE INDEX idx_atendente_id ON Pedido(id_atendente);
CREATE INDEX idx_id_menu ON Itens_Pedido(id_menu);

-- 5. Estruturas Avançadas

-- Função UDF: Calcular Desconto para Clientes Premium
DELIMITER $$

CREATE FUNCTION calcular_desconto(gasto DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    IF gasto > 1000 THEN
        RETURN gasto * 0.90;  -- 10% de desconto
    ELSE
        RETURN gasto;
    END IF;
END $$

DELIMITER ;

-- Trigger: Atualizar Disponibilidade de Mesa quando o pedido for fechado
DELIMITER $$

CREATE TRIGGER atualizar_disponibilidade_mesa
AFTER UPDATE ON Pedido
FOR EACH ROW
BEGIN
    IF NEW.status = 'Fechado' THEN
        UPDATE Mesa
        SET disponibilidade_mesa = 'Disponível'
        WHERE id_mesa = NEW.id_mesa;
    END IF;
END $$

DELIMITER ;
