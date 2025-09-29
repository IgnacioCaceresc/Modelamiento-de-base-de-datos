//------------------------CASO 1------------------------------------------//

-- Eliminar tablas si existen (orden inverso para evitar problemas con FK)
DROP TABLE DOMINIO CASCADE CONSTRAINTS;
DROP TABLE TITULACION CASCADE CONSTRAINTS;
DROP TABLE PERSONAL CASCADE CONSTRAINTS;
DROP TABLE TITULO CASCADE CONSTRAINTS;
DROP TABLE IDIOMA CASCADE CONSTRAINTS;
DROP TABLE GENERO CASCADE CONSTRAINTS;
DROP TABLE ESTADO_CIVIL CASCADE CONSTRAINTS;
DROP TABLE COMPANIA CASCADE CONSTRAINTS;
DROP TABLE COMUNA CASCADE CONSTRAINTS;
DROP TABLE REGION CASCADE CONSTRAINTS;


-- TABLAS FUERTES 


-- Tabla REGION
CREATE TABLE REGION (
    id_region NUMBER(2) GENERATED ALWAYS AS IDENTITY (START WITH 7 INCREMENT BY 2),
    nombre_region VARCHAR2(25) NOT NULL,
    CONSTRAINT REGION_PK PRIMARY KEY (id_region)
);

-- Tabla IDIOMA
CREATE TABLE IDIOMA (
    id_idioma NUMBER(3) GENERATED ALWAYS AS IDENTITY (START WITH 25 INCREMENT BY 3),
    nombre_idioma VARCHAR2(30) NOT NULL,
    CONSTRAINT IDIOMA_PK PRIMARY KEY (id_idioma)
);

-- Tabla TITULO
CREATE TABLE TITULO (
    id_titulo VARCHAR2(3),
    descripcion_titulo VARCHAR2(60) NOT NULL,
    CONSTRAINT TITULO_PK PRIMARY KEY (id_titulo)
);

-- Tabla GENERO
CREATE TABLE GENERO (
    id_genero VARCHAR2(3),
    descripcion_genero VARCHAR2(25) NOT NULL,
    CONSTRAINT GENERO_PK PRIMARY KEY (id_genero)
);

-- Tabla ESTADO_CIVIL
CREATE TABLE ESTADO_CIVIL (
    id_estado_civil VARCHAR2(2),
    descripcion_est_civil VARCHAR2(25) NOT NULL,
    CONSTRAINT ESTADO_CIVIL_PK PRIMARY KEY (id_estado_civil)
);


-- TABLAS CON DEPENDENCIAS 

-- Tabla COMUNA (depende de REGION)
CREATE TABLE COMUNA (
    id_comuna NUMBER(5),
    comuna_nombre VARCHAR2(25) NOT NULL,
    cod_region NUMBER(2) NOT NULL,
    CONSTRAINT COMUNA_PK PRIMARY KEY (id_comuna, cod_region),
    CONSTRAINT COMUNA_FK_REGION FOREIGN KEY (cod_region) 
        REFERENCES REGION(id_region)
);

-- Tabla COMPANIA (depende de COMUNA y REGION)
CREATE TABLE COMPANIA (
    id_empresa NUMBER(2),
    nombre_empresa VARCHAR2(25) NOT NULL,
    calle VARCHAR2(50),
    numeracion NUMBER,
    renta_promedio NUMBER(10),
    cod_aumento NUMBER(4,3),
    cod_comuna NUMBER(5) NOT NULL,
    cod_region NUMBER(2) NOT NULL,
    CONSTRAINT COMPANIA_PK PRIMARY KEY (id_empresa),
    CONSTRAINT COMPANIA_UN_NOMBRE_EMPRESA UNIQUE (nombre_empresa),
    CONSTRAINT COMPANIA_FK_COMUNA FOREIGN KEY (cod_comuna, cod_region) 
        REFERENCES COMUNA(id_comuna, cod_region)
);


-- TABLA PRINCIPAL (PERSONAL)

