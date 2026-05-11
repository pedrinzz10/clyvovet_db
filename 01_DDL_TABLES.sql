-- ============================================================
-- CLYVO VET -- BANCO DE DADOS ORACLE
-- Arquivo 01: DDL -- Criacao das Tabelas
-- Schema alinhado com entidades Java (UUID como PK VARCHAR2(36))
-- ============================================================

-- Funcao auxiliar: gera UUID padrao (8-4-4-4-12)
-- compativel com java.util.UUID.randomUUID().toString()
CREATE OR REPLACE FUNCTION fn_uuid RETURN VARCHAR2 IS
BEGIN
    RETURN LOWER(REGEXP_REPLACE(
        RAWTOHEX(SYS_GUID()),
        '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})',
        '\1-\2-\3-\4-\5'
    ));
END fn_uuid;
/

-- Sequence apenas para tb_log_erros (tabela de sistema interna)
CREATE SEQUENCE seq_log_erros START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

-- ============================================================
-- TABELA DE LOG DE ERROS (exigida pelo professor)
-- ============================================================
CREATE TABLE tb_log_erros (
    id              NUMBER        DEFAULT seq_log_erros.NEXTVAL PRIMARY KEY,
    nome_procedure  VARCHAR2(100) NOT NULL,
    nome_usuario    VARCHAR2(100) DEFAULT USER,
    data_erro       TIMESTAMP     DEFAULT SYSTIMESTAMP,
    codigo_erro     NUMBER,
    mensagem_erro   VARCHAR2(4000)
);

-- ============================================================
-- 1. TUTOR
-- sexo: salvo como nome do enum Java (MASCULINO/FEMININO/OUTRO)
-- ============================================================
CREATE TABLE tutor (
    id              VARCHAR2(36)  DEFAULT fn_uuid() PRIMARY KEY,
    cpf             VARCHAR2(11),
    nome            VARCHAR2(150) NOT NULL,
    data_nascimento DATE,
    sexo            VARCHAR2(10),
    email           VARCHAR2(200),
    telefone        VARCHAR2(20),
    logradouro      VARCHAR2(300),
    numero          VARCHAR2(10),
    bairro          VARCHAR2(150),
    cidade          VARCHAR2(100),
    estado          VARCHAR2(50),
    cep             VARCHAR2(10),
    CONSTRAINT uk_tutor_cpf   UNIQUE (cpf),
    CONSTRAINT uk_tutor_email UNIQUE (email),
    CONSTRAINT chk_tutor_sexo CHECK (sexo IN ('MASCULINO','FEMININO','OUTRO'))
);

-- ============================================================
-- 2. ANIMAL
-- ============================================================
CREATE TABLE animal (
    id               VARCHAR2(36)  DEFAULT fn_uuid() PRIMARY KEY,
    nome             VARCHAR2(100) NOT NULL,
    raca             VARCHAR2(100),
    especie          VARCHAR2(50),
    porte            VARCHAR2(20),
    cor              VARCHAR2(80),
    sexo             VARCHAR2(10),
    data_nascimento  DATE,
    observacao       VARCHAR2(1000),
    tutor_id         VARCHAR2(36),
    CONSTRAINT fk_animal_tutor  FOREIGN KEY (tutor_id) REFERENCES tutor(id),
    CONSTRAINT chk_animal_porte CHECK (porte   IN ('PEQUENO','MEDIO','GRANDE')),
    CONSTRAINT chk_animal_sexo  CHECK (sexo    IN ('MACHO','FEMEA','DESCONHECIDO'))
);

-- ============================================================
-- 3. CLINICA
-- ============================================================
CREATE TABLE clinica (
    id         VARCHAR2(36)  DEFAULT fn_uuid() PRIMARY KEY,
    nome       VARCHAR2(200) NOT NULL,
    cnpj       VARCHAR2(14),
    telefone   VARCHAR2(20),
    email      VARCHAR2(200),
    logradouro VARCHAR2(300),
    numero     VARCHAR2(10),
    bairro     VARCHAR2(150),
    cidade     VARCHAR2(100),
    estado     VARCHAR2(50),
    cep        VARCHAR2(10),
    CONSTRAINT uk_clinica_cnpj UNIQUE (cnpj)
);

-- ============================================================
-- 4. VETERINARIO
-- ============================================================
CREATE TABLE veterinario (
    id               VARCHAR2(36)  DEFAULT fn_uuid() PRIMARY KEY,
    cpf              VARCHAR2(11),
    nome             VARCHAR2(150) NOT NULL,
    data_nascimento  DATE,
    sexo             VARCHAR2(10),
    email            VARCHAR2(200),
    telefone         VARCHAR2(20),
    especialidade    VARCHAR2(100),
    crmv             VARCHAR2(30),
    logradouro       VARCHAR2(300),
    numero           VARCHAR2(10),
    bairro           VARCHAR2(150),
    cidade           VARCHAR2(100),
    estado           VARCHAR2(50),
    cep              VARCHAR2(10),
    clinica_id       VARCHAR2(36),
    CONSTRAINT fk_vet_clinica FOREIGN KEY (clinica_id) REFERENCES clinica(id),
    CONSTRAINT uk_vet_cpf     UNIQUE (cpf),
    CONSTRAINT uk_vet_crmv    UNIQUE (crmv),
    CONSTRAINT chk_vet_sexo   CHECK (sexo IN ('MASCULINO','FEMININO','OUTRO'))
);

-- ============================================================
-- 5. EVENTO CLINICO
-- tipo_evento: salvo como nome do enum Java
-- ============================================================
CREATE TABLE evento_clinico (
    id              VARCHAR2(36)  DEFAULT fn_uuid() PRIMARY KEY,
    data            DATE,
    hora            VARCHAR2(5),
    descricao       VARCHAR2(1000),
    tipo_evento     VARCHAR2(20),
    veterinario_id  VARCHAR2(36),
    animal_id       VARCHAR2(36),
    clinica_id      VARCHAR2(36),
    CONSTRAINT fk_evento_vet     FOREIGN KEY (veterinario_id) REFERENCES veterinario(id),
    CONSTRAINT fk_evento_animal  FOREIGN KEY (animal_id)      REFERENCES animal(id),
    CONSTRAINT fk_evento_clinica FOREIGN KEY (clinica_id)     REFERENCES clinica(id),
    CONSTRAINT chk_evento_tipo   CHECK (tipo_evento IN ('CONSULTA','RETORNO','VACINA','EXAME','CIRURGIA','OUTRO'))
);

-- ============================================================
-- 6. PAGAMENTO
-- forma_pagamento e status_pagamento: nome do enum Java
-- ============================================================
CREATE TABLE pagamento (
    id                VARCHAR2(36)  DEFAULT fn_uuid() PRIMARY KEY,
    forma_pagamento   VARCHAR2(10),
    valor             NUMBER(10,2),
    data_pagamento    DATE,
    descricao         VARCHAR2(500),
    observacao        VARCHAR2(1000),
    status_pagamento  VARCHAR2(15),
    evento_clinico_id VARCHAR2(36),
    CONSTRAINT fk_pagamento_evento  FOREIGN KEY (evento_clinico_id) REFERENCES evento_clinico(id),
    CONSTRAINT chk_forma_pagamento  CHECK (forma_pagamento  IN ('PIX','CARTAO','DINHEIRO','BOLETO')),
    CONSTRAINT chk_status_pagamento CHECK (status_pagamento IN ('PENDENTE','PAGO','CANCELADO','ESTORNADO')),
    CONSTRAINT chk_pagamento_valor  CHECK (valor > 0)
);
