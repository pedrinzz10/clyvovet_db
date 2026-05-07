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
--      Navigator > Relational Models > clique direito > "Engineer to Logical Model"
-- ============================================================

-- ------------------------------------------------------------
-- DOMINIO: SISTEMA
-- ------------------------------------------------------------
CREATE TABLE tb_log_erros (
    id              NUMBER          NOT NULL,
    nome_procedure  VARCHAR2(100)   NOT NULL,
    nome_usuario    VARCHAR2(100),
    data_erro       TIMESTAMP,
    codigo_erro     NUMBER,
    mensagem_erro   VARCHAR2(4000),
    CONSTRAINT pk_log_erros PRIMARY KEY (id)
);

-- ------------------------------------------------------------
-- DOMINIO: ENDERECOS
-- ------------------------------------------------------------
CREATE TABLE tb_enderecos (
    id          NUMBER          NOT NULL,
    logradouro  VARCHAR2(300)   NOT NULL,
    bairro      VARCHAR2(150),
    cidade      VARCHAR2(100)   NOT NULL,
    estado      VARCHAR2(50)    NOT NULL,
    cep         VARCHAR2(10),
    latitude    NUMBER(10,7),
    longitude   NUMBER(10,7),
    criado_em   TIMESTAMP       NOT NULL,
    CONSTRAINT pk_enderecos PRIMARY KEY (id)
);

-- ------------------------------------------------------------
-- DOMINIO: USUARIOS
-- ------------------------------------------------------------
CREATE TABLE tb_usuarios (
    id              NUMBER          NOT NULL,
    nome            VARCHAR2(150)   NOT NULL,
    email           VARCHAR2(200)   NOT NULL,
    telefone        VARCHAR2(20),
    senha_hash      VARCHAR2(255)   NOT NULL,
    perfil          VARCHAR2(20)    NOT NULL,
    url_avatar      VARCHAR2(500),
    idioma          VARCHAR2(5)     NOT NULL,
    ativo           NUMBER(1)       NOT NULL,
    endereco_id     NUMBER,
    criado_em       TIMESTAMP       NOT NULL,
    atualizado_em   TIMESTAMP       NOT NULL,
    CONSTRAINT pk_usuarios          PRIMARY KEY (id),
    CONSTRAINT uk_usuario_email     UNIQUE (email),
    CONSTRAINT chk_usuario_perfil   CHECK (perfil IN ('dono','veterinario','admin_clinica','super_admin')),
    CONSTRAINT chk_usuario_idioma   CHECK (idioma IN ('pt','en','es')),
    CONSTRAINT chk_usuario_ativo    CHECK (ativo  IN (0,1))
);

-- ------------------------------------------------------------
-- DOMINIO: ANIMAIS
-- ------------------------------------------------------------
CREATE TABLE tb_animais (
    id                  NUMBER          NOT NULL,
    nome                VARCHAR2(100)   NOT NULL,
    especie             VARCHAR2(30)    NOT NULL,
    raca                VARCHAR2(100),
    sexo                VARCHAR2(15),
    data_nascimento     DATE,
    cor                 VARCHAR2(80),
    peso_kg             NUMBER(5,2),
    codigo_microchip    VARCHAR2(50),
    url_foto            VARCHAR2(500),
    modalidade          VARCHAR2(15)    NOT NULL,
    ativo               NUMBER(1)       NOT NULL,
    criado_em           TIMESTAMP       NOT NULL,
    CONSTRAINT pk_animais           PRIMARY KEY (id),
    CONSTRAINT uk_animal_microchip  UNIQUE (codigo_microchip),
    CONSTRAINT chk_animal_especie   CHECK (especie    IN ('cao','gato','ave','reptil','roedor','fazenda','selvagem','outro')),
    CONSTRAINT chk_animal_sexo      CHECK (sexo       IN ('macho','femea','desconhecido')),
    CONSTRAINT chk_animal_modal     CHECK (modalidade IN ('domestico','agropecuario','selvagem')),
    CONSTRAINT chk_animal_peso      CHECK (peso_kg > 0),
    CONSTRAINT chk_animal_ativo     CHECK (ativo IN (0,1))
);

