-- ============================================================
-- CLYVO VET -- BANCO DE DADOS ORACLE
-- Arquivo 04: Procedures de Carga de Dados
-- Todas com: parametros, EXCEPTION WHEN OTHERS,
--            2 excecoes especificas e log de erros
-- ============================================================

-- ------------------------------------------------------------
-- PROCEDURE: prc_inserir_usuario
-- ------------------------------------------------------------
CREATE OR REPLACE PROCEDURE prc_inserir_usuario (
    p_nome       IN VARCHAR2,
    p_email      IN VARCHAR2,
    p_telefone   IN VARCHAR2,
    p_senha_hash IN VARCHAR2,
    p_perfil     IN VARCHAR2 DEFAULT 'dono',
    p_idioma     IN VARCHAR2 DEFAULT 'pt'
) AS
    v_contador NUMBER;
BEGIN
    -- Excecao 1: email duplicado
    SELECT COUNT(*) INTO v_contador
    FROM tb_usuarios
    WHERE email = p_email;

    IF v_contador > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Email ja cadastrado: ' || p_email);
    END IF;

    -- Excecao 2: perfil invalido
    IF p_perfil NOT IN ('dono','veterinario','admin_clinica','super_admin') THEN
        RAISE_APPLICATION_ERROR(-20002, 'Perfil invalido: ' || p_perfil);
    END IF;

    INSERT INTO tb_usuarios (nome, email, telefone, senha_hash, perfil, idioma)
    VALUES (p_nome, p_email, p_telefone, p_senha_hash, p_perfil, p_idioma);

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        INSERT INTO tb_log_erros (nome_procedure, codigo_erro, mensagem_erro)
        VALUES ('prc_inserir_usuario', SQLCODE, SQLERRM);
        COMMIT;
        RAISE;
END prc_inserir_usuario;
/

-- ------------------------------------------------------------
-- PROCEDURE: prc_inserir_animal
-- ------------------------------------------------------------
CREATE OR REPLACE PROCEDURE prc_inserir_animal (
    p_nome             IN VARCHAR2,
    p_especie          IN VARCHAR2,
    p_raca             IN VARCHAR2,
    p_sexo             IN VARCHAR2,
    p_data_nascimento  IN DATE,
    p_cor              IN VARCHAR2,
    p_peso_kg          IN NUMBER,
    p_codigo_microchip IN VARCHAR2,
    p_url_foto         IN VARCHAR2,
    p_modalidade       IN VARCHAR2 DEFAULT 'domestico',
    p_dono_id          IN NUMBER
) AS
    v_animal_id NUMBER;
    v_contador  NUMBER;
BEGIN
    -- Excecao 1: microchip duplicado
    IF p_codigo_microchip IS NOT NULL THEN
        SELECT COUNT(*) INTO v_contador
        FROM tb_animais
        WHERE codigo_microchip = p_codigo_microchip;

        IF v_contador > 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Microchip ja cadastrado: ' || p_codigo_microchip);
        END IF;
    END IF;

    -- Excecao 2: tutor nao existe
    SELECT COUNT(*) INTO v_contador
    FROM tb_usuarios
    WHERE id = p_dono_id AND perfil = 'dono';

    IF v_contador = 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Tutor nao encontrado com id: ' || p_dono_id);
    END IF;

    INSERT INTO tb_animais (nome, especie, raca, sexo, data_nascimento, cor, peso_kg,
                            codigo_microchip, url_foto, modalidade)
    VALUES (p_nome, p_especie, p_raca, p_sexo, p_data_nascimento, p_cor,
            p_peso_kg, p_codigo_microchip, p_url_foto, p_modalidade)
    RETURNING id INTO v_animal_id;

    -- Associa o tutor principal ao animal
    INSERT INTO tb_donos_animal (animal_id, usuario_id, papel)
    VALUES (v_animal_id, p_dono_id, 'principal');

    -- Cria carteirinha digital automaticamente
    INSERT INTO tb_carteirinhas (animal_id, token_qr_code, certificado_em, valido_ate, publico)
    VALUES (v_animal_id,
            LOWER(RAWTOHEX(SYS_GUID())),
            SYSTIMESTAMP,
            SYSTIMESTAMP + INTERVAL '365' DAY,
            0);

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        INSERT INTO tb_log_erros (nome_procedure, codigo_erro, mensagem_erro)
        VALUES ('prc_inserir_animal', SQLCODE, SQLERRM);
        COMMIT;
        RAISE;
