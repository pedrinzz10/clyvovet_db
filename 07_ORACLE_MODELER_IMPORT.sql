-- ============================================================
-- CLYVO VET -- ORACLE DATA MODELER
-- Arquivo 07: DDL para importacao no Oracle Data Modeler
-- ============================================================
-- COMO USAR:
--   1. Abra o Oracle Data Modeler
--   2. File > Import > DDL File
--   3. Selecione este arquivo
--   4. Clique em "Generate" para criar o Modelo Relacional
--   5. Para o Modelo Logico:
--      View > Logical Model
-- ============================================================
-- NOTA: Este arquivo usa VARCHAR2(36) para PKs/FKs (UUID).
--       Sem fn_uuid() -- o Data Modeler nao executa PL/SQL.
--       Sem DEFAULT -- apenas estrutura para geracao do modelo.
-- ============================================================

-- ------------------------------------------------------------
-- TABELA: tb_log_erros
-- ------------------------------------------------------------
CREATE TABLE tb_log_erros (
    id              NUMBER           NOT NULL,
    nome_procedure  VARCHAR2(100),
    nome_usuario    VARCHAR2(100),
    data_erro       TIMESTAMP,
    codigo_erro     NUMBER,
    mensagem_erro   VARCHAR2(4000),
    CONSTRAINT pk_log_erros PRIMARY KEY (id)
);

-- ------------------------------------------------------------
-- TABELA: tutor
-- ------------------------------------------------------------
CREATE TABLE tutor (
    id               VARCHAR2(36)  NOT NULL,
    nome             VARCHAR2(120) NOT NULL,
    email            VARCHAR2(120) NOT NULL,
    cpf              VARCHAR2(11),
    telefone         VARCHAR2(20),
    data_nascimento  DATE,
    sexo             VARCHAR2(10),
    logradouro       VARCHAR2(150),
    numero           VARCHAR2(10),
    bairro           VARCHAR2(80),
    cidade           VARCHAR2(80),
    estado           VARCHAR2(2),
    cep              VARCHAR2(8),
    criado_em        TIMESTAMP,
    CONSTRAINT pk_tutor       PRIMARY KEY (id),
    CONSTRAINT uq_tutor_email UNIQUE (email),
    CONSTRAINT uq_tutor_cpf   UNIQUE (cpf),
    CONSTRAINT chk_tutor_sexo CHECK (sexo IN ('MASCULINO','FEMININO','OUTRO'))
);

-- ------------------------------------------------------------
-- TABELA: animal
-- ------------------------------------------------------------
CREATE TABLE animal (
    id               VARCHAR2(36)  NOT NULL,
    nome             VARCHAR2(80)  NOT NULL,
    especie          VARCHAR2(20)  NOT NULL,
    raca             VARCHAR2(60),
    porte            VARCHAR2(10),
    cor              VARCHAR2(40),
    sexo             VARCHAR2(10),
    data_nascimento  DATE,
    observacao       VARCHAR2(500),
    tutor_id         VARCHAR2(36)  NOT NULL,
    criado_em        TIMESTAMP,
    CONSTRAINT pk_animal        PRIMARY KEY (id),
    CONSTRAINT chk_animal_especie CHECK (especie IN ('CAO','GATO','AVE','REPTIL','ROEDOR','OUTRO')),
    CONSTRAINT chk_animal_porte   CHECK (porte   IN ('PEQUENO','MEDIO','GRANDE')),
    CONSTRAINT chk_animal_sexo    CHECK (sexo    IN ('MACHO','FEMEA'))
);

-- ------------------------------------------------------------
-- TABELA: clinica
-- ------------------------------------------------------------
CREATE TABLE clinica (
    id          VARCHAR2(36)  NOT NULL,
    nome        VARCHAR2(120) NOT NULL,
    cnpj        VARCHAR2(14),
    telefone    VARCHAR2(20),
    email       VARCHAR2(120),
    logradouro  VARCHAR2(150),
    numero      VARCHAR2(10),
    bairro      VARCHAR2(80),
    cidade      VARCHAR2(80),
    estado      VARCHAR2(2),
    cep         VARCHAR2(8),
    criado_em   TIMESTAMP,
    CONSTRAINT pk_clinica     PRIMARY KEY (id),
    CONSTRAINT uq_clinica_cnpj UNIQUE (cnpj)
);

