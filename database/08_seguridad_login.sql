CREATE TABLE seguridad.categoria_usuario (
    categoria_usuario_id BIGINT GENERATED ALWAYS AS IDENTITY,
    codigo VARCHAR(50) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(300),
    activa BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_categoria_usuario
        PRIMARY KEY (categoria_usuario_id),

    CONSTRAINT uq_categoria_usuario_codigo
        UNIQUE (codigo),

    CONSTRAINT uq_categoria_usuario_nombre
        UNIQUE (nombre)
);


CREATE TABLE seguridad.usuario (
    usuario_id BIGINT GENERATED ALWAYS AS IDENTITY,
    categoria_usuario_id BIGINT NOT NULL,

    nombre VARCHAR(150) NOT NULL,

    correo VARCHAR(150) NOT NULL,
    correo_normalizado VARCHAR(150) NOT NULL,

    password_hash VARCHAR(500) NOT NULL,

    activa BOOLEAN NOT NULL DEFAULT TRUE,

    ultimo_acceso_en TIMESTAMPTZ,

    creado_en TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_usuario
        PRIMARY KEY (usuario_id),

    CONSTRAINT fk_usuario_categoria
        FOREIGN KEY (categoria_usuario_id)
        REFERENCES seguridad.categoria_usuario(categoria_usuario_id),

    CONSTRAINT uq_usuario_correo
        UNIQUE (correo_normalizado)
);


CREATE TABLE seguridad.permiso (
    permiso_id BIGINT GENERATED ALWAYS AS IDENTITY,
    codigo VARCHAR(100) NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    modulo VARCHAR(50) NOT NULL,
    descripcion VARCHAR(300),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_permiso
        PRIMARY KEY (permiso_id),

    CONSTRAINT uq_permiso_codigo
        UNIQUE (codigo)
);

CREATE TABLE seguridad.rol (
    rol_id BIGINT GENERATED ALWAYS AS IDENTITY,

    empresa_id BIGINT,

    codigo VARCHAR(50) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(300),

    es_global BOOLEAN NOT NULL DEFAULT FALSE,
    activo BOOLEAN NOT NULL DEFAULT TRUE,

    creado_en TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_rol
        PRIMARY KEY (rol_id),

    CONSTRAINT fk_rol_empresa
        FOREIGN KEY (empresa_id)
        REFERENCES configuracion.empresa(empresa_id),

    CONSTRAINT ck_rol_alcance
        CHECK (
            (es_global = TRUE AND empresa_id IS NULL)
            OR
            (es_global = FALSE AND empresa_id IS NOT NULL)
        )
);



CREATE TABLE seguridad.rol_permiso (
    rol_id BIGINT NOT NULL,
    permiso_id BIGINT NOT NULL,
    creado_en TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_rol_permiso
        PRIMARY KEY (rol_id, permiso_id),

    CONSTRAINT fk_rol_permiso_rol
        FOREIGN KEY (rol_id)
        REFERENCES seguridad.rol(rol_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_rol_permiso_permiso
        FOREIGN KEY (permiso_id)
        REFERENCES seguridad.permiso(permiso_id)
        ON DELETE CASCADE
);

--Esta tabla responde:

--¿A qué empresas tiene acceso este usuario?

CREATE TABLE seguridad.usuario_empresa (
    usuario_empresa_id BIGINT GENERATED ALWAYS AS IDENTITY,

    usuario_id BIGINT NOT NULL,
    empresa_id BIGINT NOT NULL,

    es_principal BOOLEAN NOT NULL DEFAULT FALSE,
    activo BOOLEAN NOT NULL DEFAULT TRUE,

    creado_en TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_usuario_empresa
        PRIMARY KEY (usuario_empresa_id),

    CONSTRAINT fk_usuario_empresa_usuario
        FOREIGN KEY (usuario_id)
        REFERENCES seguridad.usuario(usuario_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_usuario_empresa_empresa
        FOREIGN KEY (empresa_id)
        REFERENCES configuracion.empresa(empresa_id),

    CONSTRAINT uq_usuario_empresa
        UNIQUE (usuario_id, empresa_id)
);


--Ahora necesitamos responder:

--¿Qué rol tiene este usuario dentro de esa empresa?

--Y por eso relacionamos el rol con usuario_empresa, no directamente con usuario.

CREATE TABLE seguridad.usuario_empresa_rol (
    usuario_empresa_rol_id BIGINT GENERATED ALWAYS AS IDENTITY,


    usuario_empresa_id BIGINT NOT NULL,
    rol_id BIGINT NOT NULL,


    activo BOOLEAN NOT NULL DEFAULT TRUE,


    creado_en TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,


    CONSTRAINT pk_usuario_empresa_rol
        PRIMARY KEY (usuario_empresa_rol_id),


    CONSTRAINT fk_usuario_empresa_rol_usuario_empresa
        FOREIGN KEY (usuario_empresa_id)
        REFERENCES seguridad.usuario_empresa(usuario_empresa_id)
        ON DELETE CASCADE,


    CONSTRAINT fk_usuario_empresa_rol_rol
        FOREIGN KEY (rol_id)
        REFERENCES seguridad.rol(rol_id)
        ON DELETE CASCADE,


    CONSTRAINT uq_usuario_empresa_rol
        UNIQUE (usuario_empresa_id, rol_id)
);


CREATE TABLE seguridad.usuario_rol (
    usuario_rol_id BIGINT GENERATED ALWAYS AS IDENTITY,

    usuario_id BIGINT NOT NULL,
    rol_id BIGINT NOT NULL,

    activo BOOLEAN NOT NULL DEFAULT TRUE,

    creado_en TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_usuario_rol
        PRIMARY KEY (usuario_rol_id),

    CONSTRAINT fk_usuario_rol_usuario
        FOREIGN KEY (usuario_id)
        REFERENCES seguridad.usuario(usuario_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_usuario_rol_rol
        FOREIGN KEY (rol_id)
        REFERENCES seguridad.rol(rol_id)
        ON DELETE CASCADE,

    CONSTRAINT uq_usuario_rol
        UNIQUE (usuario_id, rol_id)
);