END prc_inserir_animal;
/

-- ------------------------------------------------------------
-- PROCEDURE: prc_inserir_clinica
-- ------------------------------------------------------------
CREATE OR REPLACE PROCEDURE prc_inserir_clinica (
    p_nome              IN VARCHAR2,
    p_endereco          IN VARCHAR2,
    p_cidade            IN VARCHAR2,
    p_estado            IN VARCHAR2,
    p_latitude          IN NUMBER,
    p_longitude         IN NUMBER,
    p_telefone          IN VARCHAR2,
    p_email             IN VARCHAR2,
    p_parceira          IN NUMBER   DEFAULT 1,
    p_atende_domicilio  IN NUMBER   DEFAULT 0,
    p_aberta_24h        IN NUMBER   DEFAULT 0,
    p_bairro            IN VARCHAR2 DEFAULT NULL,
    p_cep               IN VARCHAR2 DEFAULT NULL
) AS
    v_contador    NUMBER;
    v_endereco_id NUMBER;
BEGIN
    -- Excecao 1: coordenadas invalidas
    IF p_latitude NOT BETWEEN -90 AND 90 OR p_longitude NOT BETWEEN -180 AND 180 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Coordenadas geograficas invalidas');
    END IF;

    -- Excecao 2: clinica com mesmo nome e cidade ja existe
    SELECT COUNT(*) INTO v_contador
    FROM tb_clinicas c
    JOIN tb_enderecos e ON e.id = c.endereco_id
    WHERE UPPER(c.nome) = UPPER(p_nome) AND UPPER(e.cidade) = UPPER(p_cidade);

    IF v_contador > 0 THEN
        RAISE_APPLICATION_ERROR(-20006, 'Clinica ja cadastrada nesta cidade: ' || p_nome);
    END IF;

    INSERT INTO tb_enderecos (logradouro, bairro, cidade, estado, cep, latitude, longitude)
    VALUES (p_endereco, p_bairro, p_cidade, p_estado, p_cep, p_latitude, p_longitude)
    RETURNING id INTO v_endereco_id;

    INSERT INTO tb_clinicas (nome, endereco_id, telefone, email, parceira, atende_domicilio, aberta_24h)
    VALUES (p_nome, v_endereco_id, p_telefone, p_email, p_parceira, p_atende_domicilio, p_aberta_24h);

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        INSERT INTO tb_log_erros (nome_procedure, codigo_erro, mensagem_erro)
        VALUES ('prc_inserir_clinica', SQLCODE, SQLERRM);
        COMMIT;
        RAISE;
END prc_inserir_clinica;
/

-- ------------------------------------------------------------
-- PROCEDURE: prc_inserir_veterinario
-- ------------------------------------------------------------
CREATE OR REPLACE PROCEDURE prc_inserir_veterinario (
    p_nome              IN VARCHAR2,
    p_email             IN VARCHAR2,
    p_telefone          IN VARCHAR2,
    p_crm               IN VARCHAR2,
    p_especialidade     IN VARCHAR2,
    p_biografia         IN VARCHAR2,
    p_anos_experiencia  IN NUMBER,
    p_clinica_id        IN NUMBER
) AS
    v_usuario_id    NUMBER;
    v_veterinario_id NUMBER;
    v_contador      NUMBER;
