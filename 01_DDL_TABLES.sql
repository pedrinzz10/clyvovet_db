-- ============================================================
-- CLYVO VET -- BANCO DE DADOS ORACLE
-- Arquivo 01: DDL -- Criacao das Tabelas
-- Compativel com Oracle XE / SQL Developer
-- ============================================================

-- ============================================================
-- SEQUENCES (substitui AUTO INCREMENT do PostgreSQL)
-- ============================================================
CREATE SEQUENCE seq_log_erros           START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_enderecos           START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_usuarios            START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_animais             START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_donos_animal        START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_scores_saude        START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_carteirinhas        START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_vacinas_carteirinha START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_clinicas            START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_horarios_clinica    START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_veterinarios        START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_vet_clinicas        START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_agendas_vet         START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_bloqueios_vet       START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_consultas           START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_lembretes           START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_eventos_saude       START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_registros_vacina    START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_documentos          START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_notificacoes        START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_avaliacoes          START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

-- ============================================================
-- TABELA DE LOG DE ERROS (exigida pelo professor)
-- ============================================================
CREATE TABLE tb_log_erros (
    id              NUMBER          DEFAULT seq_log_erros.NEXTVAL PRIMARY KEY,
    nome_procedure  VARCHAR2(100)   NOT NULL,
    nome_usuario    VARCHAR2(100)   DEFAULT USER,
    data_erro       TIMESTAMP       DEFAULT SYSTIMESTAMP,
    codigo_erro     NUMBER,
    mensagem_erro   VARCHAR2(4000)
);

-- ============================================================
-- ENDERECOS (reutilizavel por clinicas e usuarios)
-- ============================================================
CREATE TABLE tb_enderecos (
    id          NUMBER        DEFAULT seq_enderecos.NEXTVAL PRIMARY KEY,
    logradouro  VARCHAR2(300) NOT NULL,
    bairro      VARCHAR2(150),
    cidade      VARCHAR2(100) NOT NULL,
    estado      VARCHAR2(50)  NOT NULL,
    cep         VARCHAR2(10),
    latitude    NUMBER(10,7),
    longitude   NUMBER(10,7),
    criado_em   TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL
);

-- ============================================================
-- 1. USUARIOS
-- perfil: dono=tutor, veterinario, admin_clinica, super_admin
-- ============================================================
CREATE TABLE tb_usuarios (
    id              NUMBER          DEFAULT seq_usuarios.NEXTVAL PRIMARY KEY,
    nome            VARCHAR2(150)   NOT NULL,
    email           VARCHAR2(200)   NOT NULL UNIQUE,
    telefone        VARCHAR2(20),
    senha_hash      VARCHAR2(255)   NOT NULL,
    perfil          VARCHAR2(20)    DEFAULT 'dono' NOT NULL,
    url_avatar      VARCHAR2(500),
    idioma          VARCHAR2(5)     DEFAULT 'pt' NOT NULL,
    ativo           NUMBER(1)       DEFAULT 1 NOT NULL,
    endereco_id     NUMBER,
    criado_em       TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    atualizado_em   TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT chk_usuario_perfil  CHECK (perfil IN ('dono','veterinario','admin_clinica','super_admin')),
    CONSTRAINT chk_usuario_idioma  CHECK (idioma IN ('pt','en','es')),
    CONSTRAINT chk_usuario_ativo   CHECK (ativo  IN (0,1)),
    CONSTRAINT fk_usuario_endereco FOREIGN KEY (endereco_id) REFERENCES tb_enderecos(id)
);

