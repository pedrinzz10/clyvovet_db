-- ============================================================
-- CLYVO VET -- BANCO DE DADOS ORACLE
-- Arquivo 04: Procedures de Carga de Dados
-- Padrao: parametros, 2 excecoes especificas, EXCEPTION WHEN OTHERS,
--         ROLLBACK + log em tb_log_erros em caso de falha
-- ============================================================

-- ------------------------------------------------------------
-- PROCEDURE: prc_inserir_tutor
-- ------------------------------------------------------------
CREATE OR REPLACE PROCEDURE prc_inserir_tutor (
    p_nome      IN VARCHAR2,
    p_email     IN VARCHAR2,
    p_cpf       IN VARCHAR2  DEFAULT NULL,
    p_telefone  IN VARCHAR2  DEFAULT NULL,
    p_data_nasc IN DATE      DEFAULT NULL,
    p_sexo      IN VARCHAR2  DEFAULT NULL,
    p_logradouro IN VARCHAR2 DEFAULT NULL,
    p_numero    IN VARCHAR2  DEFAULT NULL,
    p_bairro    IN VARCHAR2  DEFAULT NULL,
    p_cidade    IN VARCHAR2  DEFAULT NULL,
    p_estado    IN VARCHAR2  DEFAULT NULL,
    p_cep       IN VARCHAR2  DEFAULT NULL
) AS
    v_contador NUMBER;
BEGIN
    -- Excecao 1: email duplicado
    SELECT COUNT(*) INTO v_contador FROM tutor WHERE email = p_email;
    IF v_contador > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Email ja cadastrado: ' || p_email);
    END IF;

    -- Excecao 2: CPF duplicado
    IF p_cpf IS NOT NULL THEN
        SELECT COUNT(*) INTO v_contador FROM tutor WHERE cpf = p_cpf;
        IF v_contador > 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'CPF ja cadastrado: ' || p_cpf);
        END IF;
    END IF;

    INSERT INTO tutor (nome, email, cpf, telefone, data_nascimento, sexo,
                       logradouro, numero, bairro, cidade, estado, cep)
    VALUES (p_nome, p_email, p_cpf, p_telefone, p_data_nasc, p_sexo,
            p_logradouro, p_numero, p_bairro, p_cidade, p_estado, p_cep);

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        INSERT INTO tb_log_erros (nome_procedure, codigo_erro, mensagem_erro)
        VALUES ('prc_inserir_tutor', SQLCODE, SQLERRM);
        COMMIT;
        RAISE;
END prc_inserir_tutor;
/

-- ------------------------------------------------------------
-- PROCEDURE: prc_inserir_animal
-- ------------------------------------------------------------
CREATE OR REPLACE PROCEDURE prc_inserir_animal (
    p_nome      IN VARCHAR2,
    p_especie   IN VARCHAR2,
    p_raca      IN VARCHAR2  DEFAULT NULL,
    p_porte     IN VARCHAR2  DEFAULT NULL,
    p_cor       IN VARCHAR2  DEFAULT NULL,
    p_sexo      IN VARCHAR2  DEFAULT NULL,
    p_data_nasc IN DATE      DEFAULT NULL,
    p_observacao IN VARCHAR2 DEFAULT NULL,
    p_tutor_id  IN VARCHAR2
) AS
    v_contador NUMBER;