BEGIN
    -- Excecao 1: CRM duplicado
    SELECT COUNT(*) INTO v_contador FROM tb_veterinarios WHERE crm = p_crm;
    IF v_contador > 0 THEN
        RAISE_APPLICATION_ERROR(-20007, 'CRM ja cadastrado: ' || p_crm);
    END IF;

    -- Excecao 2: clinica nao existe ou inativa
    SELECT COUNT(*) INTO v_contador FROM tb_clinicas WHERE id = p_clinica_id AND ativo = 1;
    IF v_contador = 0 THEN
        RAISE_APPLICATION_ERROR(-20008, 'Clinica nao encontrada com id: ' || p_clinica_id);
    END IF;

    -- Cria usuario com perfil veterinario
    INSERT INTO tb_usuarios (nome, email, telefone, senha_hash, perfil)
    VALUES (p_nome, p_email, p_telefone, 'changeme123', 'veterinario')
    RETURNING id INTO v_usuario_id;

    -- Cria registro de veterinario
    INSERT INTO tb_veterinarios (usuario_id, nome, crm, especialidade, biografia, anos_experiencia)
    VALUES (v_usuario_id, p_nome, p_crm, p_especialidade, p_biografia, p_anos_experiencia)
    RETURNING id INTO v_veterinario_id;

    -- Associa veterinario a clinica como principal
    INSERT INTO tb_vet_clinicas (veterinario_id, clinica_id, principal)
    VALUES (v_veterinario_id, p_clinica_id, 1);

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        INSERT INTO tb_log_erros (nome_procedure, codigo_erro, mensagem_erro)
        VALUES ('prc_inserir_veterinario', SQLCODE, SQLERRM);
        COMMIT;
        RAISE;
END prc_inserir_veterinario;
/

-- ------------------------------------------------------------
-- PROCEDURE: prc_inserir_consulta
-- ------------------------------------------------------------
CREATE OR REPLACE PROCEDURE prc_inserir_consulta (
    p_animal_id         IN NUMBER,
    p_dono_id           IN NUMBER,
    p_veterinario_id    IN NUMBER,
    p_clinica_id        IN NUMBER,
    p_especialidade     IN VARCHAR2,
    p_data              IN DATE,
    p_hora              IN VARCHAR2,
    p_duracao_min       IN NUMBER DEFAULT 30,
    p_tipo_atendimento  IN VARCHAR2 DEFAULT 'presencial',
    p_observacoes       IN VARCHAR2 DEFAULT NULL
) AS
    v_contador   NUMBER;
    v_consulta_id NUMBER;
BEGIN
    -- Excecao 1: horario ja ocupado para este veterinario
    SELECT COUNT(*) INTO v_contador
    FROM tb_consultas
    WHERE veterinario_id  = p_veterinario_id
      AND data_consulta   = p_data
      AND hora_consulta   = p_hora
      AND situacao NOT IN ('cancelada');

    IF v_contador > 0 THEN
        RAISE_APPLICATION_ERROR(-20009, 'Horario ja ocupado para este veterinario');
    END IF;

    -- Excecao 2: data no passado
    IF p_data < TRUNC(SYSDATE) THEN
        RAISE_APPLICATION_ERROR(-20010, 'Nao e possivel agendar para uma data no passado');
    END IF;

    INSERT INTO tb_consultas (
        animal_id, dono_id, veterinario_id, clinica_id, especialidade,
        data_consulta, hora_consulta, duracao_min,
        tipo_atendimento, situacao, observacoes_dono
    ) VALUES (
        p_animal_id, p_dono_id, p_veterinario_id, p_clinica_id, p_especialidade,
        p_data, p_hora, p_duracao_min,
        p_tipo_atendimento, 'agendada', p_observacoes
    ) RETURNING id INTO v_consulta_id;

    -- Cria lembretes automaticos: 3 dias, 1 dia e 2 horas antes
    INSERT INTO tb_lembretes_consulta (consulta_id, lembrar_em, canal)
    VALUES (v_consulta_id,
            TO_TIMESTAMP(p_data||' '||p_hora,'DD/MM/YYYY HH24:MI') - INTERVAL '3' DAY,
            'whatsapp');

    INSERT INTO tb_lembretes_consulta (consulta_id, lembrar_em, canal)
    VALUES (v_consulta_id,
            TO_TIMESTAMP(p_data||' '||p_hora,'DD/MM/YYYY HH24:MI') - INTERVAL '1' DAY,
            'whatsapp');

    INSERT INTO tb_lembretes_consulta (consulta_id, lembrar_em, canal)
    VALUES (v_consulta_id,
            TO_TIMESTAMP(p_data||' '||p_hora,'DD/MM/YYYY HH24:MI') - INTERVAL '2' HOUR,
            'push');

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        INSERT INTO tb_log_erros (nome_procedure, codigo_erro, mensagem_erro)
        VALUES ('prc_inserir_consulta', SQLCODE, SQLERRM);
        COMMIT;
        RAISE;
