---------------- CASO 1 ------------------------
---TABLAS FUERTES---
CREATE TABLE REGION (
    id_region NUMBER(4) PRIMARY KEY,
    nom_region VARCHAR2(255) NOT NULL
);

CREATE TABLE SALUD (
    id_salud NUMBER(4) PRIMARY KEY,
    nom_salud VARCHAR2(40) NOT NULL
);

CREATE TABLE AFP (
    id_afp NUMBER(4) PRIMARY KEY,
    nom_afp VARCHAR2(40) NOT NULL
);

CREATE TABLE COMUNA (
    cod_comuna NUMBER(5) PRIMARY KEY,
    nombre_comuna VARCHAR2(100) NOT NULL,
    id_region NUMBER(4) NOT NULL,
    CONSTRAINT fk_comuna_region FOREIGN KEY (id_region) REFERENCES REGION(id_region)
);

CREATE TABLE MARCA (
    id_marca NUMBER(3) PRIMARY KEY,
    nombre_marca VARCHAR2(25) NOT NULL
);

CREATE TABLE CATEGORIA (
    id_categoria NUMBER(3) PRIMARY KEY,
    nombre_categoria VARCHAR2(255) NOT NULL
);

CREATE TABLE MEDIO_PAGO (
    id_medio_pago NUMBER(3) PRIMARY KEY,
    nombre_medio VARCHAR2(50) NOT NULL
);

CREATE TABLE PROVEEDOR (
    id_proveedor NUMBER(5) PRIMARY KEY,
    nombre_proveedor VARCHAR2(150) NOT NULL,
    rut_proveedor VARCHAR2(10) NOT NULL UNIQUE,
    telefono VARCHAR2(20),
    email VARCHAR2(200),
    direccion VARCHAR2(200),
    cod_comuna NUMBER(5) NOT NULL,
    CONSTRAINT fk_proveedor_comuna FOREIGN KEY (cod_comuna) REFERENCES COMUNA(cod_comuna)
);

--- TABLAS DEBILES ---
CREATE TABLE EMPLEADO (
    id_empleado NUMBER(4) PRIMARY KEY,
    rut_empleado VARCHAR2(100) NOT NULL UNIQUE,
    nombre_empleado VARCHAR2(25) NOT NULL,
    ape_paterno VARCHAR2(25) NOT NULL,
    ape_materno VARCHAR2(25) NOT NULL,
    fecha_contratacion DATE NOT NULL,
    sueldo_base NUMBER(10) NOT NULL,
    bono_jefatura NUMBER(10),
    activo CHAR(1) NOT NULL CHECK (activo IN ('S','N')),
    tipo_empleado VARCHAR2(25) NOT NULL,
    cod_jefe NUMBER(4),
    cod_salud NUMBER(4) NOT NULL,
    cod_afp NUMBER(4) NOT NULL,
    CONSTRAINT fk_empleado_salud FOREIGN KEY (cod_salud) REFERENCES SALUD(id_salud),
    CONSTRAINT fk_empleado_afp FOREIGN KEY (cod_afp) REFERENCES AFP(id_afp),
    CONSTRAINT fk_empleado_jefe FOREIGN KEY (cod_jefe) REFERENCES EMPLEADO(id_empleado)
);


CREATE TABLE ADMINISTRATIVO (
    id_empleado NUMBER(4) PRIMARY KEY,
    departamento VARCHAR2(50),
    CONSTRAINT fk_administrativo_empleado FOREIGN KEY (id_empleado) REFERENCES EMPLEADO(id_empleado)
);

CREATE TABLE VENDEDOR (
    id_empleado NUMBER(4) PRIMARY KEY,
    comision_venta NUMBER(5,2) NOT NULL,
    CONSTRAINT fk_vendedor_empleado FOREIGN KEY (id_empleado) REFERENCES EMPLEADO(id_empleado)
);