BEGIN
    -- Excecao 1: tutor nao existe
    SELECT COUNT(*) INTO v_contador FROM tutor WHERE id = p_tutor_id;
    IF v_contador = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Tutor nao encontrado: ' || p_tutor_id);
    END IF;

    -- Excecao 2: especie invalida
    IF p_especie NOT IN ('CAO','GATO','AVE','REPTIL','ROEDOR','OUTRO') THEN
        RAISE_APPLICATION_ERROR(-20004, 'Especie invalida: ' || p_especie);
    END IF;

    INSERT INTO animal (nome, especie, raca, porte, cor, sexo,
                        data_nascimento, observacao, tutor_id)
    VALUES (p_nome, p_especie, p_raca, p_porte, p_cor, p_sexo,
            p_data_nasc, p_observacao, p_tutor_id);

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
    p_nome      IN VARCHAR2,
    p_cnpj      IN VARCHAR2  DEFAULT NULL,
    p_telefone  IN VARCHAR2  DEFAULT NULL,
    p_email     IN VARCHAR2  DEFAULT NULL,
    p_logradouro IN VARCHAR2 DEFAULT NULL,
    p_numero    IN VARCHAR2  DEFAULT NULL,
    p_bairro    IN VARCHAR2  DEFAULT NULL,
    p_cidade    IN VARCHAR2  DEFAULT NULL,
    p_estado    IN VARCHAR2  DEFAULT NULL,
    p_cep       IN VARCHAR2  DEFAULT NULL
) AS
    v_contador NUMBER;
BEGIN
    -- Excecao 1: CNPJ duplicado
    IF p_cnpj IS NOT NULL THEN
        SELECT COUNT(*) INTO v_contador FROM clinica WHERE cnpj = p_cnpj;
        IF v_contador > 0 THEN
            RAISE_APPLICATION_ERROR(-20005, 'CNPJ ja cadastrado: ' || p_cnpj);
        END IF;
    END IF;

    -- Excecao 2: clinica com mesmo nome e cidade ja existe
    SELECT COUNT(*) INTO v_contador
    FROM clinica
    WHERE UPPER(nome) = UPPER(p_nome) AND UPPER(cidade) = UPPER(p_cidade);
    IF v_contador > 0 THEN
        RAISE_APPLICATION_ERROR(-20006, 'Clinica ja cadastrada nesta cidade: ' || p_nome);
    END IF;

    INSERT INTO clinica (nome, cnpj, telefone, email,
                         logradouro, numero, bairro, cidade, estado, cep)
    VALUES (p_nome, p_cnpj, p_telefone, p_email,
            p_logradouro, p_numero, p_bairro, p_cidade, p_estado, p_cep);

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
    p_nome         IN VARCHAR2,
    p_crmv         IN VARCHAR2,
    p_especialidade IN VARCHAR2 DEFAULT NULL,
    p_email        IN VARCHAR2  DEFAULT NULL,
    p_cpf          IN VARCHAR2  DEFAULT NULL,
    p_telefone     IN VARCHAR2  DEFAULT NULL,
    p_sexo         IN VARCHAR2  DEFAULT NULL,
    p_data_nasc    IN DATE      DEFAULT NULL,
    p_clinica_id   IN VARCHAR2,
    p_logradouro   IN VARCHAR2  DEFAULT NULL,
    p_numero       IN VARCHAR2  DEFAULT NULL,
    p_bairro       IN VARCHAR2  DEFAULT NULL,
    p_cidade       IN VARCHAR2  DEFAULT NULL,
    p_estado       IN VARCHAR2  DEFAULT NULL,
    p_cep          IN VARCHAR2  DEFAULT NULL
) AS
    v_contador NUMBER;
BEGIN
    -- Excecao 1: CRMV duplicado
    SELECT COUNT(*) INTO v_contador FROM veterinario WHERE crmv = p_crmv;
    IF v_contador > 0 THEN
        RAISE_APPLICATION_ERROR(-20007, 'CRMV ja cadastrado: ' || p_crmv);
    END IF;

    -- Excecao 2: clinica nao existe
    SELECT COUNT(*) INTO v_contador FROM clinica WHERE id = p_clinica_id;
    IF v_contador = 0 THEN
        RAISE_APPLICATION_ERROR(-20008, 'Clinica nao encontrada: ' || p_clinica_id);
    END IF;

    INSERT INTO veterinario (nome, crmv, especialidade, email, cpf, telefone, sexo,
                              data_nascimento, clinica_id,
                              logradouro, numero, bairro, cidade, estado, cep)
    VALUES (p_nome, p_crmv, p_especialidade, p_email, p_cpf, p_telefone, p_sexo,
            p_data_nasc, p_clinica_id,
            p_logradouro, p_numero, p_bairro, p_cidade, p_estado, p_cep);

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
-- PROCEDURE: prc_inserir_evento_clinico
-- ------------------------------------------------------------
CREATE OR REPLACE PROCEDURE prc_inserir_evento_clinico (
    p_data           IN DATE,
    p_hora           IN VARCHAR2,
    p_descricao      IN VARCHAR2  DEFAULT NULL,
    p_tipo_evento    IN VARCHAR2,
    p_veterinario_id IN VARCHAR2,
    p_animal_id      IN VARCHAR2,
    p_clinica_id     IN VARCHAR2
) AS
    v_contador NUMBER;