-- ============================================================
-- 2. ANIMAIS
-- especie: cao, gato, ave, reptil, roedor, fazenda, selvagem, outro
-- modalidade reflete as 3 modalidades da plataforma
-- ============================================================
CREATE TABLE tb_animais (
    id                  NUMBER          DEFAULT seq_animais.NEXTVAL PRIMARY KEY,
    nome                VARCHAR2(100)   NOT NULL,
    especie             VARCHAR2(30)    NOT NULL,
    raca                VARCHAR2(100),
    sexo                VARCHAR2(15),
    data_nascimento     DATE,
    cor                 VARCHAR2(80),
    peso_kg             NUMBER(5,2),
    codigo_microchip    VARCHAR2(50)    UNIQUE,
    url_foto            VARCHAR2(500),
    modalidade          VARCHAR2(15)    DEFAULT 'domestico' NOT NULL,
    ativo               NUMBER(1)       DEFAULT 1 NOT NULL,
    criado_em           TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT chk_animal_especie  CHECK (especie    IN ('cao','gato','ave','reptil','roedor','fazenda','selvagem','outro')),
    CONSTRAINT chk_animal_sexo     CHECK (sexo       IN ('macho','femea','desconhecido')),
    CONSTRAINT chk_animal_modal    CHECK (modalidade IN ('domestico','agropecuario','selvagem')),
    CONSTRAINT chk_animal_peso     CHECK (peso_kg > 0),
    CONSTRAINT chk_animal_ativo    CHECK (ativo IN (0,1))
);

-- ============================================================
-- 3. DONOS DO ANIMAL (um animal pode ter varios tutores)
-- ============================================================
CREATE TABLE tb_donos_animal (
    id          NUMBER       DEFAULT seq_donos_animal.NEXTVAL PRIMARY KEY,
    animal_id   NUMBER       NOT NULL,
    usuario_id  NUMBER       NOT NULL,
    papel       VARCHAR2(15) DEFAULT 'principal' NOT NULL,
    criado_em   TIMESTAMP    DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT fk_dono_animal  FOREIGN KEY (animal_id)  REFERENCES tb_animais(id)   ON DELETE CASCADE,
    CONSTRAINT fk_dono_usuario FOREIGN KEY (usuario_id) REFERENCES tb_usuarios(id)  ON DELETE CASCADE,
    CONSTRAINT uk_dono_animal  UNIQUE (animal_id, usuario_id),
    CONSTRAINT chk_dono_papel  CHECK (papel IN ('principal','secundario'))
);

-- ============================================================
-- 4. SCORE DE SAUDE DO ANIMAL (snapshots periodicos)
-- ============================================================
CREATE TABLE tb_scores_saude (
    id                  NUMBER      DEFAULT seq_scores_saude.NEXTVAL PRIMARY KEY,
    animal_id           NUMBER      NOT NULL,
    pontuacao           NUMBER(5,2) NOT NULL,
    pontuacao_nutricao  NUMBER(5,2),
    pontuacao_atividade NUMBER(5,2),
    pontuacao_vacina    NUMBER(5,2),
    registrado_em       TIMESTAMP   DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT fk_score_animal   FOREIGN KEY (animal_id) REFERENCES tb_animais(id) ON DELETE CASCADE,
    CONSTRAINT chk_pontuacao     CHECK (pontuacao           BETWEEN 0 AND 100),
    CONSTRAINT chk_nutricao      CHECK (pontuacao_nutricao  BETWEEN 0 AND 100),
    CONSTRAINT chk_atividade     CHECK (pontuacao_atividade BETWEEN 0 AND 100),
    CONSTRAINT chk_vacina_score  CHECK (pontuacao_vacina    BETWEEN 0 AND 100)
);

-- ============================================================
-- 5. CARTEIRINHA DIGITAL DO ANIMAL
-- ============================================================
CREATE TABLE tb_carteirinhas (
    id                  NUMBER       DEFAULT seq_carteirinhas.NEXTVAL PRIMARY KEY,
    animal_id           NUMBER       NOT NULL UNIQUE,
    token_qr_code       VARCHAR2(36) NOT NULL UNIQUE,
    numero_registro     VARCHAR2(50),
    certificado_em      TIMESTAMP    DEFAULT SYSTIMESTAMP,
    valido_ate          TIMESTAMP,
    publico             NUMBER(1)    DEFAULT 0 NOT NULL,
    CONSTRAINT fk_carteirinha_animal   FOREIGN KEY (animal_id) REFERENCES tb_animais(id) ON DELETE CASCADE,
    CONSTRAINT chk_carteirinha_publica CHECK (publico IN (0,1))
);

