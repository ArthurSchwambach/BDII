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
        WHEN gasto >= 5000 THEN 'Premium'
        ELSE 'Comum'
    END;
END$$

DELIMITER ;