CREATE TABLE PRODUCTO (
    id_producto NUMBER(4) PRIMARY KEY,
    nombre_producto VARCHAR2(100) NOT NULL,
    unidad_venta VARCHAR2(50) NOT NULL,
    origen_nacional CHAR(1) NOT NULL CHECK (origen_nacional IN ('S','N')),
    stock_minimo NUMBER(3) NOT NULL,
    precio_compra NUMBER(10,2) NOT NULL,
    precio_venta NUMBER(10,2) NOT NULL,
    cod_marca NUMBER(3) NOT NULL,
    cod_categoria NUMBER(3) NOT NULL,
    cod_proveedor NUMBER(5) NOT NULL,
    CONSTRAINT fk_producto_marca FOREIGN KEY (cod_marca) REFERENCES MARCA(id_marca),
    CONSTRAINT fk_producto_categoria FOREIGN KEY (cod_categoria) REFERENCES CATEGORIA(id_categoria),
    CONSTRAINT fk_producto_proveedor FOREIGN KEY (cod_proveedor) REFERENCES PROVEEDOR(id_proveedor)
);


CREATE TABLE VENTA (
    id_venta NUMBER(4) GENERATED ALWAYS AS IDENTITY START WITH 5050 INCREMENT BY 3 PRIMARY KEY,
    fecha_venta DATE NOT NULL,
    total_venta NUMBER(10,2) NOT NULL,
    cod_medio_pago NUMBER(3) NOT NULL,
    cod_empleado NUMBER(4) NOT NULL,
    CONSTRAINT fk_venta_medio_pago FOREIGN KEY (cod_medio_pago) REFERENCES MEDIO_PAGO(id_medio_pago),
    CONSTRAINT fk_venta_empleado FOREIGN KEY (cod_empleado) REFERENCES EMPLEADO(id_empleado)
);


CREATE TABLE DETALLE_VENTA (
    cod_venta NUMBER(4),
    cod_producto NUMBER(4),
    cantidad NUMBER(6) NOT NULL,
    precio_unitario NUMBER(10,2) NOT NULL,
    subtotal NUMBER(10,2) NOT NULL,
    PRIMARY KEY (cod_venta, cod_producto),
    CONSTRAINT fk_detalle_venta FOREIGN KEY (cod_venta) REFERENCES VENTA(id_venta),
    CONSTRAINT fk_detalle_producto FOREIGN KEY (cod_producto) REFERENCES PRODUCTO(id_producto)
);


CREATE TABLE COMPRA (
    id_compra NUMBER(4) PRIMARY KEY,
    fecha_compra DATE NOT NULL,
    total_compra NUMBER(10,2) NOT NULL,
    estado_pago CHAR(1) NOT NULL CHECK (estado_pago IN ('P','C')), -- P=Pendiente, C=Pagado
    cod_proveedor NUMBER(5) NOT NULL,
    cod_medio_pago NUMBER(3) NOT NULL,
    CONSTRAINT fk_compra_proveedor FOREIGN KEY (cod_proveedor) REFERENCES PROVEEDOR(id_proveedor),
    CONSTRAINT fk_compra_medio_pago FOREIGN KEY (cod_medio_pago) REFERENCES MEDIO_PAGO(id_medio_pago)
);


CREATE TABLE DETALLE_COMPRA (
    cod_compra NUMBER(4),
    cod_producto NUMBER(4),
    cantidad NUMBER(6) NOT NULL,
    precio_compra NUMBER(10,2) NOT NULL,
    subtotal NUMBER(10,2) NOT NULL,
    PRIMARY KEY (cod_compra, cod_producto),
    CONSTRAINT fk_detalle_compra FOREIGN KEY (cod_compra) REFERENCES COMPRA(id_compra),
    CONSTRAINT fk_detalle_compra_producto FOREIGN KEY (cod_producto) REFERENCES PRODUCTO(id_producto)
);


CREATE TABLE INVENTARIO (
    id_inventario NUMBER(4) PRIMARY KEY,
    cod_producto NUMBER(4) NOT NULL,
    stock_actual NUMBER(6) NOT NULL,
    stock_minimo NUMBER(6) NOT NULL,
    fecha_actualizacion DATE NOT NULL,
    CONSTRAINT fk_inventario_producto FOREIGN KEY (cod_producto) REFERENCES PRODUCTO(id_producto)
);

