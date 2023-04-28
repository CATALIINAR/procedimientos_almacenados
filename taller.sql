-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 27-04-2023 a las 13:18:10
-- Versión del servidor: 10.4.28-MariaDB
-- Versión de PHP: 8.0.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `taller`
--

DELIMITER $$
--
-- Procedimientos
--
DROP PROCEDURE IF EXISTS `actualizarColumnaEdadd`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizarColumnaEdadd` ()   BEGIN
	DECLARE fecha DATE;
	DECLARE idusuario INT;
	DECLARE edadUsuario INT;
	
    	DECLARE fin INTEGER DEFAULT 0;
    
    	DECLARE calEdad CURSOR FOR SELECT id, fecha_de_nacimiento FROM usuario;
    
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET fin = 1;
    
	OPEN calEdad;
		nulo:LOOP
		
		FETCH calEdad INTO idusuario, fecha;

		IF fin = 1 THEN
			LEAVE nulo;
		END IF;

		SET edadUsuario = calcularEdad(fecha);

		UPDATE usuario SET edad = (fecha) WHERE id = idusuario;

	END LOOP; 
	CLOSE calEdad;
    
END$$

DROP PROCEDURE IF EXISTS `actualizarEdad`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizarEdad` ()   BEGIN
	DECLARE r_fnacimiento DATE;
	DECLARE r_idusuario INT;
	
    	/* Esta variable de "r_edadfinal" hara el calculo de la edad final.*/
	DECLARE r_edadfinal INT;
	
    	/* Este sera quien resguarde el cursor de algun error que suceda en caso de no encontrar datos. */
    	DECLARE fin INTEGER DEFAULT 0;
    
    	/* Declaro mi cursor, en el que recogerá el "idUser, fecha_nacimiento" de la tabla "edad". */
    	DECLARE calEdad CURSOR FOR SELECT idUser, fecha_nacimiento FROM edad;
    
    	/* Esta es una sentencia en donde se verifica si siguen encontrando datos, en caso de que no, se ha de cambiar el valor de la variable fin, haciendo que cierre el proceso debido.*/
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET fin = 1;
    
	/* Abro o Inicio el cursor */
	OPEN calEdad;
		proceso:LOOP
		
		/* Acá en el FETCH, es donde tomará los valores recogidos de "idUser, fecha_nacimiento" y los guardará en las variables correspondientes.*/
		FETCH calEdad INTO r_idusuario, r_fnacimiento;

		/* En éste IF, es donde se evalua lo anteriormente dicho sobre cerrar el proceso.*/
		IF fin = 1 THEN
			LEAVE proceso;
		END IF;

		/* Aquí es donde se realiza el calculo de la edad final, en el que sacamos el año del CURDATE y el año de r_fnacimiento, y se guarda en r_edadfinal. */
		SET r_edadfinal = calcularEdad(r_fnacimiento);

		/* Acá se hace la debida actualizacion de edad, en el que en la columna edad, insertamos el dato de r_edadfinal, y le colocamos de condicion el id del usuario al que le recogimos los datos.*/
		UPDATE edad SET edad = (r_edadfinal) WHERE idUser = r_idusuario;

	/* Cerramos el LOOP y el Cursor */
	END LOOP; 
	CLOSE calEdad;
    
    /* Y listo, asi tenemos la procedimiento de calcular edad con un cursor. */
END$$