CREATE TABLE tb_donos_animal (
    id          NUMBER       NOT NULL,
    animal_id   NUMBER       NOT NULL,
    usuario_id  NUMBER       NOT NULL,
    papel       VARCHAR2(15) NOT NULL,
    criado_em   TIMESTAMP    NOT NULL,
    CONSTRAINT pk_donos_animal  PRIMARY KEY (id),
    CONSTRAINT uk_dono_animal   UNIQUE (animal_id, usuario_id),
    CONSTRAINT chk_dono_papel   CHECK (papel IN ('principal','secundario'))
);

CREATE TABLE tb_scores_saude (
    id                  NUMBER      NOT NULL,
    animal_id           NUMBER      NOT NULL,
    pontuacao           NUMBER(5,2) NOT NULL,
    pontuacao_nutricao  NUMBER(5,2),
    pontuacao_atividade NUMBER(5,2),
    pontuacao_vacina    NUMBER(5,2),
    registrado_em       TIMESTAMP   NOT NULL,
    CONSTRAINT pk_scores_saude  PRIMARY KEY (id),
    CONSTRAINT chk_pontuacao    CHECK (pontuacao           BETWEEN 0 AND 100),
    CONSTRAINT chk_nutricao     CHECK (pontuacao_nutricao  BETWEEN 0 AND 100),
    CONSTRAINT chk_atividade    CHECK (pontuacao_atividade BETWEEN 0 AND 100),
    CONSTRAINT chk_vacina_score CHECK (pontuacao_vacina    BETWEEN 0 AND 100)
);

-- ------------------------------------------------------------
-- DOMINIO: CARTEIRINHA DIGITAL
-- ------------------------------------------------------------
CREATE TABLE tb_carteirinhas (
    id              NUMBER       NOT NULL,
    animal_id       NUMBER       NOT NULL,
    token_qr_code   VARCHAR2(36) NOT NULL,
    numero_registro VARCHAR2(50),
    certificado_em  TIMESTAMP,
    valido_ate      TIMESTAMP,
    publico         NUMBER(1)    NOT NULL,
    CONSTRAINT pk_carteirinhas          PRIMARY KEY (id),
    CONSTRAINT uk_carteirinha_animal    UNIQUE (animal_id),
    CONSTRAINT uk_carteirinha_qr        UNIQUE (token_qr_code),
    CONSTRAINT chk_carteirinha_publica  CHECK (publico IN (0,1))
);

CREATE TABLE tb_vacinas_carteirinha (
    id              NUMBER        NOT NULL,
    carteirinha_id  NUMBER        NOT NULL,
    nome_vacina     VARCHAR2(150) NOT NULL,
    situacao        VARCHAR2(10)  NOT NULL,
    aplicada_em     DATE,
    valida_ate      DATE,
    CONSTRAINT pk_vacinas_carteirinha   PRIMARY KEY (id),
    CONSTRAINT chk_vacina_situacao      CHECK (situacao IN ('ok','pendente','vencida'))
);

-- ------------------------------------------------------------
-- DOMINIO: CLINICAS
-- ------------------------------------------------------------
CREATE TABLE tb_clinicas (
    id                  NUMBER        NOT NULL,
    nome                VARCHAR2(200) NOT NULL,
    endereco_id         NUMBER        NOT NULL,
    telefone            VARCHAR2(20),
    email               VARCHAR2(200),
    url_logo            VARCHAR2(500),
    parceira            NUMBER(1)     NOT NULL,
    atende_domicilio    NUMBER(1)     NOT NULL,
    aberta_24h          NUMBER(1)     NOT NULL,
    media_avaliacao     NUMBER(3,2),
    total_avaliacoes    NUMBER,
    ativo               NUMBER(1)     NOT NULL,
    criado_em           TIMESTAMP     NOT NULL,
    CONSTRAINT pk_clinicas          PRIMARY KEY (id),
    CONSTRAINT chk_clinica_parceira  CHECK (parceira         IN (0,1)),
    CONSTRAINT chk_clinica_domicilio CHECK (atende_domicilio IN (0,1)),
    CONSTRAINT chk_clinica_24h       CHECK (aberta_24h       IN (0,1)),
    CONSTRAINT chk_clinica_avaliacao CHECK (media_avaliacao  BETWEEN 0 AND 5),
    CONSTRAINT chk_clinica_ativo     CHECK (ativo            IN (0,1))
);