BEGIN
    -- Excecao 1: data no passado
    IF p_data < TRUNC(SYSDATE) THEN
        RAISE_APPLICATION_ERROR(-20009, 'Nao e possivel agendar para uma data no passado');
    END IF;

    -- Excecao 2: conflito de horario para o veterinario
    SELECT COUNT(*) INTO v_contador
    FROM evento_clinico
    WHERE veterinario_id = p_veterinario_id
      AND data = p_data
      AND hora = p_hora;
    IF v_contador > 0 THEN
        RAISE_APPLICATION_ERROR(-20010,
            'Horario ja ocupado para este veterinario em ' ||
            TO_CHAR(p_data,'DD/MM/YYYY') || ' ' || p_hora);
    END IF;

    INSERT INTO evento_clinico (data, hora, descricao, tipo_evento,
                                veterinario_id, animal_id, clinica_id)
    VALUES (p_data, p_hora, p_descricao, p_tipo_evento,
            p_veterinario_id, p_animal_id, p_clinica_id);

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        INSERT INTO tb_log_erros (nome_procedure, codigo_erro, mensagem_erro)
        VALUES ('prc_inserir_evento_clinico', SQLCODE, SQLERRM);
        COMMIT;
        RAISE;
END prc_inserir_evento_clinico;
/

-- ------------------------------------------------------------
-- PROCEDURE: prc_inserir_pagamento
-- ------------------------------------------------------------
CREATE OR REPLACE PROCEDURE prc_inserir_pagamento (
    p_forma         IN VARCHAR2,
    p_valor         IN NUMBER,
    p_status        IN VARCHAR2  DEFAULT 'PENDENTE',
    p_data_pgto     IN DATE      DEFAULT NULL,
    p_descricao     IN VARCHAR2  DEFAULT NULL,
    p_observacao    IN VARCHAR2  DEFAULT NULL,
    p_evento_id     IN VARCHAR2
) AS
    v_contador NUMBER;
BEGIN
    -- Excecao 1: evento nao existe
    SELECT COUNT(*) INTO v_contador FROM evento_clinico WHERE id = p_evento_id;
    IF v_contador = 0 THEN
        RAISE_APPLICATION_ERROR(-20011, 'Evento clinico nao encontrado: ' || p_evento_id);
    END IF;

    -- Excecao 2: pagamento ja registrado para este evento
    SELECT COUNT(*) INTO v_contador FROM pagamento WHERE evento_clinico_id = p_evento_id;
    IF v_contador > 0 THEN
        RAISE_APPLICATION_ERROR(-20012, 'Pagamento ja registrado para este evento');
    END IF;

    INSERT INTO pagamento (forma_pagamento, valor, status_pagamento,
                           data_pagamento, descricao, observacao, evento_clinico_id)
    VALUES (p_forma, p_valor, p_status,
            p_data_pgto, p_descricao, p_observacao, p_evento_id);

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        INSERT INTO tb_log_erros (nome_procedure, codigo_erro, mensagem_erro)
        VALUES ('prc_inserir_pagamento', SQLCODE, SQLERRM);
        COMMIT;
        RAISE;
END prc_inserir_pagamento;
/
