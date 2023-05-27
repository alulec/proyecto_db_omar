BASE_DATOS=$1
ARCHIVO_CONFIGURACION="/home/alexis/Escritorio/Repositorio/MySql/parametros.cfg"
RUTA_RESPALDO="/home/alexis/Escritorio/Repositorio/MySql"
ARCHIVO_RESPALDO=$(date +%Y%m%d%H%M%S)_$BASE_DATOS.sql
RUTA_ARCHIVO_RESPALDO="$RUTA_RESPALDO/$ARCHIVO_RESPALDO"
/usr/bin/mysqldump --defaults-file=$ARCHIVO_CONFIGURACION $BASE_DATOS > $RUTA_ARCHIVO_RESPALDO