CREATE TABLE tb_horarios_clinica (
    id          NUMBER      NOT NULL,
    clinica_id  NUMBER      NOT NULL,
    dia_semana  NUMBER(1)   NOT NULL,
    abre_as     VARCHAR2(5),
    fecha_as    VARCHAR2(5),
    fechado     NUMBER(1)   NOT NULL,
    CONSTRAINT pk_horarios_clinica  PRIMARY KEY (id),
    CONSTRAINT uk_clinica_dia       UNIQUE (clinica_id, dia_semana),
    CONSTRAINT chk_horario_dia      CHECK (dia_semana BETWEEN 0 AND 6),
    CONSTRAINT chk_horario_fechado  CHECK (fechado    IN (0,1))
);

-- ------------------------------------------------------------
-- DOMINIO: VETERINARIOS
-- ------------------------------------------------------------
CREATE TABLE tb_veterinarios (
    id                  NUMBER        NOT NULL,
    usuario_id          NUMBER        NOT NULL,
    nome                VARCHAR2(150) NOT NULL,
    crm                 VARCHAR2(30)  NOT NULL,
    especialidade       VARCHAR2(100),
    biografia           VARCHAR2(1000),
    anos_experiencia    NUMBER(3),
    url_foto            VARCHAR2(500),
    media_avaliacao     NUMBER(3,2),
    disponivel          NUMBER(1)     NOT NULL,
    criado_em           TIMESTAMP     NOT NULL,
    CONSTRAINT pk_veterinarios      PRIMARY KEY (id),
    CONSTRAINT uk_vet_usuario       UNIQUE (usuario_id),
    CONSTRAINT uk_vet_crm           UNIQUE (crm),
    CONSTRAINT chk_vet_avaliacao    CHECK (media_avaliacao BETWEEN 0 AND 5),
    CONSTRAINT chk_vet_disponivel   CHECK (disponivel      IN (0,1))
);

CREATE TABLE tb_vet_clinicas (
    id              NUMBER    NOT NULL,
    veterinario_id  NUMBER    NOT NULL,
    clinica_id      NUMBER    NOT NULL,
    principal       NUMBER(1) NOT NULL,
    criado_em       TIMESTAMP NOT NULL,
    CONSTRAINT pk_vet_clinicas  PRIMARY KEY (id),
    CONSTRAINT uk_vet_clinica   UNIQUE (veterinario_id, clinica_id),
    CONSTRAINT chk_vc_principal CHECK (principal IN (0,1))
);

CREATE TABLE tb_agendas_vet (
    id               NUMBER      NOT NULL,
    veterinario_id   NUMBER      NOT NULL,
    clinica_id       NUMBER      NOT NULL,
    dia_semana       NUMBER(1)   NOT NULL,
    hora_inicio      VARCHAR2(5) NOT NULL,
    hora_fim         VARCHAR2(5) NOT NULL,
    duracao_slot_min NUMBER(3)   NOT NULL,
    max_slots        NUMBER(3)   NOT NULL,
    ativo            NUMBER(1)   NOT NULL,
    CONSTRAINT pk_agendas_vet   PRIMARY KEY (id),
    CONSTRAINT chk_agenda_dia   CHECK (dia_semana      BETWEEN 0 AND 6),
    CONSTRAINT chk_agenda_slot  CHECK (duracao_slot_min > 0),
    CONSTRAINT chk_agenda_ativo CHECK (ativo           IN (0,1))
);

CREATE TABLE tb_bloqueios_vet (
    id              NUMBER       NOT NULL,
    veterinario_id  NUMBER       NOT NULL,
    data_bloqueio   DATE         NOT NULL,
    hora_inicio     VARCHAR2(5)  NOT NULL,
    hora_fim        VARCHAR2(5)  NOT NULL,
    motivo          VARCHAR2(200),
    CONSTRAINT pk_bloqueios_vet PRIMARY KEY (id)
);