-- Tabla PERSONAL (depende de múltiples tablas)
CREATE TABLE PERSONAL (
    rut_persona NUMBER(8),
    dv_persona CHAR(1) NOT NULL,
    primer_nombre VARCHAR2(25) NOT NULL,
    segundo_nombre VARCHAR2(25),
    primer_apellido VARCHAR2(25) NOT NULL,
    segundo_apellido VARCHAR2(25),
    fecha_contratacion DATE NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    email VARCHAR2(100),
    calle VARCHAR2(50),
    numeracion NUMBER(5),
    sueldo NUMBER(5) NOT NULL,
    cod_comuna NUMBER(5) NOT NULL,
    cod_region NUMBER(2) NOT NULL,
    cod_genero VARCHAR2(3) NOT NULL,
    cod_estado_civil VARCHAR2(2) NOT NULL,
    cod_empresa NUMBER(2) NOT NULL,
    encargado_rut NUMBER(8),
    CONSTRAINT PERSONAL_PK PRIMARY KEY (rut_persona),
    CONSTRAINT PERSONAL_FK_COMPANIA FOREIGN KEY (cod_empresa) 
        REFERENCES COMPANIA(id_empresa),
    CONSTRAINT PERSONAL_FK_COMUNA FOREIGN KEY (cod_comuna, cod_region) 
        REFERENCES COMUNA(id_comuna, cod_region),
    CONSTRAINT PERSONAL_FK_ESTADO_CIVIL FOREIGN KEY (cod_estado_civil) 
        REFERENCES ESTADO_CIVIL(id_estado_civil),
    CONSTRAINT PERSONAL_FK_GENERO FOREIGN KEY (cod_genero) 
        REFERENCES GENERO(id_genero),
    CONSTRAINT PERSONAL_FK_PERSONAL FOREIGN KEY (encargado_rut) 
        REFERENCES PERSONAL(rut_persona)
);


-- TABLAS DE RELACIONES MUCHOS A MUCHOS

-- Tabla TITULACION (relaciona PERSONAL con TITULO)
CREATE TABLE TITULACION (
    cod_titulo VARCHAR2(3),
    persona_rut NUMBER(8),
    fecha_titulacion DATE NOT NULL,
    CONSTRAINT TITULACION_PK PRIMARY KEY (cod_titulo, persona_rut),
    CONSTRAINT TITULACION_FK_PERSONAL FOREIGN KEY (persona_rut) 
        REFERENCES PERSONAL(rut_persona),
    CONSTRAINT TITULACION_FK_TITULO FOREIGN KEY (cod_titulo) 
        REFERENCES TITULO(id_titulo)
);

-- Tabla DOMINIO (relaciona PERSONAL con IDIOMA)
CREATE TABLE DOMINIO (
    id_idioma NUMBER(3),
    persona_rut NUMBER(8),
    nivel VARCHAR2(25) NOT NULL,
    CONSTRAINT DOMINIO_PK PRIMARY KEY (id_idioma, persona_rut),
    CONSTRAINT DOMINIO_FK_IDIOMA FOREIGN KEY (id_idioma) 
        REFERENCES IDIOMA(id_idioma),
    CONSTRAINT DOMINIO_FK_PERSONAL FOREIGN KEY (persona_rut) 
        REFERENCES PERSONAL(rut_persona)
);

//------------------CASO 2-------------------------------------//

--MAIL SI BIEN ES OPCIONAL DEBE SER ÚNICO--

ALTER TABLE PERSONAL
ADD CONSTRAINT PERSONAL_UN_EMAIL UNIQUE (email);

--EL DIGITO VERIFICADOR DEBE ESTAR DENTRO DE LOS CARÁCTERES EN LISTADO--

ALTER TABLE PERSONAL
ADD CONSTRAINT PERSONAL_CK_DV_PERSONA 
CHECK (dv_persona IN ('0','1','2','3','4','5','6','7','8','9','K'));

