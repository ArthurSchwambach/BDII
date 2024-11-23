-- Triggers

-- Quando um pedido é concluído, esse trigger atualiza os gastos do cliente

DELIMITER $$

CREATE TRIGGER AtualizarGastoCliente
AFTER UPDATE ON Pedido
FOR EACH ROW
BEGIN
        IF OLD.status = 'Aberto' AND NEW.status = 'Fechado' THEN
        UPDATE Cliente 
        SET gasto = gasto + (SELECT SUM(preco * quantidade)
                             FROM Itens_Pedido
                             JOIN Menu ON Itens_Pedido.id_menu = Menu.id_menu
                             WHERE Itens_Pedido.id_pedido = NEW.id_pedido)
        WHERE id_cliente = NEW.id_cliente;
    END IF;
END$$

DELIMITER ;

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
Before INSERT ON Pedido
FOR EACH ROW
BEGIN
    IF NEW.status = 'Aberto' THEN
        UPDATE Mesa
        SET disponibilidade_mesa = 'Ocupada'
        WHERE id_mesa = NEW.id_mesa;
    END IF;
END$$

DELIMITER ;