DROP PROCEDURE IF EXISTS `CalcularNota`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CalcularNota` (IN `nota` FLOAT)   Begin 
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
end$$

DROP PROCEDURE IF EXISTS `cantidadProductos`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `cantidadProductos` (IN `Nombretipoproduc` VARCHAR(50), OUT `cantidad` INT)   begin 
	select count(*) into cantidad
    from productos, tipo_producto
    where tipo_producto.nombreTipoProducto = Nombretipoproduc
    and productos.idTipoProducto = tipo_producto.idTipoProducto;
end$$

DROP PROCEDURE IF EXISTS `listacorreo`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `listacorreo` (INOUT `emailList` VARCHAR(4000))   Begin	
	Declare finished integer default 0;
	Declare email varchar(100) default "";
    
    Declare curEmail 
		Cursor for 
			select cliente.correo from cliente;
   
	Declare continue handler 
       for not found set finished =1;
       
    Open curEmail;
    
    getEmail: loop
    Fetch curEmail into email;
    if finished = 1 then 
    leave getEmail;
    end if;
    
    set emailList = concat(email, ";", emailList);
    End loop getEmail;
    Close curEmail;
end$$

DROP PROCEDURE IF EXISTS `listaInventario`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `listaInventario` (INOUT `ProductInventa` VARCHAR(2000))   Begin	
    Declare fin integer default 0;
	Declare Cantidad int;
	Declare nombreProducto varchar(4000) default "";
    
    Declare cur
		Cursor for 
			select Inventario.cantidad,productos.nombreProducto from inventario join productos 
            on inventario.idProducto = productos.idProducto;
   
	Declare continue handler for not found set fin =1;
       
        Open cur;
    
    getInventa: loop
    Fetch cur into cantidad, nombreProducto;
    if fin = 1 then 
    leave getInventa;
    end if;
        
        set ProductInventa = Concat(nombreProducto, ";" ,cantidad, ";" ,ProductInventa);
        End loop getInventa;
		Close cur;
end$$

DROP PROCEDURE IF EXISTS `pais_sucursal`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `pais_sucursal` (IN `nombre` VARCHAR(50))   begin
select s.nombre, p.nombre ,s.direccion , c.nombre
from sucursal s, ciudad c, pais p
where p.nombre = nombre
and s.id_pais = 1
and c.id = s.id_ciudad;

end$$

DROP PROCEDURE IF EXISTS `preciosProductos`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `preciosProductos` (IN `Nombretipoproduc` VARCHAR(50), OUT `preciomax` DECIMAL(5,3), OUT `preciomin` DECIMAL(5,3), OUT `media` DECIMAL(5,3))   begin 
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
end$$

DROP PROCEDURE IF EXISTS `saludo`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `saludo` ()   begin
	select "hola mundo";
end$$

DROP PROCEDURE IF EXISTS `UsuarioContraseña`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `UsuarioContraseña` (IN `id` INT, IN `nombre` VARCHAR(45), IN `apellido` VARCHAR(45))   begin 
select concat(upper(substr(nombre,1,4)),upper(substr(apellido, 1,2)),substr(id, 1,3))"usuario",
concat(substr(id, 1,4),".",upper(substr(apellido, 1,2)))"contraseña";
end$$

--
-- Funciones
--
DROP FUNCTION IF EXISTS `calcularEdad`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `calcularEdad` (`fecha_nacimiento` DATE) RETURNS INT(11) DETERMINISTIC begin 
    declare edad int;
    select year(now()) - year(fecha_nacimiento) into edad;
    return edad;

end$$

DROP FUNCTION IF EXISTS `funcionIVA`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `funcionIVA` (`valor` DECIMAL(5,3)) RETURNS DECIMAL(5,3) DETERMINISTIC begin
   declare iva decimal (5,3);
   
    set iva  = valor * 1.19;
    return iva; 
end$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `audicliente`
--

DROP TABLE IF EXISTS `audicliente`;
CREATE TABLE `audicliente` (
  `idAudi` int(11) NOT NULL,
  `usuario` varchar(45) DEFAULT NULL,
  `fechaHora` datetime DEFAULT NULL,
  `accion` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `audicliente`
--

INSERT INTO `audicliente` (`idAudi`, `usuario`, `fechaHora`, `accion`) VALUES
(1, 'root@localhost', '2023-03-23 11:04:59', 'Se ingreso un nuevo cliente: Juan1123450087'),
(2, 'root@localhost', '2023-03-23 11:06:47', 'Se ingreso un nuevo cliente: MonicaCon Id:1022344532'),
(3, 'root@localhost', '2023-03-23 11:21:12', 'Se ingreso un nuevo cliente:  IsabelCon Id:  1134033122'),
(4, 'root@localhost', '2023-03-23 11:44:27', 'Se ingreso un nuevo cliente:  LuisCon Id:  1130877432'),
(5, 'root@localhost', '2023-03-23 11:46:46', 'Se ingreso un nuevo cliente:  LuisCon Id:  1130877432'),
(6, 'root@localhost', '2023-03-23 13:11:28', 'Se ingreso un nuevo cliente:  AngelCon Id:  1977087732'),
(7, 'root@localhost', '2023-03-23 13:20:22', 'Se ingreso un nuevo cliente:  MiguelCon Id:1033455432'),
(8, 'root@localhost', '2023-03-23 13:34:44', 'Se ingreso un nuevo cliente:  LuisaCon Id:223432122'),
(9, 'root@localhost', '2023-03-23 13:40:05', 'Se borro un cliente:  LuisaCon Id:223432122'),
(10, 'root@localhost', '2023-03-23 14:45:12', 'Se ingreso un nuevo cliente:  LuisaCon Id:223432122'),
(11, 'root@localhost', '2023-03-23 14:45:13', 'Se borro un cliente:  LuisaCon Id:223432122'),
(12, 'root@localhost', '2023-03-23 14:45:31', 'Se ingreso un nuevo cliente:  LuisaCon Id:223432122'),
(13, 'root@localhost', '2023-03-23 14:45:31', 'Se borro un cliente:  LuisaCon Id:223432122'),
(14, 'root@localhost', '2023-03-23 14:46:15', 'Se ingreso un nuevo cliente:  LuisaCon Id:223432122'),
(15, 'root@localhost', '2023-03-23 14:46:15', 'Se borro un cliente:  LuisaCon Id:223432122'),
(16, 'root@localhost', '2023-03-23 14:46:33', 'Se ingreso un nuevo cliente:  LuisaCon Id:223432122'),
(17, 'root@localhost', '2023-03-23 14:46:33', 'Se borro un cliente:  LuisaCon Id:223432122'),
(18, 'root@localhost', '2023-03-23 14:47:07', 'Se ingreso un nuevo cliente:  LuisaCon Id:223432122'),
(19, 'root@localhost', '2023-03-23 14:47:07', 'Se borro un cliente:  LuisaCon Id:223432122'),
(20, 'root@localhost', '2023-03-23 14:47:42', 'Se ingreso un nuevo cliente:  LuisaCon Id:223432122'),
(21, 'root@localhost', '2023-03-23 14:47:42', 'Se borro un cliente:  LuisaCon Id:223432122'),
(22, 'root@localhost', '2023-03-23 14:48:28', 'Se ingreso un nuevo cliente:  LuisaCon Id:223432122'),
(23, 'root@localhost', '2023-03-23 14:48:45', 'Se borro un cliente:  LuisaCon Id:223432122'),
(24, 'root@localhost', '2023-03-23 14:50:47', 'Se ingreso un nuevo cliente:  LuisaCon Id:223432122'),
(25, 'root@localhost', '2023-03-23 14:51:53', 'Se borro un cliente:  LuisaCon Id:223432122');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ciudad`
--

