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
FLUSH PRIVILEGES;

/* 2) Generar un procedimiento almacenado que calcule el consumo diario por tienda y
movimiento y lo agregue a una tabla llamada concentradro_consumo que debe
tener fecha, nombre y timo de tienda y el total de consumos o cancelaciones */

DROP TABLE IF EXISTS concentrado_consumo;
CREATE TABLE concentrado_consumo(
	Fecha DATE, nom_tien VARCHAR(45), tien_tipo VARCHAR(45), consu_total INT, cance_total INT
);
DELIMITER $$
DROP PROCEDURE IF EXISTS consu_tien_diario $$
CREATE PROCEDURE consu_tien_diario()
BEGIN
    INSERT INTO concentrado_consumo (
		Fecha, nom_tien, tien_tipo, 
		consu_total, cance_total
	)
    SELECT fecha, tnombre, tipo, SUM(IF(con.movimiento = 'V', con.importe, false)) AS consu_total,
	SUM(IF(con.movimiento = 'C', con.importe, false)) AS cance_total
    FROM consumo  con JOIN tienda ti ON con.tiendano = ti.tiendano
    GROUP BY tnombre, fecha, movimiento, tipo;
END $$
DELIMITER ;

-- Ejecutamos el procedimiento almecenado
CALL consu_tien_diario();
SELECT * FROM concentrado_consumo;


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

UPDATE tienda
SET tipo="patito"
WHERE tiendano=1;

select * from bitacora;

/* 5) Generar un trigger que valide que no se inserten consumos de venta con importe
menor a cero */
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

select tiendano, movimiento, sum(importe)
from consumo group by movimiento, tiendano
order by tiendano;
        

/* 7) Crear una vista que muestre el detalle completo del concentrado de ventas  */

create or replace view concentrado_ventas as
select fecha, tiendano, importe
from consumo
where movimiento = 'V';

select * from concentrado_ventas;

/* 8) Crear una vista que muestre el detalle completo del concentrado de ventas por
	tipo de tienda  */
    
create or replace view concentrado_ventas_tienda as
select a.tiendano, tipo as Tipo_tienda, sum(importe)as pagos_Tienda 
from tienda a
left join consumo p ON(a.tiendano = p.tiendano)
group by a.tiendano;
select * from concentrado_ventas_tienda;

/* 9) Generar un usuario que solo pueda acceder a las dos vistas anteriores */

drop user 'usuarioView'@'localhost';
create user 'usuarioView'@'localhost' identified by '789546%';
grant select on credito.concentrado_ventas to 'usuarioView'@'localhost';
grant select on credito.concentrado_ventas_tienda to 'usuarioView'@'localhost';