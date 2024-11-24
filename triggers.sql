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