DROP TABLE IF EXISTS `ciudad`;
CREATE TABLE `ciudad` (
  `id` int(11) NOT NULL,
  `nombre` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `ciudad`
--

INSERT INTO `ciudad` (`id`, `nombre`) VALUES
(1, 'bogota'),
(2, 'medellin'),
(3, 'buenos aires'),
(4, 'rio de janerio '),
(5, 'lima');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cliente`
--

DROP TABLE IF EXISTS `cliente`;
CREATE TABLE `cliente` (
  `cedula` int(11) NOT NULL DEFAULT 0,
  `nombre` varchar(45) DEFAULT NULL,
  `puntos` int(11) DEFAULT NULL,
  `Correo` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `cliente`
--

INSERT INTO `cliente` (`cedula`, `nombre`, `puntos`, `Correo`) VALUES
(1002234571, 'Andres', 20, 'andi@gmail.com'),
(1022344532, 'Monica', 100, 'moni@hot.com'),
(1033455432, 'Miguel', 150, 'migue@gmail.com'),
(1033530200, 'Manuela', 50, 'mau@gmail.com'),
(1089965400, 'Ines', 10, 'Ines@gmail.com'),
(1123450087, 'Juan Felipe', 22, 'juan@fmail.com'),
(1130877432, 'Luis', 55, 'Luis@gmail.com'),
(1134033122, 'Isabel', 77, 'isa@gmail.com'),
(1977087732, 'Angel', 101, 'Angell@gmail.com');

--
-- Disparadores `cliente`
--
DROP TRIGGER IF EXISTS `borrarcliente`;
DELIMITER $$
CREATE TRIGGER `borrarcliente` AFTER DELETE ON `cliente` FOR EACH ROW begin 
   insert into audicliente (usuario,fechaHora,accion) 
   values (user(),now(),(concat('Se borro un cliente:  ',old.nombre,"", 'Con Id:', old.cedula)));
   
   end
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `nuevocliente`;
DELIMITER $$
CREATE TRIGGER `nuevocliente` AFTER INSERT ON `cliente` FOR EACH ROW begin 
   insert into audicliente (usuario,fechaHora,accion) 
   values (user(),now(),(concat('Se ingreso un nuevo cliente:  ',new.nombre,"", 'Con Id:', new.cedula)));
   
   end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `factura`
--

DROP TABLE IF EXISTS `factura`;
CREATE TABLE `factura` (
  `numeroFactura` int(11) NOT NULL DEFAULT 0,
  `idProducto` int(11) DEFAULT NULL,
  `idCliente` int(11) DEFAULT NULL,
  `cantidad` int(11) DEFAULT NULL,
  `fechaVenta` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `factura`
--

INSERT INTO `factura` (`numeroFactura`, `idProducto`, `idCliente`, `cantidad`, `fechaVenta`) VALUES
(10001, 101, 1002234571, 2, '2023-03-23 10:36:23');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `inventario`
--

DROP TABLE IF EXISTS `inventario`;
CREATE TABLE `inventario` (
  `idProducto` int(11) NOT NULL,
  `cantidad` int(11) DEFAULT NULL,
  `valor` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `inventario`
--

INSERT INTO `inventario` (`idProducto`, `cantidad`, `valor`) VALUES
(100, 54, 13990),
(101, 45, 2000);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pais`
--

DROP TABLE IF EXISTS `pais`;
CREATE TABLE `pais` (
  `id` int(11) NOT NULL,
  `nombre` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `pais`
--

INSERT INTO `pais` (`id`, `nombre`) VALUES
(1, 'colombia'),
(2, 'argentina'),
(3, 'brazil'),
(4, 'peru');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos`
--

DROP TABLE IF EXISTS `productos`;
CREATE TABLE `productos` (
  `idProducto` int(11) NOT NULL,
  `idTipoProducto` int(11) DEFAULT NULL,
  `nombreProducto` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `valor` decimal(5,3) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `productos`
--

INSERT INTO `productos` (`idProducto`, `idTipoProducto`, `nombreProducto`, `valor`) VALUES
(100, 1, 'Bandeja de carne de cerdo', 14.000),
(101, 2, 'Manzana', 2.000),
(111, 1, 'Bandeja Chorizo', 20.000),
(112, 1, 'Bandeja de pollo', 12.000);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sucursal`
--

DROP TABLE IF EXISTS `sucursal`;
CREATE TABLE `sucursal` (
  `id` int(11) NOT NULL,
  `nombre` varchar(45) DEFAULT NULL,
  `id_pais` int(11) DEFAULT NULL,
  `id_ciudad` int(11) DEFAULT NULL,
  `direccion` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `sucursal`
--

INSERT INTO `sucursal` (`id`, `nombre`, `id_pais`, `id_ciudad`, `direccion`) VALUES
(19, 'McDonald\'s', 1, 1, 'Cl 136 #18B-45'),
(20, 'McDonald\'s', 1, 2, 'Calle 39B, Cq. 73B #N° - 67'),
(21, 'McDonald\'s', 2, 3, 'Av. Córdoba 1765'),
(22, 'McDonald\'s', 4, 4, 'Edifício Empresarial Rio Branco'),
(23, 'McDonald\'s', 4, 5, 'Av. Oscar R. Benavides 140 Miraflores'),
(24, 'McDonald\'s', 1, 1, 'Cl. 118 # 7-76 ');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_producto`
--

DROP TABLE IF EXISTS `tipo_producto`;
CREATE TABLE `tipo_producto` (
  `idTipoProducto` int(11) NOT NULL DEFAULT 0,
  `nombreTipoProducto` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `tipo_producto`
--

INSERT INTO `tipo_producto` (`idTipoProducto`, `nombreTipoProducto`) VALUES
(1, 'Carnes'),
(2, 'Frutas'),
(3, 'Dulces'),
(4, 'verduras');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

DROP TABLE IF EXISTS `usuario`;
CREATE TABLE `usuario` (
  `id` int(11) NOT NULL,
  `nombre` varchar(45) DEFAULT NULL,
  `fecha_de_nacimiento` date DEFAULT NULL,
  `edad` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`id`, `nombre`, `fecha_de_nacimiento`, `edad`) VALUES
(1220, 'andrea suarez', '2001-02-11', 20010211),
(1333, 'marta cruz', '1986-10-18', 19861018),
(17820, 'felipe pliorez', '2003-01-11', 20030111),
(23220, 'juan camargo', '1999-09-01', 19990901);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `audicliente`
--
ALTER TABLE `audicliente`
  ADD PRIMARY KEY (`idAudi`);

--
-- Indices de la tabla `ciudad`
--
ALTER TABLE `ciudad`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`cedula`);

--
-- Indices de la tabla `factura`
--
ALTER TABLE `factura`
  ADD PRIMARY KEY (`numeroFactura`),
  ADD KEY `FK_PRODUCTO_idx` (`idProducto`),
  ADD KEY `FK_CLIENTE_idx` (`idCliente`);

--
-- Indices de la tabla `inventario`
--
ALTER TABLE `inventario`
  ADD PRIMARY KEY (`idProducto`);

--
-- Indices de la tabla `pais`
--
ALTER TABLE `pais`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `productos`
--
ALTER TABLE `productos`
  ADD PRIMARY KEY (`idProducto`),
  ADD KEY `FK_TIPOPRODUCTO_idx` (`idTipoProducto`);

--
-- Indices de la tabla `sucursal`
--
ALTER TABLE `sucursal`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_pais` (`id_pais`),
  ADD KEY `id_ciudad` (`id_ciudad`);

--
-- Indices de la tabla `tipo_producto`
--
ALTER TABLE `tipo_producto`
  ADD PRIMARY KEY (`idTipoProducto`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `audicliente`
--
ALTER TABLE `audicliente`
  MODIFY `idAudi` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT de la tabla `ciudad`
--
ALTER TABLE `ciudad`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `pais`
--
ALTER TABLE `pais`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `sucursal`
--
ALTER TABLE `sucursal`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `factura`
--
ALTER TABLE `factura`
  ADD CONSTRAINT `FK_CLIENTE` FOREIGN KEY (`idCliente`) REFERENCES `cliente` (`cedula`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_PRODUCTOFAC` FOREIGN KEY (`idProducto`) REFERENCES `productos` (`idProducto`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `inventario`
--
ALTER TABLE `inventario`
  ADD CONSTRAINT `FK_PRODUCTO` FOREIGN KEY (`idProducto`) REFERENCES `productos` (`idProducto`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `productos`
--
ALTER TABLE `productos`
  ADD CONSTRAINT `FK_TIPOPRODUCTO` FOREIGN KEY (`idTipoProducto`) REFERENCES `tipo_producto` (`idTipoProducto`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `sucursal`
--
ALTER TABLE `sucursal`
  ADD CONSTRAINT `sucursal_ibfk_1` FOREIGN KEY (`id_pais`) REFERENCES `pais` (`id`),
  ADD CONSTRAINT `sucursal_ibfk_2` FOREIGN KEY (`id_ciudad`) REFERENCES `ciudad` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
