/*1.Escribe un procedimiento que no tenga ningún parámetro de entrada ni de salida y que muestre el texto ¡Hola mundo!.*/
DELIMITER $$
create procedure saludo()
begin
	select "hola mundo";
end $$
DELIMITER ;

/*2.Escribe un procedimiento que reciba un número real de entrada, que representa el valor de la nota de un alumno, 
y muestre un mensaje indicando qué nota ha obtenido teniendo en cuenta las siguientes condiciones:
[0,5) = Insuficiente
[5,6) = Aprobado
[6, 7) = Bien
[7, 9) = Notable
[9, 10] = Sobresaliente
En cualquier otro caso la nota no será válida.*/

Delimiter //
Create procedure CalcularNota(IN nota float )
Begin 
Declare calificacion varchar(50);
If nota >= 0 and nota < 5 then 
	set calificacion = "Insuficiente";

elseif nota >= 5 and nota < 6 then 
	set calificacion = "Aprobado";

elseif nota >= 6 and nota < 7 then 
	set calificacion = "Bien";

elseif nota >= 7 and nota < 9 then 
	set calificacion = "Notable";

elseif nota >= 9 and nota < 10 then 
	set calificacion = "Sobresaliente";
else 
	set calificacion = "Nota no valida";

end If;
select calificacion;
end //

Call CalcularNota(2.0);

/*3.Escriba un procedimiento llamado cantidadProductos que reciba como entrada el nombre del tipo de producto
 y devuelva el número de productos que existen dentro de esa categoría. */

Delimiter //
create procedure cantidadProductos(in Nombretipoproduc varchar(50), out cantidad int)
begin 
	select count(*) into cantidad
    from productos, tipo_producto
    where tipo_producto.nombreTipoProducto = Nombretipoproduc
    and productos.idTipoProducto = tipo_producto.idTipoProducto;
end
//


/*4.Escribe un procedimiento que se llame preciosProductos, 
que reciba como parámetro de entrada el nombre del tipo de producto y devuelva como salida tres parámetros. 
El precio máximo, el precio mínimo y la media de los productos que existen en esa categoría. */

Delimiter //
create procedure preciosProductos(in Nombretipoproduc varchar(50), out preciomax decimal(5,3), 
																   out preciomin decimal(5,3), 
																   out media decimal(5,3) )
begin 
set preciomax = (
	select max(valor)
    from productos, tipo_producto
    where tipo_producto.nombreTipoProducto = Nombretipoproduc
    and productos.idTipoProducto = tipo_producto.idTipoProducto
				);

set preciomin =(
	select min(valor)
    from productos, tipo_producto
    where tipo_producto.nombreTipoProducto = Nombretipoproduc
    and productos.idTipoProducto = tipo_producto.idTipoProducto
				);

set media =(
	select AVG(valor)
    from productos, tipo_producto
    where tipo_producto.nombreTipoProducto = Nombretipoproduc
    and productos.idTipoProducto = tipo_producto.idTipoProducto
			);
end //


/*5.Realice un procedimiento que se llame funcionIVA que incluya una función que calcule el total
 con el incremento del iva.*/
 
delimiter //
create function funcionIVA (valor decimal(5,3))
returns decimal(5,3) DETERMINISTIC
begin
   declare iva decimal (5,3);
   
    set iva  = valor * 1.19;
    return iva; 
end //

select sumerca.funcionIVA(productos.valor) as ValorTotal, productos.nombreProducto from productos;

/*6.	Escribe un procedimiento que reciba el nombre de un país como parámetro de entrada 
y realice una consulta sobre la tabla sucursal para obtener todas las sucursales que existen en la tabla de ese país.*/
#creacion de tablas punto 6
CREATE TABLE  pais(
  id int NOT NULL AUTO_INCREMENT,
  nombre varchar(45),
  PRIMARY KEY (id)
);

CREATE TABLE  ciudad(
  id int NOT NULL AUTO_INCREMENT,
  nombre varchar(45),
  PRIMARY KEY (id)
);
CREATE TABLE  sucursal(
  id int NOT NULL AUTO_INCREMENT,
  nombre varchar(45),
  id_pais int,
  id_ciudad int,
  direccion varchar(50),
  PRIMARY KEY (id),
  FOREIGN KEY (id_pais) REFERENCES pais(id),
  FOREIGN KEY (id_ciudad) REFERENCES ciudad(id)
)

/*7.Una vez creada la tabla se decide añadir una nueva columna a la tabla llamada edad que será un valor calculado a partir de la columna fecha_nacimiento. 
Escriba la sentencia SQL necesaria para modificar la tabla y añadir la nueva columna*/

CREATE TABLE  usuario(
  id int NOT NULL,
  nombre varchar(45),
  fecha_de_nacimiento date,
  PRIMARY KEY (id)
);

select*
from usuario ;

alter table usuario
add column edad int;

insert into usuario(id,nombre,fecha_de_nacimiento) values ("1220", "andrea suarez", "2001-02-11"), ("23220", "juan camargo", "1999-09-01"),
("1333", "marta cruz", "1986-10-18"),("17820", "felipe pliorez", "2003-01-11");


	
/*8.Escriba una función llamada calcularEdad que reciba una fecha y devuelva el número de años
 que han pasado desde la fecha actual hasta la fecha pasada como parámetro:*/

Delimiter //
CREATE FUNCTION calcularEdad(fecha_nacimiento date) RETURNS int
    DETERMINISTIC
begin 
    declare edad int;
    select year(now()) - year(fecha_nacimiento) into edad;
    return edad;

end //

/*9.Escriba un procedimiento que permita calcular la edad de todos los usuarios que ya existen en la tabla. 
Para esto será necesario crear un procedimiento llamado actualizarColumnaEdad que calcule la edad de cada usuario
 y actualice la tabla. Este procedimiento hará uso de la función calcularEdad que hemos creado en el paso anterior.*/

DELIMITER //
CREATE PROCEDURE actualizarColumnaEdad()
BEGIN
	DECLARE fecha DATE;
	DECLARE idU INT;
	DECLARE edadUsuario INT;
	
    	DECLARE fin INTEGER DEFAULT 0;
        DECLARE calEdad CURSOR FOR SELECT id, fecha_de_nacimiento FROM usuario;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET fin = 1;
    
	OPEN calEdad;
		proceso:LOOP
		
		FETCH calEdad INTO idU, fecha;

		IF fin = 1 THEN
			LEAVE proceso;
		END IF;
		SET edadUsuario = calcularEdad(fecha);

		UPDATE usuario SET edad = (edadUsuario) WHERE id = idU;

	END LOOP; 
	CLOSE calEdad;
    
END ;

/*10.	Escribe un procedimiento almacenado para su proyecto integrador que sea útil.*/
/* CREAR USUARIO Y CONTRASEÑA */

DELIMITER $$
create procedure UsuarioContraseña(in id int, in nombre varchar(45), in apellido varchar(45))
begin 
select concat(upper(substr(nombre,1,4)),upper(substr(apellido, 1,2)),substr(id, 1,3))"usuario",
concat(substr(id, 1,4),".",upper(substr(apellido, 1,2)))"contraseña";
end $$