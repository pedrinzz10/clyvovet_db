-- ============================================================
-- CLYVO VET -- ORACLE DATA MODELER
-- Arquivo 07: DDL para importação no Oracle Data Modeler
-- ============================================================
-- COMO USAR:
--   1. Abra o Oracle Data Modeler
--   2. File > Import > DDL File
--   3. Selecione este arquivo
--   4. Clique em "Generate" para criar o Modelo Relacional
--   5. Para Modelo Lógico: View > Logical Model
-- ============================================================
-- NOTA: Usa VARCHAR2(36) para PKs/FKs (UUID).
--       Sem fn_uuid() -- Data Modeler não executa PL/SQL.
--       Sem DEFAULT -- apenas estrutura para geração do modelo.
-- ============================================================

-- ------------------------------------------------------------
-- TABELA: log_erros
-- ------------------------------------------------------------
CREATE TABLE log_erros (
    id              NUMBER           NOT NULL,
    nome_procedure  VARCHAR2(100),
    usuario         VARCHAR2(100),
    data_erro       TIMESTAMP,
    codigo_erro     NUMBER,
    mensagem_erro   VARCHAR2(4000),
    CONSTRAINT pk_log_erros PRIMARY KEY (id)
);

-- ------------------------------------------------------------
-- TABELA: tutor
-- ------------------------------------------------------------
CREATE TABLE tutor (
    id              VARCHAR2(36)  NOT NULL,
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
    criado_em       TIMESTAMP,
    CONSTRAINT pk_tutor       PRIMARY KEY (id),
    CONSTRAINT uq_tutor_email UNIQUE (email),
    CONSTRAINT uq_tutor_cpf   UNIQUE (cpf),
    CONSTRAINT chk_tutor_genero CHECK (genero IN ('MASCULINO','FEMININO','OUTRO'))
);

-- ------------------------------------------------------------
-- TABELA: animal
-- ------------------------------------------------------------
CREATE TABLE animal (
    id              VARCHAR2(36)  NOT NULL,
    nome            VARCHAR2(100) NOT NULL,
    raca            VARCHAR2(100),
    especie         VARCHAR2(50),
    porte           VARCHAR2(10),
    cor             VARCHAR2(80),
    genero          VARCHAR2(10),
    data_nascimento DATE,
    observacoes     VARCHAR2(1000),
    peso            NUMBER(5,2),
    castrado        NUMBER(1),
    microchip       VARCHAR2(50),
    foto_url        VARCHAR2(500),
    qr_code         VARCHAR2(100),
    tutor_id        VARCHAR2(36)  NOT NULL,
    criado_em       TIMESTAMP,
    CONSTRAINT pk_animal          PRIMARY KEY (id),
    CONSTRAINT uq_animal_microchip UNIQUE (microchip),
    CONSTRAINT uq_animal_qr_code   UNIQUE (qr_code),
    CONSTRAINT chk_animal_castrado CHECK (castrado IN (0,1)),
    CONSTRAINT chk_animal_porte    CHECK (porte    IN ('PEQUENO','MEDIO','GRANDE')),
    CONSTRAINT chk_animal_genero   CHECK (genero   IN ('MACHO','FEMEA','DESCONHECIDO'))
);

-- ------------------------------------------------------------
-- TABELA: clinica
-- ------------------------------------------------------------
CREATE TABLE clinica (
    id        VARCHAR2(36)  NOT NULL,
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
    criado_em TIMESTAMP,
    CONSTRAINT pk_clinica      PRIMARY KEY (id),
    CONSTRAINT uq_clinica_cnpj UNIQUE (cnpj)
);

-- ------------------------------------------------------------
-- TABELA: veterinario
-- ------------------------------------------------------------
CREATE TABLE veterinario (
    id              VARCHAR2(36)  NOT NULL,
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
    clinica_id      VARCHAR2(36)  NOT NULL,
    criado_em       TIMESTAMP,
    CONSTRAINT pk_veterinario  PRIMARY KEY (id),
    CONSTRAINT uq_vet_crmv     UNIQUE (crmv),
    CONSTRAINT uq_vet_cpf      UNIQUE (cpf),
    CONSTRAINT chk_vet_genero  CHECK (genero IN ('MASCULINO','FEMININO','OUTRO'))
);

-- ------------------------------------------------------------
-- TABELA: evento_clinico
-- ------------------------------------------------------------
CREATE TABLE evento_clinico (
    id              VARCHAR2(36)  NOT NULL,
    data_evento     DATE,
    hora_evento     VARCHAR2(5),
    descricao       VARCHAR2(1000),
    tipo_evento     VARCHAR2(20),
    veterinario_id  VARCHAR2(36)  NOT NULL,
    animal_id       VARCHAR2(36)  NOT NULL,
    clinica_id      VARCHAR2(36)  NOT NULL,
    criado_em       TIMESTAMP,
    CONSTRAINT pk_evento_clinico PRIMARY KEY (id),
    CONSTRAINT chk_evento_tipo   CHECK (tipo_evento IN ('CONSULTA','RETORNO','VACINA','EXAME','CIRURGIA','OUTRO'))
);