-- ------------------------------------------------------------
-- DOMINIO: AGENDAMENTOS
-- ------------------------------------------------------------
CREATE TABLE tb_consultas (
    id                  NUMBER        NOT NULL,
    animal_id           NUMBER        NOT NULL,
    dono_id             NUMBER        NOT NULL,
    veterinario_id      NUMBER        NOT NULL,
    clinica_id          NUMBER        NOT NULL,
    especialidade       VARCHAR2(100),
    data_consulta       DATE          NOT NULL,
    hora_consulta       VARCHAR2(5)   NOT NULL,
    duracao_min         NUMBER(3)     NOT NULL,
    tipo_atendimento    VARCHAR2(15)  NOT NULL,
    situacao            VARCHAR2(15)  NOT NULL,
    observacoes_dono    VARCHAR2(1000),
    observacoes_vet     VARCHAR2(2000),
    motivo_cancelamento VARCHAR2(500),
    criado_em           TIMESTAMP     NOT NULL,
    atualizado_em       TIMESTAMP     NOT NULL,
    CONSTRAINT pk_consultas         PRIMARY KEY (id),
    CONSTRAINT chk_consulta_tipo    CHECK (tipo_atendimento IN ('presencial','domiciliar')),
    CONSTRAINT chk_consulta_situacao CHECK (situacao        IN ('agendada','confirmada','concluida','cancelada','ausente'))
);

CREATE TABLE tb_lembretes_consulta (
    id          NUMBER       NOT NULL,
    consulta_id NUMBER       NOT NULL,
    lembrar_em  TIMESTAMP    NOT NULL,
    canal       VARCHAR2(10) NOT NULL,
    enviado_em  TIMESTAMP,
    situacao    VARCHAR2(10) NOT NULL,
    CONSTRAINT pk_lembretes_consulta    PRIMARY KEY (id),
    CONSTRAINT chk_lembrete_canal       CHECK (canal    IN ('push','email','sms','whatsapp')),
    CONSTRAINT chk_lembrete_situacao    CHECK (situacao IN ('pendente','enviado','falhou'))
);

-- ------------------------------------------------------------
-- DOMINIO: SAUDE & DOCUMENTOS
-- ------------------------------------------------------------
CREATE TABLE tb_eventos_saude (
    id              NUMBER        NOT NULL,
    animal_id       NUMBER        NOT NULL,
    tipo            VARCHAR2(20)  NOT NULL,
    nome            VARCHAR2(200) NOT NULL,
    descricao       VARCHAR2(1000),
    data_prevista   DATE,
    realizado_em    DATE,
    situacao        VARCHAR2(15)  NOT NULL,
    cor_etiqueta    VARCHAR2(10),
    criado_por      NUMBER,
    criado_em       TIMESTAMP     NOT NULL,
    CONSTRAINT pk_eventos_saude     PRIMARY KEY (id),
    CONSTRAINT chk_evento_tipo      CHECK (tipo    IN ('vacina','vermifugacao','exame','consulta','medicamento','outro')),
    CONSTRAINT chk_evento_situacao  CHECK (situacao IN ('pendente','urgente','concluido','agendado'))
);

CREATE TABLE tb_registros_vacina (
    id                  NUMBER        NOT NULL,
    animal_id           NUMBER        NOT NULL,
    veterinario_id      NUMBER,
    clinica_id          NUMBER,
    nome_vacina         VARCHAR2(150) NOT NULL,
    numero_lote         VARCHAR2(50),
    data_aplicacao      DATE          NOT NULL,
    data_proxima_dose   DATE,
    criado_em           TIMESTAMP     NOT NULL,
    CONSTRAINT pk_registros_vacina PRIMARY KEY (id)
);

CREATE TABLE tb_documentos_animal (
    id              NUMBER        NOT NULL,
    animal_id       NUMBER        NOT NULL,
    tipo            VARCHAR2(25)  NOT NULL,
    nome            VARCHAR2(200) NOT NULL,
    url_arquivo     VARCHAR2(500),
    tamanho_bytes   NUMBER,
    tipo_mime       VARCHAR2(100),
    idioma          VARCHAR2(5),
    emitido_em      DATE,
    valido_ate      DATE,
    enviado_por     NUMBER,
    criado_em       TIMESTAMP     NOT NULL,
    CONSTRAINT pk_documentos_animal PRIMARY KEY (id),
    CONSTRAINT chk_doc_tipo  CHECK (tipo   IN ('carteirinha_vacinal','exame','receita','certificado','raio_x','legal','outro')),
    CONSTRAINT chk_doc_idioma CHECK (idioma IN ('pt','en','es'))
);

