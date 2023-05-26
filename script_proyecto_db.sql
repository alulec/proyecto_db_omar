/* Nombre de los integrantes:
	Alexis Jesus Cordova de la Cruz
	Marcial González Jaime Omar
    Javier Espinosa Gómez
*/

-- Iniciamos la base de datos de credito
use Credito;

-- 1) Crear dos usuario para la base Crédito
create user 'usuario1'@'localhost' identified by '123456%';
create user 'usuario2'@'localhost' identified by '12345%';

/*  a) Un usuario solo puede realizar lecturas en toda las tablas y no puede realizar
mas de 20 consultas por hora.  */
grant select on credito.* to 'usuario1'@'localhost';
ALTER USER 'usuario1'@'localhost' WITH MAX_QUERIES_PER_HOUR 20;
FLUSH PRIVILEGES;


/* b) El otro usuario escribir y leer en todas las tablas de la base y no puede tener
mas de 3 conexiones concurrentes ni hacer ningún movimiento DDL. */
grant insert on credito.* to 'usuario2'@'localhost';
grant select on credito.* to 'usuario2'@'localhost';
ALTER USER 'operador1'@'localhost' WITH MAX_USER_CONNECTIONS 3;
GRANT SELECT, INSERT, UPDATE, DELETE ON *.* TO 'usuario1'@'localhost';
REVOKE CREATE, ALTER, DROP, TRUNCATE ON *.* FROM 'usuario1'@'localhost';
FLUSH PRIVILEGES;

/* 2) Generar un procedimiento almacenado que calcule el consumo diario por tienda y
movimiento y lo agregue a una tabla llamada concentradro_consumo que debe
tener fecha, nombre y timo de tienda y el total de consumos o cancelaciones */

DELIMITER $$
DROP PROCEDURE IF EXISTS calculo_consumo_diario $$
CREATE PROCEDURE calculo_consumo_diario()
BEGIN
    CREATE TABLE IF NOT EXISTS concentrado_consumo (
        fecha DATE,
        nombre VARCHAR(30),
        tipo varchar(20),
        importe INT);

        INSERT INTO concentrado_consumo (fecha, nombre, tipo, importe)
		SELECT fecha, tnombre, tipo, importe
		FROM tienda, consumo;
        select * from concentrado_consumo;
END $$
DELIMITER ;
-- Ejecutamos el procedimiento almecenado
CALL calculo_consumo_diario;


/*3) Generar un procedimiento almacenado que regrese el consumo total por tienda y
los datos del empleado, recibiendo como entrada solo el numero de empleado */

DELIMITER $$
DROP PROCEDURE IF EXISTS tienda_empleado_calculo $$
CREATE PROCEDURE tienda_empleado_calculo()
BEGIN
     SELECT empno, tiendano, importe
        FROM empleado, consumo 
        GROUP BY empno, tiendano, importe;
END $$
DELIMITER ;
-- Ejecutamos el procedimiento almecenado
CALL tienda_empleado_calculo();

/*  4) Generar un trigger que guarden en una bitácora los registros eliminados o
actualizados de consumo, cuenta, empleado, tarjeta tienda. */

-- punto 04: generar un trigger... bitacora
drop table if exists bitacora;
create table bitacora(
    id int not null auto_increment primary key,
    fecha datetime not null,
    usuario varchar(50) not null,
    tabla varchar(50) not null,
    accion text null
);

delimiter //
DROP TRIGGER  IF EXISTS after_delete_consumo//
CREATE TRIGGER after_delete_consumo
after delete ON consumo
FOR EACH ROW
BEGIN
	insert into bitacora values (
    null, sysdate(), user(), 'Consumo',
    JSON_OBJECT('Sentencia', 'Delete',
    'cuentano', old.cuentano, 'movimiento', old.movimiento, 'importe', old.importe)
    );
END; //
DELIMITER ;

