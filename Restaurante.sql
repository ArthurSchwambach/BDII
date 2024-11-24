Drop database Restaurante;
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
    disponibilidade_mesa ENUM('Disponível', 'Ocupada') DEFAULT 'Disponível'
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
    fim TIMESTAMP,
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

-- Procedimentos
DELIMITER $$

CREATE PROCEDURE PopularPedidos(
    IN num_pedidos INT
)
BEGIN
    DECLARE cliente_id_val INT;
    DECLARE mesa_id_val INT;
    DECLARE atendente_id_val INT;
    DECLARE pedido_id_val INT;
    DECLARE menu_id_val INT;
    DECLARE contador INT DEFAULT 0;
    DECLARE done INT DEFAULT 0;
    DECLARE pedido_status VARCHAR(20);

    DECLARE cur_menu CURSOR FOR 
        SELECT id_menu FROM Menu;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur_menu;

    pedido_loop: LOOP
        IF contador >= num_pedidos THEN
            LEAVE pedido_loop;
        END IF;


        SET cliente_id_val = (SELECT id_cliente FROM Cliente ORDER BY RAND() LIMIT 1);

        SET mesa_id_val = (SELECT id_mesa FROM Mesa WHERE disponibilidade_mesa = 'Disponível' ORDER BY RAND() LIMIT 1);

        SET atendente_id_val = (SELECT id_atendente FROM Atendente ORDER BY RAND() LIMIT 1);

        SET pedido_status = CASE
            WHEN RAND() <= 0.55 THEN 'Fechado'
            WHEN RAND() <= 0.75 THEN 'Cancelado'
            ELSE 'Aberto'             
        END;

        INSERT INTO Pedido (id_cliente, id_mesa, id_atendente, inicio, fim, status)
        VALUES (
            cliente_id_val, 
            mesa_id_val, 
            atendente_id_val, 
            CURRENT_TIMESTAMP, 
            CASE 
                WHEN pedido_status = 'Aberto' THEN NULL 
                ELSE DATE_ADD(CURRENT_TIMESTAMP, INTERVAL FLOOR(RAND() * 120 + 30) MINUTE) 
            END,
            pedido_status
        );

        SET pedido_id_val = LAST_INSERT_ID();

        FETCH cur_menu INTO menu_id_val;
        WHILE NOT done DO
            INSERT INTO Itens_Pedido (id_pedido, id_menu, quantidade)
            VALUES (
                pedido_id_val,
                menu_id_val,
                FLOOR(RAND() * 5) + 1
            );
            FETCH cur_menu INTO menu_id_val;
        END WHILE;

        SET done = 0;

        SET contador = contador + 1;
    END LOOP;

    CLOSE cur_menu;
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE AtualizarTipoClientes()
BEGIN
    UPDATE Cliente
    SET tipo = CASE
        WHEN gasto >= 15000 THEN 'Premium'
        ELSE 'Comum'
    END;
END$$

DELIMITER ;

-- Triggers

-- Disponibilidade da mesa

DELIMITER $$

CREATE TRIGGER LiberarMesaAoFecharPedido
AFTER UPDATE ON Pedido
FOR EACH ROW
BEGIN
    IF OLD.status = 'Aberto' AND NEW.status = 'Fechado' THEN
        UPDATE Mesa
        SET disponibilidade_mesa = 'Disponível'
        WHERE id_mesa = NEW.id_mesa;
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER AtualizarDisponibilidadeMesa
AFTER INSERT ON Pedido
FOR EACH ROW
BEGIN
    IF NEW.status = 'Aberto' THEN
        UPDATE Mesa
        SET disponibilidade_mesa = 'Ocupada'
        WHERE id_mesa = NEW.id_mesa;
    END IF;
END$$

DELIMITER ;

-- Função

DELIMITER $$

CREATE FUNCTION calcular_desconto(valor DECIMAL(10,2)) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE desconto DECIMAL(10,2);
    SET desconto = valor * 0.10;
    RETURN valor - desconto;
END$$

DELIMITER ;