-- ------------------------------------------------------------
-- DOMINIO: COMUNICACAO & RELACIONAMENTO
-- ------------------------------------------------------------
CREATE TABLE tb_notificacoes (
    id              NUMBER        NOT NULL,
    usuario_id      NUMBER        NOT NULL,
    tipo            VARCHAR2(50)  NOT NULL,
    titulo          VARCHAR2(200) NOT NULL,
    mensagem        VARCHAR2(1000),
    lido            NUMBER(1)     NOT NULL,
    tipo_entidade   VARCHAR2(50),
    id_entidade     NUMBER,
    criado_em       TIMESTAMP     NOT NULL,
    CONSTRAINT pk_notificacoes  PRIMARY KEY (id),
    CONSTRAINT chk_notif_lido   CHECK (lido IN (0,1))
);

CREATE TABLE tb_avaliacoes (
    id              NUMBER        NOT NULL,
    avaliador_id    NUMBER        NOT NULL,
    tipo_alvo       VARCHAR2(15)  NOT NULL,
    id_alvo         NUMBER        NOT NULL,
    consulta_id     NUMBER,
    nota            NUMBER(2)     NOT NULL,
    comentario      VARCHAR2(2000),
    criado_em       TIMESTAMP     NOT NULL,
    CONSTRAINT pk_avaliacoes        PRIMARY KEY (id),
    CONSTRAINT chk_avaliacao_alvo   CHECK (tipo_alvo IN ('clinica','veterinario')),
    CONSTRAINT chk_avaliacao_nota   CHECK (nota      BETWEEN 1 AND 5)
);

-- ============================================================
-- FOREIGN KEYS (ao final para evitar dependencias de ordem)
-- ============================================================

-- tb_usuarios
ALTER TABLE tb_usuarios
    ADD CONSTRAINT fk_usuario_endereco FOREIGN KEY (endereco_id)
    REFERENCES tb_enderecos(id);

-- tb_donos_animal
ALTER TABLE tb_donos_animal
    ADD CONSTRAINT fk_dono_animal  FOREIGN KEY (animal_id)  REFERENCES tb_animais(id)  ON DELETE CASCADE;
ALTER TABLE tb_donos_animal
    ADD CONSTRAINT fk_dono_usuario FOREIGN KEY (usuario_id) REFERENCES tb_usuarios(id) ON DELETE CASCADE;

-- tb_scores_saude
ALTER TABLE tb_scores_saude
    ADD CONSTRAINT fk_score_animal FOREIGN KEY (animal_id) REFERENCES tb_animais(id) ON DELETE CASCADE;

-- tb_carteirinhas
ALTER TABLE tb_carteirinhas
    ADD CONSTRAINT fk_carteirinha_animal FOREIGN KEY (animal_id) REFERENCES tb_animais(id) ON DELETE CASCADE;

-- tb_vacinas_carteirinha
ALTER TABLE tb_vacinas_carteirinha
    ADD CONSTRAINT fk_vacina_carteirinha FOREIGN KEY (carteirinha_id) REFERENCES tb_carteirinhas(id) ON DELETE CASCADE;

-- tb_clinicas
ALTER TABLE tb_clinicas
    ADD CONSTRAINT fk_clinica_endereco FOREIGN KEY (endereco_id) REFERENCES tb_enderecos(id);

-- tb_horarios_clinica
ALTER TABLE tb_horarios_clinica
    ADD CONSTRAINT fk_horario_clinica FOREIGN KEY (clinica_id) REFERENCES tb_clinicas(id) ON DELETE CASCADE;

-- tb_veterinarios
ALTER TABLE tb_veterinarios
    ADD CONSTRAINT fk_vet_usuario FOREIGN KEY (usuario_id) REFERENCES tb_usuarios(id) ON DELETE CASCADE;

-- tb_vet_clinicas
ALTER TABLE tb_vet_clinicas
    ADD CONSTRAINT fk_vc_veterinario FOREIGN KEY (veterinario_id) REFERENCES tb_veterinarios(id) ON DELETE CASCADE;