--EL SUELDO MÍNIMO DE LOS EMPLEADOS NO PUEDE SER MENOR A 450.000 PESOS--

ALTER TABLE PERSONAL
ADD CONSTRAINT PERSONAL_CK_SUELDO_MINIMO 
CHECK (sueldo >= 450000);

//-------------------CASO 3---------------------------//

-- CREACIÓN DE SECUENCIAS

-- Secuencia para COMUNA (inicia en 1101, incremento 6)
DROP SEQUENCE SEQ_COMUNA;
CREATE SEQUENCE SEQ_COMUNA
START WITH 1101
INCREMENT BY 6
NOCACHE
NOCYCLE;

-- Secuencia para COMPANIA (inicia en 10, incremento 5)
DROP SEQUENCE SEQ_COMPANIA;
CREATE SEQUENCE SEQ_COMPANIA
START WITH 10
INCREMENT BY 5
NOCACHE
NOCYCLE;


-- POBLAMIENTO DE TABLAS


-- 1. TABLA REGION 

INSERT INTO REGION (nombre_region) VALUES ('ARICA Y PARINACOTA');
INSERT INTO REGION (nombre_region) VALUES ('METROPOLITANA');
INSERT INTO REGION (nombre_region) VALUES ('LA ARAUCANIA');


-- 2. TABLA IDIOMA 

INSERT INTO IDIOMA (nombre_idioma) VALUES ('Ingles');
INSERT INTO IDIOMA (nombre_idioma) VALUES ('Chino');
INSERT INTO IDIOMA (nombre_idioma) VALUES ('Aleman');
INSERT INTO IDIOMA (nombre_idioma) VALUES ('Espanol');
INSERT INTO IDIOMA (nombre_idioma) VALUES ('Frances');

-- 3. TABLA COMUNA (usa SEQUENCE)

-- Región: ARICA Y PARINACOTA (id_region = 7)
INSERT INTO COMUNA (id_comuna, comuna_nombre, cod_region) 
VALUES (SEQ_COMUNA.NEXTVAL, 'Arica', 7);

-- Región: METROPOLITANA (id_region = 9)
INSERT INTO COMUNA (id_comuna, comuna_nombre, cod_region) 
VALUES (SEQ_COMUNA.NEXTVAL, 'Santiago', 9);


-- Región: LA ARAUCANIA (id_region = 11)
INSERT INTO COMUNA (id_comuna, comuna_nombre, cod_region) 
VALUES (SEQ_COMUNA.NEXTVAL, 'Temuco', 11);

-- 4. TABLA COMPANIA 

-- Compañía 1: CC.VRojas
INSERT INTO COMPANIA (id_empresa, nombre_empresa, calle, numeracion, 
                      renta_promedio, cod_aumento, cod_comuna, cod_region)
VALUES (SEQ_COMPANIA.NEXTVAL, 'CC.VRojas', 'Amapolas', 506, 
        1857000, 0.5, 1101, 7);

-- Compañía 2: SELLER
INSERT INTO COMPANIA (id_empresa, nombre_empresa, calle, numeracion, 
                      renta_promedio, cod_aumento, cod_comuna, cod_region)
VALUES (SEQ_COMPANIA.NEXTVAL, 'SELLER', 'Los Alamos', 5490, 
        897000, 0.025, 1101, 7);

-- Compañía 3: Praxia LTDA
INSERT INTO COMPANIA (id_empresa, nombre_empresa, calle, numeracion, 
                      renta_promedio, cod_aumento, cod_comuna, cod_region)
VALUES (SEQ_COMPANIA.NEXTVAL, 'Praxia LTDA', 'Las Camelias', 11098, 
        2157000, 0.055, 1107, 9);

-- Compañía 4: TIC SPA
INSERT INTO COMPANIA (id_empresa, nombre_empresa, calle, numeracion, 
                      renta_promedio, cod_aumento, cod_comuna, cod_region)