--------------------- CASO 2 -------------------------

-- 1. Restricción CHECK para sueldo base mínimo en EMPLEADO
ALTER TABLE EMPLEADO 
ADD CONSTRAINT ck_empleado_sueldo_minimo 
CHECK (sueldo_base >= 400000);

-- 2. Restricción CHECK para comisión de vendedor en VENDEDOR
ALTER TABLE VENDEDOR 
ADD CONSTRAINT ck_vendedor_comision 
CHECK (comision_venta BETWEEN 0 AND 0.25);

-- 3. Restricción CHECK para stock mínimo en PRODUCTO
ALTER TABLE PRODUCTO 
ADD CONSTRAINT ck_producto_stock_minimo 
CHECK (stock_minimo >= 3);

-- 4. Restricción UNIQUE para email único en PROVEEDOR
ALTER TABLE PROVEEDOR 
ADD CONSTRAINT un_proveedor_email 
UNIQUE (email);

-- 5. Restricción UNIQUE para nombre único en MARCA
ALTER TABLE MARCA 
ADD CONSTRAINT un_marca_nombre 
UNIQUE (nombre_marca);

-- 6. Restricción CHECK para cantidad positiva en DETALLE_VENTA
ALTER TABLE DETALLE_VENTA 
ADD CONSTRAINT ck_detalle_venta_cantidad 
CHECK (cantidad > 0);

COMMIT;

---------------- CASO 3 -------------------

-- =============================================
-- CREACIÓN DE SECUENCIAS
-- =============================================

-- Secuencia para SALUD (inicia en 2050, incrementa en 10)
CREATE SEQUENCE seq_salud
    START WITH 2050
    INCREMENT BY 10
    NOCACHE
    NOCYCLE;

-- Secuencia para EMPLEADO (inicia en 750, incrementa en 3)
CREATE SEQUENCE seq_empleado
    START WITH 750
    INCREMENT BY 3
    NOCACHE
    NOCYCLE;

COMMIT;

---Poblar tabla AFP
INSERT INTO AFP (id_afp, nom_afp) VALUES (210, 'AFP Habitat');
INSERT INTO AFP (id_afp, nom_afp) VALUES (216, 'AFP Cuprum');
INSERT INTO AFP (id_afp, nom_afp) VALUES (222, 'AFP Provida');
INSERT INTO AFP (id_afp, nom_afp) VALUES (228, 'AFP PlanVital');

COMMIT;

---Poblar tabla PREVISION_SALUD
INSERT INTO SALUD (id_salud, nom_salud) VALUES (2050, 'Fonasa');
INSERT INTO SALUD (id_salud, nom_salud) VALUES (2060, 'Isapre Colmena');
INSERT INTO SALUD (id_salud, nom_salud) VALUES (2070, 'Isapre Banmédica');
INSERT INTO SALUD (id_salud, nom_salud) VALUES (2080, 'Isapre Cruz Blanca');

COMMIT;

---Poblar tabla MEDIO_PAGO
INSERT INTO MEDIO_PAGO (id_medio_pago, nombre_medio) VALUES (11, 'Efectivo');
INSERT INTO MEDIO_PAGO (id_medio_pago, nombre_medio) VALUES (12, 'Tarjeta Débito');
INSERT INTO MEDIO_PAGO (id_medio_pago, nombre_medio) VALUES (13, 'Tarjeta Crédito');
INSERT INTO MEDIO_PAGO (id_medio_pago, nombre_medio) VALUES (14, 'Cheque');

COMMIT;

--Poblar tabla REGION
INSERT INTO REGION (id_region, nom_region) VALUES (1, 'Region Metropolitana');
INSERT INTO REGION (id_region, nom_region) VALUES (2, 'Valparaiso');
INSERT INTO REGION (id_region, nom_region) VALUES (3, 'Biobio');
INSERT INTO REGION (id_region, nom_region) VALUES (4, 'Los Lagos');