CREATE TABLE tb_vacinas_carteirinha (
    id              NUMBER        DEFAULT seq_vacinas_carteirinha.NEXTVAL PRIMARY KEY,
    carteirinha_id  NUMBER        NOT NULL,
    nome_vacina     VARCHAR2(150) NOT NULL,
    situacao        VARCHAR2(10)  DEFAULT 'pendente' NOT NULL,
    aplicada_em     DATE,
    valida_ate      DATE,
    CONSTRAINT fk_vacina_carteirinha FOREIGN KEY (carteirinha_id) REFERENCES tb_carteirinhas(id) ON DELETE CASCADE,
    CONSTRAINT chk_vacina_situacao   CHECK (situacao IN ('ok','pendente','vencida'))
);

-- ============================================================
-- 6. CLINICAS
-- ============================================================
CREATE TABLE tb_clinicas (
    id                  NUMBER        DEFAULT seq_clinicas.NEXTVAL PRIMARY KEY,
    nome                VARCHAR2(200) NOT NULL,
    endereco_id         NUMBER        NOT NULL,
    telefone            VARCHAR2(20),
    email               VARCHAR2(200),
    url_logo            VARCHAR2(500),
    parceira            NUMBER(1)     DEFAULT 0 NOT NULL,
    atende_domicilio    NUMBER(1)     DEFAULT 0 NOT NULL,
    aberta_24h          NUMBER(1)     DEFAULT 0 NOT NULL,
    media_avaliacao     NUMBER(3,2)   DEFAULT 0,
    total_avaliacoes    NUMBER        DEFAULT 0,
    ativo               NUMBER(1)     DEFAULT 1 NOT NULL,
    criado_em           TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT chk_clinica_parceira   CHECK (parceira         IN (0,1)),
    CONSTRAINT chk_clinica_domicilio  CHECK (atende_domicilio IN (0,1)),
    CONSTRAINT chk_clinica_24h        CHECK (aberta_24h       IN (0,1)),
    CONSTRAINT chk_clinica_avaliacao  CHECK (media_avaliacao  BETWEEN 0 AND 5),
    CONSTRAINT chk_clinica_ativo      CHECK (ativo            IN (0,1)),
    CONSTRAINT fk_clinica_endereco    FOREIGN KEY (endereco_id) REFERENCES tb_enderecos(id)
);

CREATE TABLE tb_horarios_clinica (
    id          NUMBER      DEFAULT seq_horarios_clinica.NEXTVAL PRIMARY KEY,
    clinica_id  NUMBER      NOT NULL,
    dia_semana  NUMBER(1)   NOT NULL,
    abre_as     VARCHAR2(5),
    fecha_as    VARCHAR2(5),
    fechado     NUMBER(1)   DEFAULT 0 NOT NULL,
    CONSTRAINT fk_horario_clinica  FOREIGN KEY (clinica_id) REFERENCES tb_clinicas(id) ON DELETE CASCADE,
    CONSTRAINT chk_horario_dia     CHECK (dia_semana BETWEEN 0 AND 6),
    CONSTRAINT chk_horario_fechado CHECK (fechado    IN (0,1)),
    CONSTRAINT uk_clinica_dia      UNIQUE (clinica_id, dia_semana)
);