END prc_inserir_consulta;
/

-- ------------------------------------------------------------
-- PROCEDURE: prc_inserir_evento_saude
-- ------------------------------------------------------------
CREATE OR REPLACE PROCEDURE prc_inserir_evento_saude (
    p_animal_id     IN NUMBER,
    p_tipo          IN VARCHAR2,
    p_nome          IN VARCHAR2,
    p_descricao     IN VARCHAR2,
    p_data_prevista IN DATE,
    p_realizado_em  IN DATE     DEFAULT NULL,
    p_situacao      IN VARCHAR2 DEFAULT 'pendente',
    p_criado_por    IN NUMBER   DEFAULT NULL
) AS
    v_contador NUMBER;
BEGIN
    -- Excecao 1: animal nao existe ou inativo
    SELECT COUNT(*) INTO v_contador FROM tb_animais WHERE id = p_animal_id AND ativo = 1;
    IF v_contador = 0 THEN
        RAISE_APPLICATION_ERROR(-20011, 'Animal nao encontrado com id: ' || p_animal_id);
    END IF;

    -- Excecao 2: tipo invalido
    IF p_tipo NOT IN ('vacina','vermifugacao','exame','consulta','medicamento','outro') THEN
        RAISE_APPLICATION_ERROR(-20012, 'Tipo de evento invalido: ' || p_tipo);
    END IF;

    INSERT INTO tb_eventos_saude (animal_id, tipo, nome, descricao, data_prevista,
                                  realizado_em, situacao, criado_por)
    VALUES (p_animal_id, p_tipo, p_nome, p_descricao, p_data_prevista,
            p_realizado_em, p_situacao, p_criado_por);

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        INSERT INTO tb_log_erros (nome_procedure, codigo_erro, mensagem_erro)
        VALUES ('prc_inserir_evento_saude', SQLCODE, SQLERRM);
        COMMIT;
        RAISE;
END prc_inserir_evento_saude;
/

-- ------------------------------------------------------------
-- PROCEDURE: prc_inserir_registro_vacina
-- ------------------------------------------------------------
CREATE OR REPLACE PROCEDURE prc_inserir_registro_vacina (
    p_animal_id         IN NUMBER,
    p_veterinario_id    IN NUMBER,
    p_clinica_id        IN NUMBER,
    p_nome_vacina       IN VARCHAR2,
    p_numero_lote       IN VARCHAR2,
    p_data_aplicacao    IN DATE,
    p_proxima_dose      IN DATE DEFAULT NULL
) AS
    v_contador NUMBER;
BEGIN
    -- Excecao 1: data de aplicacao no futuro
    IF p_data_aplicacao > SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20013, 'Data de aplicacao nao pode ser no futuro');
    END IF;

    -- Excecao 2: proxima dose anterior a data de aplicacao
    IF p_proxima_dose IS NOT NULL AND p_proxima_dose <= p_data_aplicacao THEN
        RAISE_APPLICATION_ERROR(-20014, 'Proxima dose deve ser posterior a data de aplicacao');
    END IF;

    INSERT INTO tb_registros_vacina (animal_id, veterinario_id, clinica_id, nome_vacina,
                                     numero_lote, data_aplicacao, data_proxima_dose)
    VALUES (p_animal_id, p_veterinario_id, p_clinica_id, p_nome_vacina,
            p_numero_lote, p_data_aplicacao, p_proxima_dose);

    -- Atualiza o evento de saude correspondente se existir
    UPDATE tb_eventos_saude
    SET situacao     = 'concluido',
        realizado_em = p_data_aplicacao
    WHERE animal_id = p_animal_id
      AND tipo      = 'vacina'
      AND UPPER(nome) = UPPER(p_nome_vacina)
      AND situacao IN ('pendente','urgente');

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        INSERT INTO tb_log_erros (nome_procedure, codigo_erro, mensagem_erro)
        VALUES ('prc_inserir_registro_vacina', SQLCODE, SQLERRM);
        COMMIT;
        RAISE;
END prc_inserir_registro_vacina;
/
