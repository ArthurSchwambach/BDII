-- 1. Cliente com maior gasto por tipo
SELECT DISTINCT c.nome Cliente, c.tipo Tipo, c.gasto Maior_Gasto
FROM Cliente c
WHERE c.gasto = (SELECT MAX(gasto)
                 FROM Cliente c2
                 WHERE c2.tipo = c.tipo);


-- 2. Atendente que mais atendeu Cliente Premium

SELECT a.nome Atendente, COUNT(p.id_cliente) Quantidade
FROM Pedido p
INNER JOIN Cliente c ON p.id_cliente = c.id_cliente
INNER JOIN Atendente a ON p.id_atendente = a.id_atendente
WHERE c.tipo = 'Premium'
GROUP BY a.id_atendente, a.nome
ORDER BY Quantidade DESC
LIMIT 1;

-- 3. Atendente que mais vendeu

SELECT a.nome Atendente, SUM(ip.quantidade * m.preco) Total_Vendido
FROM Pedido p
INNER JOIN Atendente a ON p.id_atendente = a.id_atendente
INNER JOIN Itens_Pedido ip ON p.id_pedido = ip.id_pedido
INNER JOIN Menu m ON ip.id_menu = m.id_menu
GROUP BY a.id_atendente, a.nome
ORDER BY Total_Vendido DESC
LIMIT 1;

-- 4. Top 3 Refeições mais vendidas

SELECT m.nome Item_Menu, SUM(ip.quantidade) Qtd_Vendido
FROM Itens_Pedido ip
INNER JOIN Menu m ON ip.id_menu = m.id_menu
GROUP BY m.id_menu, m.nome
ORDER BY Qtd_Vendido DESC
LIMIT 3;

-- 5. Clientes que tiveram um pedido com a duração maior que a média de duração dos pedidos

SELECT c.nome Cliente, a.nome Atendente, p.duracao Duracao
FROM Pedido p
INNER JOIN Cliente c ON c.id_cliente = p.id_cliente
INNER JOIN Atendente a ON a.id_atendente = p.id_atendente
WHERE p.duracao >  (SELECT AVG(duracao) 
                    FROM Pedido);

-- 6. Cliente com o maior gasto e o valor com desconto

SELECT distinct c.nome Cliente, c.gasto Gasto_Inicial, calcular_desconto(gasto) Descontado
FROM Cliente c
WHERE c.gasto = (SELECT MAX(gasto)
                 FROM Cliente ct);

-- 7. O maior desconto dado a um cliente do tipo comum

SELECT distinct c.nome Cliente, c.gasto - calcular_desconto(gasto) Maior_desconto_Comum
FROM Cliente c
WHERE calcular_desconto(gasto) = (SELECT MAX(calcular_desconto(gasto))
                 FROM Cliente ct
                 WHERE ct.tipo = 'Comum');