-- ============================================================
-- 7. VETERINARIOS
-- ============================================================
CREATE TABLE tb_veterinarios (
    id                  NUMBER        DEFAULT seq_veterinarios.NEXTVAL PRIMARY KEY,
    usuario_id          NUMBER        NOT NULL UNIQUE,
    nome                VARCHAR2(150) NOT NULL,
    crm                 VARCHAR2(30)  NOT NULL UNIQUE,
    especialidade       VARCHAR2(100),
    biografia           VARCHAR2(1000),
    anos_experiencia    NUMBER(3)     DEFAULT 0,
    url_foto            VARCHAR2(500),
    media_avaliacao     NUMBER(3,2)   DEFAULT 0,
    disponivel          NUMBER(1)     DEFAULT 1 NOT NULL,
    criado_em           TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT fk_vet_usuario     FOREIGN KEY (usuario_id) REFERENCES tb_usuarios(id) ON DELETE CASCADE,
    CONSTRAINT chk_vet_avaliacao  CHECK (media_avaliacao BETWEEN 0 AND 5),
    CONSTRAINT chk_vet_disponivel CHECK (disponivel       IN (0,1))
);

-- veterinario pode atuar em multiplas clinicas
CREATE TABLE tb_vet_clinicas (
    id              NUMBER    DEFAULT seq_vet_clinicas.NEXTVAL PRIMARY KEY,
    veterinario_id  NUMBER    NOT NULL,
    clinica_id      NUMBER    NOT NULL,
    principal       NUMBER(1) DEFAULT 0 NOT NULL,
    criado_em       TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT fk_vc_veterinario FOREIGN KEY (veterinario_id) REFERENCES tb_veterinarios(id) ON DELETE CASCADE,
    CONSTRAINT fk_vc_clinica     FOREIGN KEY (clinica_id)     REFERENCES tb_clinicas(id)      ON DELETE CASCADE,
    CONSTRAINT uk_vet_clinica    UNIQUE (veterinario_id, clinica_id),
    CONSTRAINT chk_vc_principal  CHECK (principal IN (0,1))
);

CREATE TABLE tb_agendas_vet (
    id               NUMBER      DEFAULT seq_agendas_vet.NEXTVAL PRIMARY KEY,
    veterinario_id   NUMBER      NOT NULL,
    clinica_id       NUMBER      NOT NULL,
    dia_semana       NUMBER(1)   NOT NULL,
    hora_inicio      VARCHAR2(5) NOT NULL,
    hora_fim         VARCHAR2(5) NOT NULL,
    duracao_slot_min NUMBER(3)   DEFAULT 30 NOT NULL,
    max_slots        NUMBER(3)   DEFAULT 8  NOT NULL,
    ativo            NUMBER(1)   DEFAULT 1  NOT NULL,
    CONSTRAINT fk_agenda_veterinario FOREIGN KEY (veterinario_id) REFERENCES tb_veterinarios(id) ON DELETE CASCADE,
    CONSTRAINT fk_agenda_clinica     FOREIGN KEY (clinica_id)     REFERENCES tb_clinicas(id)      ON DELETE CASCADE,
    CONSTRAINT chk_agenda_dia        CHECK (dia_semana      BETWEEN 0 AND 6),
    CONSTRAINT chk_agenda_slot       CHECK (duracao_slot_min > 0),
    CONSTRAINT chk_agenda_ativo      CHECK (ativo           IN (0,1))
);

CREATE TABLE tb_bloqueios_vet (
    id              NUMBER       DEFAULT seq_bloqueios_vet.NEXTVAL PRIMARY KEY,
    veterinario_id  NUMBER       NOT NULL,
    data_bloqueio   DATE         NOT NULL,
    hora_inicio     VARCHAR2(5)  NOT NULL,
    hora_fim        VARCHAR2(5)  NOT NULL,
    motivo          VARCHAR2(200),
    CONSTRAINT fk_bloqueio_vet FOREIGN KEY (veterinario_id) REFERENCES tb_veterinarios(id) ON DELETE CASCADE
);

