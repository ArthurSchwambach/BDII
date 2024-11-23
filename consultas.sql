-- Cliente com maior gasto por tipo
SELECT c.nome Cliente, c.tipo Tipo, c.gasto Maior_Gasto
FROM Cliente c
WHERE c.gasto = (SELECT MAX(gasto)
                 FROM Cliente c2
                 WHERE c2.tipo = c.tipo);

-- Atendente que mais atendeu Cliente Premium

SELECT a.nome Atendente, COUNT(p.id_cliente) Quantidade
FROM Pedido p
JOIN Cliente c ON p.id_cliente = c.id_cliente
JOIN Atendente a ON p.id_atendente = a.id_atendente
WHERE c.tipo = 'Premium'
GROUP BY a.id_atendente, a.nome
ORDER BY Quantidade DESC
LIMIT 1;

-- Atendente que mais vendeu

SELECT a.nome Atendente, SUM(ip.quantidade * m.preco) Total_Vendido
FROM Pedido p
JOIN Atendente a ON p.id_atendente = a.id_atendente
JOIN Itens_Pedido ip ON p.id_pedido = ip.id_pedido
JOIN Menu m ON ip.id_menu = m.id_menu
GROUP BY a.id_atendente, a.nome
ORDER BY Total_Vendido DESC
LIMIT 1;

-- Top 3 Refeições mais vendidas

SELECT m.nome Item_Menu, SUM(ip.quantidade) Qtd_Vendido
FROM Itens_Pedido ip
JOIN Menu m ON ip.id_menu = m.id_menu
GROUP BY m.id_menu, m.nome
ORDER BY Qtd_Vendido DESC
LIMIT 3;