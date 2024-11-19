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

    -- Cursor para percorrer os itens do menu
    DECLARE cur_menu CURSOR FOR 
        SELECT id_menu FROM Menu;

    -- Handler para o fim do cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Abrir o cursor
    OPEN cur_menu;

    -- Loop para criar pedidos
    pedido_loop: LOOP
        IF contador >= num_pedidos THEN
            LEAVE pedido_loop;
        END IF;

        -- Selecionar um cliente aleatório
        SET cliente_id_val = (SELECT id_cliente FROM Clientes ORDER BY RAND() LIMIT 1);

        -- Selecionar uma mesa disponível aleatória
        SET mesa_id_val = (SELECT id_mesa FROM Mesas WHERE disponibilidade_mesa = 'Disponível' ORDER BY RAND() LIMIT 1);

        -- Selecionar um atendente aleatório
        SET atendente_id_val = (SELECT id_atendente FROM Atendentes ORDER BY RAND() LIMIT 1);

        -- Inserir o pedido na tabela Pedidos
        INSERT INTO Pedidos (id_cliente, id_mesa, id_atendente, inicio, fim, status)
        VALUES (
            cliente_id_val, 
            mesa_id_val, 
            atendente_id_val, 
            CURRENT_TIMESTAMP, 
            DATE_ADD(CURRENT_TIMESTAMP, INTERVAL FLOOR(RAND() * 120 + 30) MINUTE), 
            'Aberto'
        );

        -- Obter o ID do pedido inserido
        SET pedido_id_val = LAST_INSERT_ID();

        -- Inserir itens no pedido
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

        -- Resetar a variável do cursor
        SET done = 0;

        -- Atualizar o contador
        SET contador = contador + 1;
    END LOOP;

    -- Fechar o cursor
    CLOSE cur_menu;
END$$

DELIMITER ;