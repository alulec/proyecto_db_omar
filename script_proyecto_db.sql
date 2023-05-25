use Credito;
-- 1) Crear dos usuario para la base Crédito
create user 'usuario1'@'localhost' identified by '123456%';
create user 'usuario2'@'localhost' identified by '12345%';

/* 
a) Un usuario solo puede realizar lecturas en toda las tablas y no puede realizar
mas de 20 consultas por hora
*/
grant select on credito.* to 'usuario1'@'localhost';
ALTER USER 'usuario1'@'localhost' WITH MAX_QUERIES_PER_HOUR 20;

/* 
b) El otro usuario escribir y leer en todas las tablas de la base y no puede tener
mas de 3 conexiones concurrentes ni hacer ningún movimiento DDL
*/
grant insert on credito.* to 'usuario2'@'localhost';
grant select on credito.* to 'usuario2'@'localhost';
ALTER USER 'operador1'@'localhost' with max_connections_per_hour 3;

/*
2) Generar un procedimiento almacenado que calcule el consumo diario por tienda y
movimiento y lo agregue a una tabla llamada concentradro_consumo que debe
tener fecha, nombre y timo de tienda y el total de consumos o cancelaciones
*/
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
/*
3) Generar un procedimiento almacenado que regrese el consumo total por tienda y
los datos del empleado, recibiendo como entrada solo el numero de empleado
*/
DELIMITER $$
DROP PROCEDURE IF EXISTS consumoPorTiendaAndDatosEmpleado $$
CREATE PROCEDURE consumoPorTiendaAndDatosEmpleado(IN numeroEmpleado int)
BEGIN
    SELECT deptono FROM empleado where empno like numeroEmpleado;
END$$
DELIMITER ;

call consumoPorTiendaAndDatosEmpleado(12001);

/*
4) Generar un trigger que guarden en una bitácora los registros eliminados o
actualizados de consumo, cuenta, empleado, tarjeta tienda
*/


/*
5) Generar un trigger que valide que no se inserten consumos de venta con importe
menor a cero
*/
DELIMITER // 
DROP TRIGGER IF EXISTS importeMenorCero//
CREATE TRIGGER importeMenorCero 
before INSERT ON consumo  
FOR EACH ROW 
BEGIN    
    if(new.importe <= 0) then 
    signal sqlstate'45000'
    set message_text = 'No se peude introducir importes iguales o menores a cero';
    end if;
END //
DELIMITER ;
insert into consumo values ("00023450074",'2023-08-23', 2, "C", -12);
