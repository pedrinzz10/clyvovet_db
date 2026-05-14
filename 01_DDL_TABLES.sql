-- ============================================================
-- CLYVO VET -- ORACLE DATABASE
-- Arquivo 01: DDL -- Criação das Tabelas
-- ============================================================

CREATE OR REPLACE FUNCTION fn_uuid RETURN VARCHAR2 IS
BEGIN
    RETURN LOWER(REGEXP_REPLACE(
        RAWTOHEX(SYS_GUID()),
        '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})',
        '\1-\2-\3-\4-\5'
    ));
END fn_uuid;
/

CREATE SEQUENCE seq_log_erros START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

-- ============================================================
-- LOG DE ERROS
-- ============================================================
CREATE TABLE log_erros (
    id              NUMBER        DEFAULT seq_log_erros.NEXTVAL PRIMARY KEY,
    nome_procedure  VARCHAR2(100) NOT NULL,
    usuario         VARCHAR2(100) DEFAULT USER,
    data_erro       TIMESTAMP     DEFAULT SYSTIMESTAMP,
    codigo_erro     NUMBER,
    mensagem_erro   VARCHAR2(4000)
);

-- ============================================================
-- 1. TUTOR
-- ============================================================
CREATE TABLE tutor (
    id              VARCHAR2(36)  DEFAULT fn_uuid() PRIMARY KEY,
    cpf             VARCHAR2(11),
    nome            VARCHAR2(150) NOT NULL,
    data_nascimento DATE,
    genero          VARCHAR2(10),
    email           VARCHAR2(200),
    telefone        VARCHAR2(20),
    rua             VARCHAR2(300),
    numero          VARCHAR2(10),
    bairro          VARCHAR2(150),
    cidade          VARCHAR2(100),
    estado          VARCHAR2(50),
    cep             VARCHAR2(10),
    criado_em       TIMESTAMP     DEFAULT SYSTIMESTAMP,
    CONSTRAINT uk_tutor_cpf     UNIQUE (cpf),
    CONSTRAINT uk_tutor_email   UNIQUE (email),
    CONSTRAINT chk_tutor_genero CHECK (genero IN ('MASCULINO','FEMININO','OUTRO'))
);

-- ============================================================
-- 2. ANIMAL
-- ============================================================
CREATE TABLE animal (
    id              VARCHAR2(36)  DEFAULT fn_uuid() PRIMARY KEY,
    nome            VARCHAR2(100) NOT NULL,
    raca            VARCHAR2(100),
    especie         VARCHAR2(50),
    porte           VARCHAR2(10),
    cor             VARCHAR2(80),
    genero          VARCHAR2(10),
    data_nascimento DATE,
    observacoes     VARCHAR2(1000),
    peso            NUMBER(5,2),
    castrado        NUMBER(1)     DEFAULT 0,
    microchip       VARCHAR2(50),
    foto_url        VARCHAR2(500),
    qr_code         VARCHAR2(100),
    tutor_id        VARCHAR2(36),
    criado_em       TIMESTAMP     DEFAULT SYSTIMESTAMP,
    CONSTRAINT fk_animal_tutor      FOREIGN KEY (tutor_id) REFERENCES tutor(id),
    CONSTRAINT chk_animal_castrado  CHECK (castrado IN (0,1)),
    CONSTRAINT uk_animal_microchip  UNIQUE (microchip),
    CONSTRAINT uk_animal_qr_code    UNIQUE (qr_code),
    CONSTRAINT chk_animal_porte     CHECK (porte   IN ('PEQUENO','MEDIO','GRANDE')),
    CONSTRAINT chk_animal_genero    CHECK (genero  IN ('MACHO','FEMEA','DESCONHECIDO'))
);

-- ============================================================
-- 3. CLINICA
-- ============================================================
CREATE TABLE clinica (
    id        VARCHAR2(36)  DEFAULT fn_uuid() PRIMARY KEY,
    nome      VARCHAR2(200) NOT NULL,
    cnpj      VARCHAR2(14),
    telefone  VARCHAR2(20),
    email     VARCHAR2(200),
    rua       VARCHAR2(300),
    numero    VARCHAR2(10),
    bairro    VARCHAR2(150),
    cidade    VARCHAR2(100),
    estado    VARCHAR2(50),
    cep       VARCHAR2(10),
    criado_em TIMESTAMP     DEFAULT SYSTIMESTAMP,
    CONSTRAINT uk_clinica_cnpj UNIQUE (cnpj)
);

