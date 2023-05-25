use Credito;

-- Crear dos usuario para la base Crédito
create user 'usuario1'@'localhost' identified by '123456%';
create user 'usuario2'@'localhost' identified by '12345%';

-- Un usuario solo puede realizar lecturas en toda las tablas y no puede realizar
-- mas de 20 consultas por hora
grant select on credito.* to 'usuario1'@'localhost';
ALTER USER 'usuario1'@'localhost' WITH MAX_QUERIES_PER_HOUR 20;

-- El otro usuario escribir y leer en todas las tablas de la base y no puede tener
-- mas de 3 conexiones concurrentes ni hacer ningún movimiento DDL
grant select on credito.* to 'usuario2'@'localhost';
grant insert on credito.* to 'usuario2'@'localhost';
ALTER USER 'operador1'@'localhost' WITH MAX_USER_CONNECTIONS 3;

CREATE PROCEDURE calcular_consumo_diario
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO concentrador_consumo(fecha, nombre_tienda, tipo_movimiento, total_consumo_cancelacion)
    SELECT 
        CONVERT(date, GETDATE()), 
        t.nombre, 
        c.tipo_movimiento, 
        SUM(c.cantidad) 
    FROM 
        tienda t 
        INNER JOIN consumo c ON t.id_tienda = c.id_tienda 
    WHERE 
        CONVERT(date, c.fecha) = CONVERT(date, GETDATE()) 
    GROUP BY 
        t.nombre, 
        c.tipo_movimiento;
END
