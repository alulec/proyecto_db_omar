show databases;
use credito ;
use tienda;
show tables;
select * from cuenta;
select * from consumo;
select * from tienda;
 SELECT fecha, tiendano, importe
        FROM consumo
        GROUP BY fecha, tiendano, importe;
       ALTER TABLE tienda
RENAME COLUMN tiendano TO tiendano2;


        
-- 1 Crear dos usuario para la base Crédito
-- a) Un usuario solo puede realizar lecturas en toda las tablas y no puede realizar 
-- mas de 20 consultas por hora 
-- b) El otro usuario escribir y leer en todas las tablas de la base y no puede tener 
-- mas de 3 conexiones concurrentes ni hacer ningún movimiento DDL
-- creacion de usuario lector 1 a)

CREATE USER 'lectorUsuario'@'localhost' IDENTIFIED BY '123456789' WITH MAX_QUERIES_PER_HOUR 20;
GRANT SELECT ON credito.* TO 'lectorUsuario'@'localhost';
-- REVOKE privilegios ON *.* FROM 'lectorUsuario'@'localhost'; // retira los privilegios de un usuario
-- actualiza los privilegios
FLUSH PRIVILEGES;

-- creacion de usuario lesctor y escritor 1 b)
CREATE USER 'lectorescritorUsuario'@'localhost' IDENTIFIED BY '1234567890' WITH MAX_USER_CONNECTIONS 3;
GRANT SELECT, INSERT, UPDATE, DELETE ON *.* TO 'lectorescritorUsuario'@'localhost';
REVOKE CREATE, ALTER, DROP, TRUNCATE ON *.* FROM 'lectorescritorUsuario'@'localhost';
FLUSH PRIVILEGES;

-- instruccion para ver los usuarios existentes
SELECT user, host FROM mysql.user;

-- muestra los privilegios de los usuarios
SHOW GRANTS FOR 'lectorUsuario'@'localhost';
SHOW GRANTS FOR 'lectorescritorUsuario'@'localhost';

-- 2 Generar un procedimiento almacenado que calcule el consumo diario por tienda y 
-- movimiento y lo agregue a una tabla llamada concentradro_consumo que debe 
-- tener fecha, nombre y timo de tienda y el total de consumos o cancelaciones

DELIMITER //
CREATE PROCEDURE calcular_consumo_diariodos()
BEGIN
	-- Crear la tabla 'concentrador_consumo' si no existe
    CREATE TABLE IF NOT EXISTS concentrado_consumo (
        fecha DATE,
        nombre VARCHAR(100),
        tiendano VARCHAR(100),
        importe INT);
    
    -- Insertar los valores en la tabla 'concentrador_consumo' desde consumo
        INSERT INTO concentrado_consumo (fecha, nombre, tiendano, importe)
		SELECT fecha, tnombre, tiendano, importe
		fROM consumo, tienda;
        
	-- Insertar los valores en la tabla 'concentrador_consumo' desde tienda
     /*INSERT INTO concentrado_consumo (nombre)
		SELECT tnombre
		fROM tienda;*/
        
        -- Observar la tabla concentrado_consumo
        select * from concentrado_consumo;
END //
DELIMITER ;

-- mandar a llamar a los procedures
CALL calcular_consumo_diariodos();

-- eliminar el procedure.
drop procedure calcular_consumo_diariodos;

-- eliminar tabla concentrado_consumo
drop table concentrado_consumo;

 -- 3 Generar un procedimiento almacenado que regrese el consumo total por tienda y 
-- los datos del empleado, recibiendo como entrada solo el numero de empleado

DELIMITER //
CREATE PROCEDURE calcular_consumo_tienda()
BEGIN
     SELECT empno, tiendano, importe
        FROM empleado, consumo 
        GROUP BY empno, tiendano, importe;
END //
DELIMITER ;

-- mandar a llamar a los procedures
CALL calcular_consumo_tienda();
-- eliminar el procedure.
drop procedure calcular_consumo_tienda;