-- ============================================================
-- 4. VETERINARIO
-- ============================================================
CREATE TABLE veterinario (
    id              VARCHAR2(36)  DEFAULT fn_uuid() PRIMARY KEY,
    cpf             VARCHAR2(11),
    nome            VARCHAR2(150) NOT NULL,
    data_nascimento DATE,
    genero          VARCHAR2(10),
    email           VARCHAR2(200),
    telefone        VARCHAR2(20),
    especialidade   VARCHAR2(100),
    crmv            VARCHAR2(30),
    rua             VARCHAR2(300),
    numero          VARCHAR2(10),
    bairro          VARCHAR2(150),
    cidade          VARCHAR2(100),
    estado          VARCHAR2(50),
    cep             VARCHAR2(10),
    clinica_id      VARCHAR2(36),
    criado_em       TIMESTAMP     DEFAULT SYSTIMESTAMP,
    CONSTRAINT fk_veterinario_clinica FOREIGN KEY (clinica_id) REFERENCES clinica(id),
    CONSTRAINT uk_vet_cpf             UNIQUE (cpf),
    CONSTRAINT uk_vet_crmv            UNIQUE (crmv),
    CONSTRAINT chk_vet_genero         CHECK (genero IN ('MASCULINO','FEMININO','OUTRO'))
);

-- ============================================================
-- 5. EVENTO_CLINICO
-- ============================================================
CREATE TABLE evento_clinico (
    id              VARCHAR2(36)  DEFAULT fn_uuid() PRIMARY KEY,
    data_evento     DATE,
    hora_evento     VARCHAR2(5),
    descricao       VARCHAR2(1000),
    tipo_evento     VARCHAR2(20),
    veterinario_id  VARCHAR2(36),
    animal_id       VARCHAR2(36),
    clinica_id      VARCHAR2(36),
    criado_em       TIMESTAMP     DEFAULT SYSTIMESTAMP,
    CONSTRAINT fk_evento_veterinario FOREIGN KEY (veterinario_id) REFERENCES veterinario(id),
    CONSTRAINT fk_evento_animal      FOREIGN KEY (animal_id)      REFERENCES animal(id),
    CONSTRAINT fk_evento_clinica     FOREIGN KEY (clinica_id)     REFERENCES clinica(id),
    CONSTRAINT chk_evento_tipo       CHECK (tipo_evento IN ('CONSULTA','RETORNO','VACINA','EXAME','CIRURGIA','OUTRO'))
);

-- ============================================================
-- 6. PAGAMENTO
-- PIX e BOLETO mantidos sem tradução (sistemas brasileiros)
-- ============================================================
CREATE TABLE pagamento (
    id                VARCHAR2(36)  DEFAULT fn_uuid() PRIMARY KEY,
    metodo_pagamento  VARCHAR2(10),
    valor             NUMBER(10,2),
    data_pagamento    DATE,
    descricao         VARCHAR2(500),
    notas             VARCHAR2(1000),
    status_pagamento  VARCHAR2(15),
    evento_id         VARCHAR2(36),
    criado_em         TIMESTAMP     DEFAULT SYSTIMESTAMP,
    CONSTRAINT fk_pagamento_evento  FOREIGN KEY (evento_id)      REFERENCES evento_clinico(id),
    CONSTRAINT chk_pagamento_metodo CHECK (metodo_pagamento IN ('PIX','CARTAO','DINHEIRO','BOLETO')),
    CONSTRAINT chk_pagamento_status CHECK (status_pagamento IN ('PENDENTE','PAGO','CANCELADO','REEMBOLSADO')),
    CONSTRAINT chk_pagamento_valor  CHECK (valor > 0)
);

-- ============================================================
-- 7. PRODUTO  (domínio API .Net)
-- ============================================================
CREATE TABLE produto (
    id               VARCHAR2(36)  DEFAULT fn_uuid() PRIMARY KEY,
    nome             VARCHAR2(200) NOT NULL,
    descricao        VARCHAR2(1000),
    categoria        VARCHAR2(20),
    preco            NUMBER(10,2),
    especie_indicada VARCHAR2(20),
    ativo            NUMBER(1)     DEFAULT 1,
    criado_em        TIMESTAMP     DEFAULT SYSTIMESTAMP,
    CONSTRAINT chk_produto_categoria CHECK (categoria         IN ('RACAO','MEDICAMENTO','ACESSORIO','SERVICO','OUTRO')),
    CONSTRAINT chk_produto_especie   CHECK (especie_indicada  IN ('CACHORRO','GATO','PASSARO','REPTIL','ROEDOR','TODOS','OUTRO')),
    CONSTRAINT chk_produto_ativo     CHECK (ativo             IN (0,1))
);