delimiter //
DROP TRIGGER  IF EXISTS after_update_consumo//
CREATE TRIGGER after_update_consumo
after update ON consumo
FOR EACH ROW
BEGIN
	insert into bitacora values (
    null, sysdate(), user(), 'Consumo',
    JSON_OBJECT('Sentencia', 'Update',
    'cuentano', old.cuentano, 'movimiento', old.movimiento, 'importe', old.importe)
    );
END; //
DELIMITER ;

delimiter //
DROP TRIGGER  IF EXISTS after_delete_cuenta//
CREATE TRIGGER after_delete_cuenta
after delete ON cuenta
FOR EACH ROW
BEGIN
	insert into bitacora values (
    null, sysdate(), user(), 'Cuenta',
    JSON_OBJECT('Sentencia', 'Delete',
    'cuentano', old.cuentano, 'empno', old.empno, 'factivacion', old.factivacion)
    );
END; //
DELIMITER ;

delimiter //
DROP TRIGGER  IF EXISTS after_update_cuenta//
CREATE TRIGGER after_update_cuenta
after update ON cuenta
FOR EACH ROW
BEGIN
	insert into bitacora values (
    null, sysdate(), user(), 'Cuenta',
    JSON_OBJECT('Sentencia', 'Update',
    'cuentano', old.cuentano, 'empno', old.empno, 'factivacion', old.factivacion)
    );
END; //
DELIMITER ;

delimiter //
DROP TRIGGER  IF EXISTS after_delete_empleado//
CREATE TRIGGER after_delete_empleado
after delete ON empleado
FOR EACH ROW
BEGIN
	insert into bitacora values (
    null, sysdate(), user(), '',
    JSON_OBJECT('Sentencia', 'Delete',
    'empno', old.empno, 'puestono', old.puestono, 'deptono', old.deptono)
    );
END; //
DELIMITER ;

delimiter //
DROP TRIGGER  IF EXISTS after_update_empleado//
CREATE TRIGGER after_update_empleado
after update ON empleado
FOR EACH ROW
BEGIN
	insert into bitacora values (
    null, sysdate(), user(), 'Cuenta',
    JSON_OBJECT('Sentencia', 'Update',
    'empno', old.empno, 'puestono', old.puestono, 'deptono', old.deptono)
    );
END; //
DELIMITER ;

delimiter //
DROP TRIGGER  IF EXISTS after_delete_tarjeta//
CREATE TRIGGER after_delete_tarjeta
after delete ON tarjeta
FOR EACH ROW
BEGIN
	insert into bitacora values (
    null, sysdate(), user(), 'Tarjeta',
    JSON_OBJECT('Sentencia', 'Delete',
    'cuentano', old.cuentano, 'tarjeta', old.tarjeta)
    );
END; //
DELIMITER ;

delimiter //
DROP TRIGGER  IF EXISTS after_update_tarjeta//
CREATE TRIGGER after_update_tarjeta
after update ON tarjeta
FOR EACH ROW
BEGIN
	insert into bitacora values (
    null, sysdate(), user(), 'tarjeta',
    JSON_OBJECT('Sentencia', 'Update',
    'cuentano', old.cuentano, 'tarjeta', old.tarjeta)
    );
END; //
DELIMITER ;

delimiter //
DROP TRIGGER  IF EXISTS after_delete_tienda//
CREATE TRIGGER after_delete_tienda
after delete ON tienda
FOR EACH ROW
BEGIN
	insert into bitacora values (
    null, sysdate(), user(), 'Tienda',
    JSON_OBJECT('Sentencia', 'Delete',
    'tienda', old.tiendano, 'tipo', old.tipo, 'tnombre', old.tnombre)
    );
END; //
DELIMITER ;

delimiter //
DROP TRIGGER  IF EXISTS after_update_tienda//
CREATE TRIGGER after_update_tienda
after update ON tienda
FOR EACH ROW
BEGIN
	insert into bitacora values (
    null, sysdate(), user(), 'Tienda',
    JSON_OBJECT('Sentencia', 'Update',
    'tienda', old.tiendano, 'tipo', old.tipo, 'tnombre', old.tnombre)
    );
END; //
DELIMITER ;

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