-- ------------------------------------------------------------
-- TABELA: veterinario
-- ------------------------------------------------------------
CREATE TABLE veterinario (
    id               VARCHAR2(36)  NOT NULL,
    nome             VARCHAR2(120) NOT NULL,
    crmv             VARCHAR2(30)  NOT NULL,
    especialidade    VARCHAR2(80),
    email            VARCHAR2(120),
    cpf              VARCHAR2(11),
    telefone         VARCHAR2(20),
    sexo             VARCHAR2(10),
    data_nascimento  DATE,
    clinica_id       VARCHAR2(36)  NOT NULL,
    logradouro       VARCHAR2(150),
    numero           VARCHAR2(10),
    bairro           VARCHAR2(80),
    cidade           VARCHAR2(80),
    estado           VARCHAR2(2),
    cep              VARCHAR2(8),
    criado_em        TIMESTAMP,
    CONSTRAINT pk_veterinario     PRIMARY KEY (id),
    CONSTRAINT uq_vet_crmv        UNIQUE (crmv),
    CONSTRAINT chk_vet_sexo       CHECK (sexo IN ('MASCULINO','FEMININO','OUTRO'))
);

-- ------------------------------------------------------------
-- TABELA: evento_clinico
-- ------------------------------------------------------------
CREATE TABLE evento_clinico (
    id               VARCHAR2(36)  NOT NULL,
    data             DATE          NOT NULL,
    hora             VARCHAR2(5)   NOT NULL,
    tipo_evento      VARCHAR2(20)  NOT NULL,
    descricao        VARCHAR2(500),
    veterinario_id   VARCHAR2(36)  NOT NULL,
    animal_id        VARCHAR2(36)  NOT NULL,
    clinica_id       VARCHAR2(36)  NOT NULL,
    criado_em        TIMESTAMP,
    CONSTRAINT pk_evento        PRIMARY KEY (id),
    CONSTRAINT chk_evento_tipo  CHECK (tipo_evento IN ('CONSULTA','RETORNO','VACINA','EXAME','CIRURGIA','OUTRO'))
);

-- ------------------------------------------------------------
-- TABELA: pagamento
-- ------------------------------------------------------------
CREATE TABLE pagamento (
    id                  VARCHAR2(36)   NOT NULL,
    forma_pagamento     VARCHAR2(20)   NOT NULL,
    valor               NUMBER(10,2)   NOT NULL,
    status_pagamento    VARCHAR2(20)   NOT NULL,
    data_pagamento      DATE,
    descricao           VARCHAR2(300),
    observacao          VARCHAR2(500),
    evento_clinico_id   VARCHAR2(36)   NOT NULL,
    criado_em           TIMESTAMP,
    CONSTRAINT pk_pagamento         PRIMARY KEY (id),
    CONSTRAINT uq_pagamento_evento  UNIQUE (evento_clinico_id),
    CONSTRAINT chk_forma_pagamento  CHECK (forma_pagamento   IN ('PIX','CARTAO','DINHEIRO','BOLETO')),
    CONSTRAINT chk_status_pagamento CHECK (status_pagamento  IN ('PENDENTE','PAGO','CANCELADO','ESTORNADO'))
);

-- ============================================================
-- FOREIGN KEYS
-- ============================================================

ALTER TABLE animal
    ADD CONSTRAINT fk_animal_tutor
    FOREIGN KEY (tutor_id) REFERENCES tutor(id);

ALTER TABLE veterinario
    ADD CONSTRAINT fk_vet_clinica
    FOREIGN KEY (clinica_id) REFERENCES clinica(id);

ALTER TABLE evento_clinico
    ADD CONSTRAINT fk_evento_veterinario
    FOREIGN KEY (veterinario_id) REFERENCES veterinario(id);

ALTER TABLE evento_clinico
    ADD CONSTRAINT fk_evento_animal
    FOREIGN KEY (animal_id) REFERENCES animal(id);

ALTER TABLE evento_clinico
    ADD CONSTRAINT fk_evento_clinica
    FOREIGN KEY (clinica_id) REFERENCES clinica(id);

ALTER TABLE pagamento
    ADD CONSTRAINT fk_pagamento_evento
    FOREIGN KEY (evento_clinico_id) REFERENCES evento_clinico(id);
