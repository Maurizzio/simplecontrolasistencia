
DROP TABLE IF EXISTS sysasis_registro ;
DROP TABLE IF EXISTS sysasis_registro_huella ;
DROP TABLE IF EXISTS sysasis_enrolamiento_huella ;
DROP TABLE IF EXISTS sysasis_listado_huella;


DROP TABLE IF EXISTS sysasis_ubicacion ;

-- tabla de ubicaciones, registra las tiendas/galpones u oficinas en las que se labora de la organizacion
CREATE  TABLE  sysasis_ubicacion (
  cod_ubicacion VARCHAR(20) NOT NULL , -- codigo ubicacion de saint, generalmente el ubicacion
  ind_activo VARCHAR(1) NOT NULL DEFAULT 'S' , -- si esta habilitado es valido para usarse, sino ya no se fabrica
  des_ubicacion VARCHAR(80) NULL , -- abrebiatura del ubicacion (nombre de galpon/tienda)
  des_direccion VARCHAR(80) NULL , -- datos extras de tienda/galpon (misc)
--  cod_localidad VARCHAR(20) NULL , -- para futuro, reservado, sera el codigo de 3 letras de la zona
  fec_actualizacion DATE NULL , -- fecha en que se altero los datos de esta tabla por ultima vez
  cod_usuasys VARCHAR(20) NULL , -- codigo/usuario que altero los datos por ultima vez
  PRIMARY KEY (cod_ubicacion) );

DROP TABLE IF EXISTS sysasis_usuario ;

-- tabla de los usuarios, sean trabajadores o de sistema, ambos son usuarios, solo que trabajadores no tendran clave
CREATE TABLE sysasis_usuario
(
  cod_ficha VARCHAR(20) NOT NULL, -- para el futuro es apellido+inicialnombre (prietol)
  cod_cedula VARCHAR(20) NOT NULL, -- cedula/pasaporte del trabajador, debe existir y ser unico
  cod_perfil VARCHAR(20) NULL, -- para futuro perfil asociado
  cod_clave VARCHAR(20) NULL, -- para futuro, clave para iniciar session
  des_nombre VARCHAR(40) NOT NULL, -- nombre del trabajador
  des_apellido VARCHAR(40) NULL,
  ind_activo VARCHAR(1) NOT NULL DEFAULT 'S', -- si esta habilitado es trabajador activo, y puede crear aistencias
  fec_ingreso DATE NULL , -- fecha en que se ingreso en la empresa o se registro los datos
  fec_actualizacion DATE NULL , -- fecha en que se altero los datos de esta tabla por ultima vez
  cod_usuasys VARCHAR(20) NULL , -- codigo/usuario que altero los datos por ultima vez
  PRIMARY KEY (cod_ficha) );


-- tabla de registros del horario de trabajo, es usada para enviar a OP y registrar los horarios laborados
CREATE  TABLE  sysasis_registro (
  cod_ficha VARCHAR(20) NOT NULL , -- ficha/cedula/id del trabajador NOTA ESTE NO ES CI , en VNZ es CI
  cod_cedula VARCHAR(20) NOT NULL , -- cedula con nacionalidad y guin del trabajador, solo VNZ
  fec_registro DATE NOT NULL , -- fecha del registro de dia a laborar
  cod_ubicacion VARCHAR(20) NOT NULL , -- ubicacion (tienda) de su ultima actividad
  num_contador INTEGER NOT NULL DEFAULT 0, -- contador de fotos, si va a distintos lugares debe marcar salida
  horaentrada INTEGER NULL, -- hora de entrada del dia
  minuentrada INTEGER NULL, -- minuto de entrada en dicha hora
  horadescanso INTEGER NULL, -- hora de descanso del dia
  minudescanso INTEGER NULL, -- minuto de descanso en dicha respectiva hora
  horareincor INTEGER NULL, -- hora que se reincorpora del descanso
  minureincor INTEGER NULL, -- minuto de reincorporacion de dicha hora
  horasalida INTEGER NULL, -- hora de salida del dia laborado
  minusalida INTEGER NULL, -- minuto de salida de dich hora
  hex_huelladactilar BLOB NOT NULL , -- huella dactilar tomada
  fec_actualizacion DATE NULL , -- fecha en que se altero los datos de esta tabla por ultima vez
  cod_usuasys VARCHAR(20) NULL , -- codigo/usuario que altero los datos por ultima vez
  PRIMARY KEY (cod_ficha, fec_registro, cod_ubicacion) ,
  -- si el personal es muy movido, tendra registros en distintas ubicaciones, 
  -- el ubicacion ayuda a descartar duplicados. esto amerita tener un SP que maneje los datos
  -- la expotacio se realizara en un vista que colocara el calculo de las horas y  
  -- estos registros "dispersos" (ejemplo, entro en castellana, su primera salida debe ser de castellana antes de ir a otro lado)
  -- diferencia entre registro no puede ser menor a 1/3 hora y mayor a 6 horas CUANDO SEAN SELLOS DISTINTOS
  CONSTRAINT sysasis_usuario_registro
    FOREIGN KEY (cod_ficha )
    REFERENCES sysasis_usuario (cod_ficha ),
  CONSTRAINT sysasis_ubicacion_registro
    FOREIGN KEY (cod_ubicacion )
    REFERENCES sysasis_ubicacion (cod_ubicacion ) );