COMMIT;

--Poblar tabla EMPLEADO
-- Empleado 1: Marcela Gonzalez Pérez
INSERT INTO EMPLEADO (id_empleado, rut_empleado, nombre_empleado, ape_paterno, ape_materno, 
                     fecha_contratacion, sueldo_base, bono_jefatura, activo, tipo_empleado, 
                     cod_jefe, cod_salud, cod_afp) 
VALUES (750, '11111111-1', 'Marcela', 'Gonzalez', 'Pérez', 
        TO_DATE('15-03-2022', 'DD-MM-YYYY'), 950000, 80000, 'S', 'Administrativo', 
        NULL, 2050, 210);

-- Empleado 2: José Muñoz Ramirez
INSERT INTO EMPLEADO (id_empleado, rut_empleado, nombre_empleado, ape_paterno, ape_materno, 
                     fecha_contratacion, sueldo_base, bono_jefatura, activo, tipo_empleado, 
                     cod_jefe, cod_salud, cod_afp) 
VALUES (753, '22222222-2', 'José', 'Muñoz', 'Ramirez', 
        TO_DATE('10-07-2021', 'DD-MM-YYYY'), 900000, 75000, 'S', 'Administrativo', 
        NULL, 2060, 216);

-- Empleado 3: Veronica Soto Alarcón
INSERT INTO EMPLEADO (id_empleado, rut_empleado, nombre_empleado, ape_paterno, ape_materno, 
                     fecha_contratacion, sueldo_base, bono_jefatura, activo, tipo_empleado, 
                     cod_jefe, cod_salud, cod_afp) 
VALUES (756, '33333333-3', 'Veronica', 'Soto', 'Alarcón', 
        TO_DATE('05-01-2020', 'DD-MM-YYYY'), 880000, 70000, 'S', 'Vendedor', 
        750, 2060, 222);  

-- Empleado 4: Luis Reyes Fuentes
INSERT INTO EMPLEADO (id_empleado, rut_empleado, nombre_empleado, ape_paterno, ape_materno, 
                     fecha_contratacion, sueldo_base, bono_jefatura, activo, tipo_empleado, 
                     cod_jefe, cod_salud, cod_afp) 
VALUES (759, '44444444-4', 'Luis', 'Reyes', 'Fuentes', 
        TO_DATE('01-04-2023', 'DD-MM-YYYY'), 560000, NULL, 'S', 'Vendedor', 
        750, 2070, 222);

-- Empleado 5: Claudia Fernandez Lagos
INSERT INTO EMPLEADO (id_empleado, rut_empleado, nombre_empleado, ape_paterno, ape_materno, 
                     fecha_contratacion, sueldo_base, bono_jefatura, activo, tipo_empleado, 
                     cod_jefe, cod_salud, cod_afp) 
VALUES (762, '55555555-5', 'Claudia', 'Fernandez', 'Lagos', 
        TO_DATE('15-04-2023', 'DD-MM-YYYY'), 600000, NULL, 'S', 'Vendedor', 
        753, 2070, 216);

-- Empleado 6: Carlos Navarro Vega
INSERT INTO EMPLEADO (id_empleado, rut_empleado, nombre_empleado, ape_paterno, ape_materno, 
                     fecha_contratacion, sueldo_base, bono_jefatura, activo, tipo_empleado, 
                     cod_jefe, cod_salud, cod_afp) 
VALUES (765, '66666666-6', 'Carlos', 'Navarro', 'Vega', 
        TO_DATE('01-05-2023', 'DD-MM-YYYY'), 610000, NULL, 'S', 'Administrativo', 
        753, 2060, 210);

-- Empleado 7: Javiera Pino Rojas
INSERT INTO EMPLEADO (id_empleado, rut_empleado, nombre_empleado, ape_paterno, ape_materno, 
                     fecha_contratacion, sueldo_base, bono_jefatura, activo, tipo_empleado, 
                     cod_jefe, cod_salud, cod_afp) 