ALTER TABLE tb_vet_clinicas
    ADD CONSTRAINT fk_vc_clinica     FOREIGN KEY (clinica_id)     REFERENCES tb_clinicas(id)      ON DELETE CASCADE;

-- tb_agendas_vet
ALTER TABLE tb_agendas_vet
    ADD CONSTRAINT fk_agenda_veterinario FOREIGN KEY (veterinario_id) REFERENCES tb_veterinarios(id) ON DELETE CASCADE;
ALTER TABLE tb_agendas_vet
    ADD CONSTRAINT fk_agenda_clinica     FOREIGN KEY (clinica_id)     REFERENCES tb_clinicas(id)     ON DELETE CASCADE;

-- tb_bloqueios_vet
ALTER TABLE tb_bloqueios_vet
    ADD CONSTRAINT fk_bloqueio_vet FOREIGN KEY (veterinario_id) REFERENCES tb_veterinarios(id) ON DELETE CASCADE;

-- tb_consultas
ALTER TABLE tb_consultas
    ADD CONSTRAINT fk_consulta_animal    FOREIGN KEY (animal_id)      REFERENCES tb_animais(id)      ON DELETE CASCADE;
ALTER TABLE tb_consultas
    ADD CONSTRAINT fk_consulta_dono      FOREIGN KEY (dono_id)        REFERENCES tb_usuarios(id);
ALTER TABLE tb_consultas
    ADD CONSTRAINT fk_consulta_vet       FOREIGN KEY (veterinario_id) REFERENCES tb_veterinarios(id);
ALTER TABLE tb_consultas
    ADD CONSTRAINT fk_consulta_clinica   FOREIGN KEY (clinica_id)     REFERENCES tb_clinicas(id);

-- tb_lembretes_consulta
ALTER TABLE tb_lembretes_consulta
    ADD CONSTRAINT fk_lembrete_consulta FOREIGN KEY (consulta_id) REFERENCES tb_consultas(id) ON DELETE CASCADE;

-- tb_eventos_saude
ALTER TABLE tb_eventos_saude
    ADD CONSTRAINT fk_evento_animal  FOREIGN KEY (animal_id)  REFERENCES tb_animais(id)  ON DELETE CASCADE;
ALTER TABLE tb_eventos_saude
    ADD CONSTRAINT fk_evento_criador FOREIGN KEY (criado_por) REFERENCES tb_usuarios(id);

-- tb_registros_vacina
ALTER TABLE tb_registros_vacina
    ADD CONSTRAINT fk_registro_animal  FOREIGN KEY (animal_id)      REFERENCES tb_animais(id)      ON DELETE CASCADE;
ALTER TABLE tb_registros_vacina
    ADD CONSTRAINT fk_registro_vet     FOREIGN KEY (veterinario_id) REFERENCES tb_veterinarios(id);
ALTER TABLE tb_registros_vacina
    ADD CONSTRAINT fk_registro_clinica FOREIGN KEY (clinica_id)     REFERENCES tb_clinicas(id);

-- tb_documentos_animal
ALTER TABLE tb_documentos_animal
    ADD CONSTRAINT fk_doc_animal   FOREIGN KEY (animal_id)   REFERENCES tb_animais(id)   ON DELETE CASCADE;
ALTER TABLE tb_documentos_animal
    ADD CONSTRAINT fk_doc_enviador FOREIGN KEY (enviado_por) REFERENCES tb_usuarios(id);

-- tb_notificacoes
ALTER TABLE tb_notificacoes
    ADD CONSTRAINT fk_notif_usuario FOREIGN KEY (usuario_id) REFERENCES tb_usuarios(id) ON DELETE CASCADE;

-- tb_avaliacoes
ALTER TABLE tb_avaliacoes
    ADD CONSTRAINT fk_avaliacao_avaliador FOREIGN KEY (avaliador_id) REFERENCES tb_usuarios(id);
ALTER TABLE tb_avaliacoes
    ADD CONSTRAINT fk_avaliacao_consulta  FOREIGN KEY (consulta_id)  REFERENCES tb_consultas(id);