-- ------------------------------------------------------------
-- TABELA: pagamento
-- ------------------------------------------------------------
CREATE TABLE pagamento (
    id                VARCHAR2(36)  NOT NULL,
    metodo_pagamento  VARCHAR2(10),
    valor             NUMBER(10,2),
    data_pagamento    DATE,
    descricao         VARCHAR2(500),
    notas             VARCHAR2(1000),
    status_pagamento  VARCHAR2(15),
    evento_id         VARCHAR2(36)  NOT NULL,
    criado_em         TIMESTAMP,
    CONSTRAINT pk_pagamento          PRIMARY KEY (id),
    CONSTRAINT chk_pagamento_metodo  CHECK (metodo_pagamento IN ('PIX','CARTAO','DINHEIRO','BOLETO')),
    CONSTRAINT chk_pagamento_status  CHECK (status_pagamento IN ('PENDENTE','PAGO','CANCELADO','REEMBOLSADO')),
    CONSTRAINT chk_pagamento_valor   CHECK (valor > 0)
);

-- ------------------------------------------------------------
-- TABELA: produto
-- ------------------------------------------------------------
CREATE TABLE produto (
    id               VARCHAR2(36)  NOT NULL,
    nome             VARCHAR2(200) NOT NULL,
    descricao        VARCHAR2(1000),
    categoria        VARCHAR2(20),
    preco            NUMBER(10,2),
    especie_indicada VARCHAR2(20),
    ativo            NUMBER(1),
    criado_em        TIMESTAMP,
    CONSTRAINT pk_produto           PRIMARY KEY (id),
    CONSTRAINT chk_produto_categoria CHECK (categoria         IN ('RACAO','MEDICAMENTO','ACESSORIO','SERVICO','OUTRO')),
    CONSTRAINT chk_produto_especie   CHECK (especie_indicada  IN ('CACHORRO','GATO','PASSARO','REPTIL','ROEDOR','TODOS','OUTRO')),
    CONSTRAINT chk_produto_ativo     CHECK (ativo             IN (0,1))
);

-- ------------------------------------------------------------
-- TABELA: sugestao_produto
-- ------------------------------------------------------------
CREATE TABLE sugestao_produto (
    id              VARCHAR2(36)  NOT NULL,
    animal_id       VARCHAR2(36)  NOT NULL,
    produto_id      VARCHAR2(36)  NOT NULL,
    justificativa   VARCHAR2(500),
    data_sugestao   DATE,
    ativo           NUMBER(1),
    criado_em       TIMESTAMP,
    CONSTRAINT pk_sugestao_produto PRIMARY KEY (id),
    CONSTRAINT chk_sugestao_ativo  CHECK (ativo IN (0,1))
);

-- ------------------------------------------------------------
-- TABELA: lembrete
-- ------------------------------------------------------------
CREATE TABLE lembrete (
    id          VARCHAR2(36)  NOT NULL,
    animal_id   VARCHAR2(36)  NOT NULL,
    titulo      VARCHAR2(200) NOT NULL,
    descricao   VARCHAR2(1000),
    tipo        VARCHAR2(20),
    agendado_em TIMESTAMP     NOT NULL,
    recorrente  NUMBER(1),
    status      VARCHAR2(20),
    criado_em   TIMESTAMP,
    CONSTRAINT pk_lembrete           PRIMARY KEY (id),
    CONSTRAINT chk_lembrete_tipo     CHECK (tipo       IN ('VACINA','MEDICAMENTO','CONSULTA','HIGIENE','OUTRO')),
    CONSTRAINT chk_lembrete_recorr   CHECK (recorrente IN (0,1)),
    CONSTRAINT chk_lembrete_status   CHECK (status     IN ('PENDENTE','ENVIADO','CANCELADO'))
);

-- ------------------------------------------------------------
-- TABELA: evento_pet
-- ------------------------------------------------------------
CREATE TABLE evento_pet (
    id              VARCHAR2(36)  NOT NULL,
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
    especie_alvo    VARCHAR2(20),
    organizador     VARCHAR2(200),
    gratuito        NUMBER(1),
    link_inscricao  VARCHAR2(500),
    ativo           NUMBER(1),
    criado_em       TIMESTAMP,
    CONSTRAINT pk_evento_pet               PRIMARY KEY (id),
    CONSTRAINT chk_evento_pet_tipo         CHECK (tipo         IN ('VACINACAO','FEIRA','CASTRACAO','WORKSHOP','OUTRO')),
    CONSTRAINT chk_evento_pet_especie_alvo CHECK (especie_alvo IN ('CACHORRO','GATO','PASSARO','REPTIL','ROEDOR','TODOS','OUTRO')),
    CONSTRAINT chk_evento_pet_gratuito     CHECK (gratuito     IN (0,1)),
    CONSTRAINT chk_evento_pet_ativo        CHECK (ativo        IN (0,1))
);

-- ============================================================
-- CHAVES ESTRANGEIRAS
-- ============================================================

ALTER TABLE animal
    ADD CONSTRAINT fk_animal_tutor
    FOREIGN KEY (tutor_id) REFERENCES tutor(id);

ALTER TABLE veterinario
    ADD CONSTRAINT fk_veterinario_clinica
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
    FOREIGN KEY (evento_id) REFERENCES evento_clinico(id);

ALTER TABLE sugestao_produto
    ADD CONSTRAINT fk_sugestao_animal
    FOREIGN KEY (animal_id) REFERENCES animal(id);

ALTER TABLE sugestao_produto
    ADD CONSTRAINT fk_sugestao_produto_ref
    FOREIGN KEY (produto_id) REFERENCES produto(id);

ALTER TABLE lembrete
    ADD CONSTRAINT fk_lembrete_animal
    FOREIGN KEY (animal_id) REFERENCES animal(id);