VALUES (768, '77777777-7', 'Javiera', 'Pino', 'Rojas', 
        TO_DATE('10-05-2023', 'DD-MM-YYYY'), 650000, NULL, 'S', 'Administrativo', 
        750, 2050, 210);

-- Empleado 8: Diego Mella Contreras
INSERT INTO EMPLEADO (id_empleado, rut_empleado, nombre_empleado, ape_paterno, ape_materno, 
                     fecha_contratacion, sueldo_base, bono_jefatura, activo, tipo_empleado, 
                     cod_jefe, cod_salud, cod_afp) 
VALUES (771, '88888888-8', 'Diego', 'Mella', 'Contreras', 
        TO_DATE('12-05-2023', 'DD-MM-YYYY'), 620000, NULL, 'S', 'Vendedor', 
        750, 2060, 216);

-- Empleado 9: Fernanda Salas Herrera
INSERT INTO EMPLEADO (id_empleado, rut_empleado, nombre_empleado, ape_paterno, ape_materno, 
                     fecha_contratacion, sueldo_base, bono_jefatura, activo, tipo_empleado, 
                     cod_jefe, cod_salud, cod_afp) 
VALUES (774, '99999999-9', 'Fernanda', 'Salas', 'Herrera', 
        TO_DATE('18-05-2023', 'DD-MM-YYYY'), 570000, NULL, 'S', 'Vendedor', 
        753, 2070, 222);

-- Empleado 10: Tomas Vidal Espinoza
INSERT INTO EMPLEADO (id_empleado, rut_empleado, nombre_empleado, ape_paterno, ape_materno, 
                     fecha_contratacion, sueldo_base, bono_jefatura, activo, tipo_empleado, 
                     cod_jefe, cod_salud, cod_afp) 
VALUES (777, '10101010-0', 'Tomas', 'Vidal', 'Espinoza', 
        TO_DATE('01-06-2023', 'DD-MM-YYYY'), 530000, NULL, 'S', 'Vendedor', 
        NULL, 2060, 222);
        
COMMIT;        

---Poblar tabla VENTA
INSERT INTO VENTA (fecha_venta, total_venta, cod_medio_pago, cod_empleado) 
VALUES (TO_DATE('12-05-2023', 'DD-MM-YYYY'), 225990, 12, 771);

INSERT INTO VENTA (fecha_venta, total_venta, cod_medio_pago, cod_empleado) 
VALUES (TO_DATE('23-10-2023', 'DD-MM-YYYY'), 524990, 13, 777);

INSERT INTO VENTA (fecha_venta, total_venta, cod_medio_pago, cod_empleado) 
VALUES (TO_DATE('17-02-2023', 'DD-MM-YYYY'), 466990, 11, 759);

COMMIT;

---------------------- CASO 4 ----------------------
---Informe N°1

SELECT 
    id_empleado AS "IDENTIFICADOR",
    nombre_empleado || ' ' || ape_paterno || ' ' || ape_materno AS "NOMBRE COMPLETO",
    sueldo_base AS "SALARIO",
    bono_jefatura AS "BONIFICACION",
    (sueldo_base + bono_jefatura) AS "SALARIO SIMULADO"
FROM EMPLEADO
WHERE activo = 'S' 
    AND bono_jefatura IS NOT NULL
ORDER BY 
    "SALARIO SIMULADO" DESC,
    ape_paterno DESC;


---Informe N°2

SELECT 
    nombre_empleado || ' ' || ape_paterno || ' ' || ape_materno AS "EMPLEADO",
    sueldo_base AS "SUELDO",
    (sueldo_base * 0.08) AS "POSIBLE AUMENTO",
    (sueldo_base * 1.08) AS "SALARIO SIMULADO"
FROM EMPLEADO
WHERE sueldo_base BETWEEN 550000 AND 800000
    AND activo = 'S'
ORDER BY sueldo_base ASC;

















