-- ============================================================
-- 8. SUGESTAO_PRODUTO  (domínio API .Net)
-- animal_id vem do front-end; FK valida existência no banco
-- ============================================================
CREATE TABLE sugestao_produto (
    id              VARCHAR2(36)  DEFAULT fn_uuid() PRIMARY KEY,
    animal_id       VARCHAR2(36)  NOT NULL,
    produto_id      VARCHAR2(36)  NOT NULL,
    justificativa   VARCHAR2(500),
    data_sugestao   DATE          DEFAULT SYSDATE,
    ativo           NUMBER(1)     DEFAULT 1,
    criado_em       TIMESTAMP     DEFAULT SYSTIMESTAMP,
    CONSTRAINT fk_sugestao_animal   FOREIGN KEY (animal_id)  REFERENCES animal(id),
    CONSTRAINT fk_sugestao_produto  FOREIGN KEY (produto_id) REFERENCES produto(id),
    CONSTRAINT chk_sugestao_ativo   CHECK (ativo IN (0,1))
);

-- ============================================================
-- 9. LEMBRETE  (domínio API .Net)
-- ============================================================
CREATE TABLE lembrete (
    id          VARCHAR2(36)  DEFAULT fn_uuid() PRIMARY KEY,
    animal_id   VARCHAR2(36)  NOT NULL,
    titulo      VARCHAR2(200) NOT NULL,
    descricao   VARCHAR2(1000),
    tipo        VARCHAR2(20),
    agendado_em TIMESTAMP     NOT NULL,
    recorrente  NUMBER(1)     DEFAULT 0,
    status      VARCHAR2(20)  DEFAULT 'PENDENTE',
    criado_em   TIMESTAMP     DEFAULT SYSTIMESTAMP,
    CONSTRAINT fk_lembrete_animal      FOREIGN KEY (animal_id) REFERENCES animal(id),
    CONSTRAINT chk_lembrete_tipo       CHECK (tipo       IN ('VACINA','MEDICAMENTO','CONSULTA','HIGIENE','OUTRO')),
    CONSTRAINT chk_lembrete_recorrente CHECK (recorrente IN (0,1)),
    CONSTRAINT chk_lembrete_status     CHECK (status     IN ('PENDENTE','ENVIADO','CANCELADO'))
);

-- ============================================================
-- 10. EVENTO_PET  (domínio API .Net)
-- ============================================================
CREATE TABLE evento_pet (
    id              VARCHAR2(36)  DEFAULT fn_uuid() PRIMARY KEY,
    titulo          VARCHAR2(200) NOT NULL,
    descricao       VARCHAR2(1000),
    tipo            VARCHAR2(20),
    rua             VARCHAR2(300),
    numero          VARCHAR2(10),
    bairro          VARCHAR2(150),
    cidade          VARCHAR2(100),
    estado          VARCHAR2(50),
    cep             VARCHAR2(10),
    data_inicio     DATE          NOT NULL,
    data_fim        DATE,
    especie_alvo    VARCHAR2(20)  DEFAULT 'TODOS',
    organizador     VARCHAR2(200),
    gratuito        NUMBER(1)     DEFAULT 1,
    link_inscricao  VARCHAR2(500),
    ativo           NUMBER(1)     DEFAULT 1,
    criado_em       TIMESTAMP     DEFAULT SYSTIMESTAMP,
    CONSTRAINT chk_evento_pet_tipo         CHECK (tipo         IN ('VACINACAO','FEIRA','CASTRACAO','WORKSHOP','OUTRO')),
    CONSTRAINT chk_evento_pet_especie_alvo CHECK (especie_alvo IN ('CACHORRO','GATO','PASSARO','REPTIL','ROEDOR','TODOS','OUTRO')),
    CONSTRAINT chk_evento_pet_gratuito     CHECK (gratuito     IN (0,1)),
    CONSTRAINT chk_evento_pet_ativo        CHECK (ativo        IN (0,1))
);