VALUES (SEQ_COMPANIA.NEXTVAL, 'TIC SPA', 'FLORES S.A.', 4357, 
        857000, NULL, 1107, 9);

-- Compañía 5: INDUSTRIAL LTDA
INSERT INTO COMPANIA (id_empresa, nombre_empresa, calle, numeracion, 
                      renta_promedio, cod_aumento, cod_comuna, cod_region)
VALUES (SEQ_COMPANIA.NEXTVAL, 'INDUSTRIAL LTDA', 'AVDA PROVIDENCIA', 106, 
        757000, 0.015, 1107, 9);

-- Compañía 6: FLORES Y ASOCIADOS
INSERT INTO COMPANIA (id_empresa, nombre_empresa, calle, numeracion, 
                      renta_promedio, cod_aumento, cod_comuna, cod_region)
VALUES (SEQ_COMPANIA.NEXTVAL, 'FLORES Y ASOCIADOS', 'PEDRO LATORRE', 557, 
        585000, 0.015, 1107, 9);

-- Compañía 7: J. HOFFMAN
INSERT INTO COMPANIA (id_empresa, nombre_empresa, calle, numeracion, 
                      renta_promedio, cod_aumento, cod_comuna, cod_region)
VALUES (SEQ_COMPANIA.NEXTVAL, 'J. HOFFMAN', 'ARTURO P. 32', 309, 
        1857000, 0.025, 1113, 11);

-- Compañía 8: CAGLIARI D.
INSERT INTO COMPANIA (id_empresa, nombre_empresa, calle, numeracion, 
                      renta_promedio, cod_aumento, cod_comuna, cod_region)
VALUES (SEQ_COMPANIA.NEXTVAL, 'CAGLIARI D.', 'ALAMEDA', 206, 
        1857000, NULL, 1107, 9);

-- Compañía 9: Rojas HNOS LTDA
INSERT INTO COMPANIA (id_empresa, nombre_empresa, calle, numeracion, 
                      renta_promedio, cod_aumento, cod_comuna, cod_region)
VALUES (SEQ_COMPANIA.NEXTVAL, 'Rojas HNOS LTDA', 'SUCRE', 106, 
        957000, 0.005, 1113, 11);

-- Compañía 10: FRIENDS P. S.A
INSERT INTO COMPANIA (id_empresa, nombre_empresa, calle, numeracion, 
                      renta_promedio, cod_aumento, cod_comuna, cod_region)
VALUES (SEQ_COMPANIA.NEXTVAL, 'FRIENDS P. S.A', 'SUECIA', 506, 
        857000, 0.015, 1113, 11);

-- ============================================
-- CONFIRMACIÓN Y CONSULTAS DE VERIFICACIÓN
-- ============================================

COMMIT;

SELECT * FROM COMPANIA;

//------------------CASO 4------------------//
--INFORME N°1--
SELECT 
    nombre_empresa AS "Nombre Empresa",
    calle || '  ' || numeracion AS "Dirección",
    renta_promedio AS "Renta Promedio",
    CASE 
        WHEN cod_aumento IS NULL THEN NULL
        ELSE ROUND(renta_promedio * (1 + cod_aumento))
    END AS "Simulación de Renta"
FROM 
    COMPANIA
ORDER BY 
    renta_promedio DESC,
    nombre_empresa ASC;
    
    --INFORME N°2--
    
    SELECT 
    id_empresa AS "CODIGO",
    nombre_empresa AS "EMPRESA",
    renta_promedio AS "PROMEDIO RENTA ACTUAL",
    CASE 
        WHEN cod_aumento IS NULL THEN NULL
        ELSE ROUND(cod_aumento + 0.15, 3)
    END AS "PCT AUMENTADO EN 15%",
    CASE 
        WHEN cod_aumento IS NULL THEN NULL
        ELSE ROUND(renta_promedio * (1 + cod_aumento + 0.15))
    END AS "RENTA AUMENTADA"
FROM 
    COMPANIA
ORDER BY 
    renta_promedio ASC,
    nombre_empresa DESC;