-- ============================================================
-- 8. CONSULTAS
-- ============================================================
CREATE TABLE tb_consultas (
    id                  NUMBER        DEFAULT seq_consultas.NEXTVAL PRIMARY KEY,
    animal_id           NUMBER        NOT NULL,
    dono_id             NUMBER        NOT NULL,
    veterinario_id      NUMBER        NOT NULL,
    clinica_id          NUMBER        NOT NULL,
    especialidade       VARCHAR2(100),
    data_consulta       DATE          NOT NULL,
    hora_consulta       VARCHAR2(5)   NOT NULL,
    duracao_min         NUMBER(3)     DEFAULT 30 NOT NULL,
    tipo_atendimento    VARCHAR2(15)  DEFAULT 'presencial' NOT NULL,
    situacao            VARCHAR2(15)  DEFAULT 'agendada' NOT NULL,
    observacoes_dono    VARCHAR2(1000),
    observacoes_vet     VARCHAR2(2000),
    motivo_cancelamento VARCHAR2(500),
    criado_em           TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    atualizado_em       TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT fk_consulta_animal    FOREIGN KEY (animal_id)      REFERENCES tb_animais(id)      ON DELETE CASCADE,
    CONSTRAINT fk_consulta_dono      FOREIGN KEY (dono_id)        REFERENCES tb_usuarios(id),
    CONSTRAINT fk_consulta_vet       FOREIGN KEY (veterinario_id) REFERENCES tb_veterinarios(id),
    CONSTRAINT fk_consulta_clinica   FOREIGN KEY (clinica_id)     REFERENCES tb_clinicas(id),
    CONSTRAINT chk_consulta_tipo     CHECK (tipo_atendimento IN ('presencial','domiciliar')),
    CONSTRAINT chk_consulta_situacao CHECK (situacao         IN ('agendada','confirmada','concluida','cancelada','ausente'))
);

CREATE TABLE tb_lembretes_consulta (
    id          NUMBER       DEFAULT seq_lembretes.NEXTVAL PRIMARY KEY,
    consulta_id NUMBER       NOT NULL,
    lembrar_em  TIMESTAMP    NOT NULL,
    canal       VARCHAR2(10) DEFAULT 'push' NOT NULL,
    enviado_em  TIMESTAMP,
    situacao    VARCHAR2(10) DEFAULT 'pendente' NOT NULL,
    CONSTRAINT fk_lembrete_consulta  FOREIGN KEY (consulta_id) REFERENCES tb_consultas(id) ON DELETE CASCADE,
    CONSTRAINT chk_lembrete_canal    CHECK (canal    IN ('push','email','sms','whatsapp')),
    CONSTRAINT chk_lembrete_situacao CHECK (situacao IN ('pendente','enviado','falhou'))
);

-- ============================================================
-- 9. EVENTOS DE SAUDE & VACINAS
-- ============================================================
CREATE TABLE tb_eventos_saude (
    id              NUMBER        DEFAULT seq_eventos_saude.NEXTVAL PRIMARY KEY,
    animal_id       NUMBER        NOT NULL,
    tipo            VARCHAR2(20)  NOT NULL,
    nome            VARCHAR2(200) NOT NULL,
    descricao       VARCHAR2(1000),
    data_prevista   DATE,
    realizado_em    DATE,
    situacao        VARCHAR2(15)  DEFAULT 'pendente' NOT NULL,
    cor_etiqueta    VARCHAR2(10),
    criado_por      NUMBER,
    criado_em       TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT fk_evento_animal   FOREIGN KEY (animal_id)  REFERENCES tb_animais(id)   ON DELETE CASCADE,
    CONSTRAINT fk_evento_criador  FOREIGN KEY (criado_por) REFERENCES tb_usuarios(id),
    CONSTRAINT chk_evento_tipo    CHECK (tipo    IN ('vacina','vermifugacao','exame','consulta','medicamento','outro')),
    CONSTRAINT chk_evento_situacao CHECK (situacao IN ('pendente','urgente','concluido','agendado'))
);

