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

