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