CREATE TABLE tb_registros_vacina (
    id                  NUMBER        DEFAULT seq_registros_vacina.NEXTVAL PRIMARY KEY,
    animal_id           NUMBER        NOT NULL,
    veterinario_id      NUMBER,
    clinica_id          NUMBER,
    nome_vacina         VARCHAR2(150) NOT NULL,
    numero_lote         VARCHAR2(50),
    data_aplicacao      DATE          NOT NULL,
    data_proxima_dose   DATE,
    criado_em           TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT fk_registro_animal  FOREIGN KEY (animal_id)      REFERENCES tb_animais(id)      ON DELETE CASCADE,
    CONSTRAINT fk_registro_vet     FOREIGN KEY (veterinario_id) REFERENCES tb_veterinarios(id),
    CONSTRAINT fk_registro_clinica FOREIGN KEY (clinica_id)     REFERENCES tb_clinicas(id)
);

-- ============================================================
-- 10. DOCUMENTOS DO ANIMAL
-- ============================================================
CREATE TABLE tb_documentos_animal (
    id              NUMBER        DEFAULT seq_documentos.NEXTVAL PRIMARY KEY,
    animal_id       NUMBER        NOT NULL,
    tipo            VARCHAR2(25)  NOT NULL,
    nome            VARCHAR2(200) NOT NULL,
    url_arquivo     VARCHAR2(500),
    tamanho_bytes   NUMBER,
    tipo_mime       VARCHAR2(100),
    idioma          VARCHAR2(5)   DEFAULT 'pt',
    emitido_em      DATE,
    valido_ate      DATE,
    enviado_por     NUMBER,
    criado_em       TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT fk_doc_animal   FOREIGN KEY (animal_id)   REFERENCES tb_animais(id)   ON DELETE CASCADE,
    CONSTRAINT fk_doc_enviador FOREIGN KEY (enviado_por) REFERENCES tb_usuarios(id),
    CONSTRAINT chk_doc_tipo    CHECK (tipo   IN ('carteirinha_vacinal','exame','receita','certificado','raio_x','legal','outro')),
    CONSTRAINT chk_doc_idioma  CHECK (idioma IN ('pt','en','es'))
);

-- ============================================================
-- 11. NOTIFICACOES
-- ============================================================
CREATE TABLE tb_notificacoes (
    id              NUMBER        DEFAULT seq_notificacoes.NEXTVAL PRIMARY KEY,
    usuario_id      NUMBER        NOT NULL,
    tipo            VARCHAR2(50)  NOT NULL,
    titulo          VARCHAR2(200) NOT NULL,
    mensagem        VARCHAR2(1000),
    lido            NUMBER(1)     DEFAULT 0 NOT NULL,
    tipo_entidade   VARCHAR2(50),
    id_entidade     NUMBER,
    criado_em       TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT fk_notif_usuario FOREIGN KEY (usuario_id) REFERENCES tb_usuarios(id) ON DELETE CASCADE,
    CONSTRAINT chk_notif_tipo   CHECK (tipo IN (
        'vacina_vencendo','lembrete_consulta','consulta_confirmada',
        'consulta_cancelada','nova_clinica','alerta_saude',
        'alerta_raca','lembrete_medicamento','documento_pronto','outro'
    )),
    CONSTRAINT chk_notif_lido   CHECK (lido IN (0,1))
);

-- ============================================================
-- 12. AVALIACOES
-- ============================================================
CREATE TABLE tb_avaliacoes (
    id              NUMBER        DEFAULT seq_avaliacoes.NEXTVAL PRIMARY KEY,
    avaliador_id    NUMBER        NOT NULL,
    tipo_alvo       VARCHAR2(15)  NOT NULL,
    id_alvo         NUMBER        NOT NULL,
    consulta_id     NUMBER,
    nota            NUMBER(2)     NOT NULL,
    comentario      VARCHAR2(2000),
    criado_em       TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT fk_avaliacao_avaliador FOREIGN KEY (avaliador_id) REFERENCES tb_usuarios(id),
    CONSTRAINT fk_avaliacao_consulta  FOREIGN KEY (consulta_id)  REFERENCES tb_consultas(id),
    CONSTRAINT chk_avaliacao_alvo     CHECK (tipo_alvo IN ('clinica','veterinario')),
    CONSTRAINT chk_avaliacao_nota     CHECK (nota      BETWEEN 1 AND 5)
);