-- 4  Generar un trigger que guarden en una bitácora los registros eliminados o 
-- actualizados de consumo, cuenta, empleado, tarjeta tienda

-- creamos la tabla bitacora
CREATE TABLE bitacora (
  id INT AUTO_INCREMENT,
  tabla_afectada VARCHAR(100),
  accion VARCHAR(50),
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
);

-- Trigger para registros eliminados en la tabla 'consumo'
DELIMITER //
CREATE TRIGGER eliminacion_consumo
AFTER DELETE
ON consumo
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla_afectada, accion)
    VALUES ('consumo', 'Eliminación');
END //
DELIMITER ;

-- Trigger para registros actualizados en la tabla 'consumo'
DELIMITER //
CREATE TRIGGER actualizacion_consumo
AFTER UPDATE
ON consumo
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla_afectada, accion)
    VALUES ('consumo', 'Actualización');
END //
DELIMITER ;

-- Trigger para registros eliminados en la tabla 'cuenta'
DELIMITER //
CREATE TRIGGER eliminacion_cuenta
AFTER DELETE
ON cuenta
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla_afectada, accion)
    VALUES ('cuenta', 'Eliminación');
END //
DELIMITER ;

-- Trigger para registros actualizados en la tabla 'cuenta'
DELIMITER //
CREATE TRIGGER actualizacion_cuenta
AFTER UPDATE
ON cuenta
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla_afectada, accion)
    VALUES ('cuenta', 'Actualización');
END //
DELIMITER ;

-- Trigger para registros eliminados en la tabla 'empleado'
DELIMITER //
CREATE TRIGGER eliminacion_empleado
AFTER DELETE
ON empleado
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla_afectada, accion)
    VALUES ('empleado', 'Eliminación');
END //
DELIMITER ;

-- Trigger para registros actualizados en la tabla 'empleado'
DELIMITER //
CREATE TRIGGER actualizacion_empleado
AFTER UPDATE
ON empleado
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla_afectada, accion)
    VALUES ('empleado', 'Actualización');
END //
DELIMITER ;
  
  -- Trigger para registros eliminados en la tabla 'tarjeta'
DELIMITER //
CREATE TRIGGER eliminacion_tarjeta
AFTER DELETE
ON tarjeta
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla_afectada, accion)
    VALUES ('tarjeta', 'Eliminación');
END //
DELIMITER ;

-- Trigger para registros actualizados en la tabla 'tarjeta'
DELIMITER //
CREATE TRIGGER actualizacion_tarjeta
AFTER UPDATE
ON tarjeta
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla_afectada, accion)
    VALUES ('tarjeta', 'Actualización');
END //
DELIMITER ;

-- Trigger para registros eliminados en la tabla 'tienda'
DELIMITER //
CREATE TRIGGER eliminacion_tienda
AFTER DELETE
ON tienda
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla_afectada, accion)
    VALUES ('tienda', 'Eliminación');
END //
DELIMITER ;

-- Trigger para registros actualizados en la tabla 'tienda'
DELIMITER //
CREATE TRIGGER actualizacion_tienda
AFTER UPDATE
ON tienda
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla_afectada, accion)
    VALUES ('tienda', 'Actualización');
END //
DELIMITER ;

-- Trigger para registros actualizados en la tabla 'concentrado_consumo'
DELIMITER //
CREATE TRIGGER actualizacion_concentrado_consumo
AFTER UPDATE
ON concentrado_consumo
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla_afectada, accion)
    VALUES ('concentrado_consumo', 'Actualización');
END //
DELIMITER ;
  -- muestra los trigger activos
  show triggers;
  
  -- borra los triggers
  -- Consulta para obtener los nombres de los triggers existentes en la base de datos
SELECT CONCAT('DROP TRIGGER IF EXISTS ', trigger_name, ';')
FROM information_schema.triggers
WHERE trigger_schema = 'credito';

 -- prueba triggers
  select * from concentrado_consumo;
  insert into consumo (cuentano)
  values ('317040700');
 UPDATE concentrado_consumo SET importe = 1000 WHERE importe =840 ;

  