-- tabla de sistema, esta se borra en cada nuevo dia, y se repobla desde OP central
CREATE  TABLE  sysasis_listado_huella (
  cod_ficha VARCHAR(20) NOT NULL , -- ficha/cedula/id del trabajador NOTA ESTE NO ES CI , en VNZ es CI
  fec_registro DATE NOT NULL , -- fecha del registro de dia de su huella dactilar
  cod_ubicacion VARCHAR(20) NOT NULL , -- ubicacion (tienda) de su ultima actividad
  hex_huelladactilar BLOB NOT NULL , -- huella dactilar tomada
  fec_actualizacion DATE NULL , -- fecha en que se altero los datos de esta tabla por ultima vez
  cod_usuasys VARCHAR(20) NULL , -- codigo/usuario que altero los datos por ultima vez
  PRIMARY KEY (cod_ficha, fec_registro, cod_ubicacion, hex_huelladactilar) ,
  -- si el personal es muy movido, tendra registros en distintas ubicaciones, 
  -- el ubicacion ayuda a descartar duplicados. esto amerita tener un SP que maneje los datos
  CONSTRAINT sysasis_usuario_registro
    FOREIGN KEY (cod_ficha )
    REFERENCES sysasis_usuario (cod_ficha ),
  CONSTRAINT sysasis_ubicacion_registro
    FOREIGN KEY (cod_ubicacion )
    REFERENCES sysasis_ubicacion (cod_ubicacion ) );


-- tabla de registros locales de las huellas, usada para auditoria local unicamente
CREATE  TABLE  sysasis_enrolamiento_huella (
  cod_ficha VARCHAR(20) NOT NULL , -- ficha/cedula/id del trabajador NOTA ESTE NO ES CI , en VNZ es CI
  fec_registro DATE NOT NULL , -- fecha del registro de dia de su huella dactilar
  cod_ubicacion VARCHAR(20) NOT NULL , -- ubicacion (tienda) de su ultima actividad
  hex_huelladactilar BLOB NOT NULL , -- huella dactilar tomada
  fec_actualizacion DATE NULL , -- fecha en que se altero los datos de esta tabla por ultima vez
  cod_usuasys VARCHAR(20) NULL , -- codigo/usuario que altero los datos por ultima vez
  PRIMARY KEY (cod_ficha, fec_registro, cod_ubicacion, hex_huelladactilar) ,
  -- si el personal es muy movido, tendra registros en distintas ubicaciones, 
  -- el ubicacion ayuda a descartar duplicados. esto amerita tener un SP que maneje los datos
  CONSTRAINT sysasis_usuario_registro
    FOREIGN KEY (cod_ficha )
    REFERENCES sysasis_usuario (cod_ficha ),
  CONSTRAINT sysasis_ubicacion_registro
    FOREIGN KEY (cod_ubicacion )
    REFERENCES sysasis_ubicacion (cod_ubicacion ) );





DELETE FROM sysasis_registro;
DELETE FROM sysasis_ubicacion;
DELETE FROM sysasis_usuario;
DELETE FROM sysasis_enrolamiento_huella;



-- Data for Name: ubicacion; Type: TABLE DATA; Schema: public; Owner: postgres
INSERT INTO
  sysasis_ubicacion
  (cod_ubicacion, ind_activo, des_ubicacion, des_direccion, fec_actualizacion, cod_usuasys)
VALUES
  ('99', 'N', 'Computacion', 'Castellana?', NULL, NULL),
  ('CA', 'N', 'Castellana', 'Caracas distrito capital', NULL, NULL);

-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: postgres
INSERT INTO
  sysasis_usuario
  (cod_cedula, cod_ficha, cod_perfil, cod_clave, des_nombre, des_apellido, ind_activo, fec_ingreso, fec_actualizacion, cod_usuasys)
VALUES
  ('15616460', '15616460', NULL, '12345', 'tirano', 'Salazar', 'S', '2012-04-20T20:11:04', '2013-04-20T20:11:04', 'lenzg'),
  ('10255030', '10255030', NULL, '12345', 'Oscar', 'Marin', 'S', '2012-04-20T20:11:04', '2013-04-20T20:11:04', 'lenzg'),
  ('14912432', '14912432', NULL, '12345', 'Gerhard', 'Lenz', 'S', '2012-04-20T20:11:04', '2013-04-20T20:11:04', 'lenzg');

