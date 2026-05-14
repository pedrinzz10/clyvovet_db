-- ============================================================
-- CLYVO VET -- ORACLE DATABASE
-- Arquivo 04: Procedures de Carga de Dados
-- Padrão: parâmetros, 2 exceções específicas, EXCEPTION WHEN OTHERS,
--         ROLLBACK + log em log_erros em caso de falha
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
    p_genero    IN VARCHAR2  DEFAULT NULL,
    p_rua       IN VARCHAR2  DEFAULT NULL,
    p_numero    IN VARCHAR2  DEFAULT NULL,
    p_bairro    IN VARCHAR2  DEFAULT NULL,
    p_cidade    IN VARCHAR2  DEFAULT NULL,
    p_estado    IN VARCHAR2  DEFAULT NULL,
    p_cep       IN VARCHAR2  DEFAULT NULL
) AS
    v_count NUMBER;
BEGIN
    -- Exceção 1: e-mail duplicado
    SELECT COUNT(*) INTO v_count FROM tutor WHERE email = p_email;
    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'E-mail já cadastrado: ' || p_email);
    END IF;

    -- Exceção 2: CPF duplicado
    IF p_cpf IS NOT NULL THEN
        SELECT COUNT(*) INTO v_count FROM tutor WHERE cpf = p_cpf;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'CPF já cadastrado: ' || p_cpf);
        END IF;
    END IF;

    INSERT INTO tutor (nome, email, cpf, telefone, data_nascimento, genero,
                       rua, numero, bairro, cidade, estado, cep)
    VALUES (p_nome, p_email, p_cpf, p_telefone, p_data_nasc, p_genero,
            p_rua, p_numero, p_bairro, p_cidade, p_estado, p_cep);

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        INSERT INTO log_erros (nome_procedure, codigo_erro, mensagem_erro)
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
    p_genero    IN VARCHAR2  DEFAULT NULL,
    p_data_nasc IN DATE      DEFAULT NULL,
    p_obs       IN VARCHAR2  DEFAULT NULL,
    p_tutor_id  IN VARCHAR2
) AS
    v_count NUMBER;
BEGIN
    -- Exceção 1: tutor não encontrado
    SELECT COUNT(*) INTO v_count FROM tutor WHERE id = p_tutor_id;
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Tutor não encontrado: ' || p_tutor_id);
    END IF;

    -- Exceção 2: espécie inválida
    IF p_especie NOT IN ('CACHORRO','GATO','PASSARO','REPTIL','ROEDOR','OUTRO') THEN
        RAISE_APPLICATION_ERROR(-20004, 'Espécie inválida: ' || p_especie);
    END IF;

    INSERT INTO animal (nome, especie, raca, porte, cor, genero,
                        data_nascimento, observacoes, tutor_id)
    VALUES (p_nome, p_especie, p_raca, p_porte, p_cor, p_genero,
            p_data_nasc, p_obs, p_tutor_id);

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        INSERT INTO log_erros (nome_procedure, codigo_erro, mensagem_erro)
        VALUES ('prc_inserir_animal', SQLCODE, SQLERRM);
        COMMIT;
        RAISE;
END prc_inserir_animal;
/

-- ------------------------------------------------------------
-- PROCEDURE: prc_inserir_clinica
-- ------------------------------------------------------------
CREATE OR REPLACE PROCEDURE prc_inserir_clinica (
    p_nome     IN VARCHAR2,
    p_cnpj     IN VARCHAR2  DEFAULT NULL,
    p_telefone IN VARCHAR2  DEFAULT NULL,
    p_email    IN VARCHAR2  DEFAULT NULL,
    p_rua      IN VARCHAR2  DEFAULT NULL,
    p_numero   IN VARCHAR2  DEFAULT NULL,
    p_bairro   IN VARCHAR2  DEFAULT NULL,
    p_cidade   IN VARCHAR2  DEFAULT NULL,
    p_estado   IN VARCHAR2  DEFAULT NULL,
    p_cep      IN VARCHAR2  DEFAULT NULL
) AS
    v_count NUMBER;
BEGIN
    -- Exceção 1: CNPJ duplicado
    IF p_cnpj IS NOT NULL THEN
        SELECT COUNT(*) INTO v_count FROM clinica WHERE cnpj = p_cnpj;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20005, 'CNPJ já cadastrado: ' || p_cnpj);
        END IF;
    END IF;

    -- Exceção 2: clínica com mesmo nome e cidade já existe
    SELECT COUNT(*) INTO v_count
    FROM clinica
    WHERE UPPER(nome) = UPPER(p_nome) AND UPPER(cidade) = UPPER(p_cidade);
    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20006, 'Clínica já cadastrada nesta cidade: ' || p_nome);
    END IF;

    INSERT INTO clinica (nome, cnpj, telefone, email,
                         rua, numero, bairro, cidade, estado, cep)
    VALUES (p_nome, p_cnpj, p_telefone, p_email,
            p_rua, p_numero, p_bairro, p_cidade, p_estado, p_cep);

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        INSERT INTO log_erros (nome_procedure, codigo_erro, mensagem_erro)
        VALUES ('prc_inserir_clinica', SQLCODE, SQLERRM);
        COMMIT;
        RAISE;
END prc_inserir_clinica;
/

-- ------------------------------------------------------------
-- PROCEDURE: prc_inserir_veterinario
-- ------------------------------------------------------------
CREATE OR REPLACE PROCEDURE prc_inserir_veterinario (
    p_nome          IN VARCHAR2,
    p_crmv          IN VARCHAR2,
    p_especialidade IN VARCHAR2  DEFAULT NULL,
    p_email         IN VARCHAR2  DEFAULT NULL,
    p_cpf           IN VARCHAR2  DEFAULT NULL,
    p_telefone      IN VARCHAR2  DEFAULT NULL,
    p_genero        IN VARCHAR2  DEFAULT NULL,
    p_data_nasc     IN DATE      DEFAULT NULL,
    p_clinica_id    IN VARCHAR2,
    p_rua           IN VARCHAR2  DEFAULT NULL,
    p_numero        IN VARCHAR2  DEFAULT NULL,
    p_bairro        IN VARCHAR2  DEFAULT NULL,
    p_cidade        IN VARCHAR2  DEFAULT NULL,
    p_estado        IN VARCHAR2  DEFAULT NULL,
    p_cep           IN VARCHAR2  DEFAULT NULL
) AS
    v_count NUMBER;
BEGIN
    -- Exceção 1: CRMV duplicado
    SELECT COUNT(*) INTO v_count FROM veterinario WHERE crmv = p_crmv;
    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20007, 'CRMV já cadastrado: ' || p_crmv);
    END IF;

    -- Exceção 2: clínica não encontrada
    SELECT COUNT(*) INTO v_count FROM clinica WHERE id = p_clinica_id;
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20008, 'Clínica não encontrada: ' || p_clinica_id);
    END IF;

    INSERT INTO veterinario (nome, crmv, especialidade, email, cpf, telefone, genero,
                              data_nascimento, clinica_id,
                              rua, numero, bairro, cidade, estado, cep)
    VALUES (p_nome, p_crmv, p_especialidade, p_email, p_cpf, p_telefone, p_genero,
            p_data_nasc, p_clinica_id,
            p_rua, p_numero, p_bairro, p_cidade, p_estado, p_cep);

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        INSERT INTO log_erros (nome_procedure, codigo_erro, mensagem_erro)
        VALUES ('prc_inserir_veterinario', SQLCODE, SQLERRM);
        COMMIT;
        RAISE;
END prc_inserir_veterinario;
/

-- ------------------------------------------------------------
-- PROCEDURE: prc_inserir_evento_clinico
-- ------------------------------------------------------------
CREATE OR REPLACE PROCEDURE prc_inserir_evento_clinico (
    p_data        IN DATE,
    p_hora        IN VARCHAR2,
    p_descricao   IN VARCHAR2  DEFAULT NULL,
    p_tipo_evento IN VARCHAR2,
    p_vet_id      IN VARCHAR2,
    p_animal_id   IN VARCHAR2,
    p_clinica_id  IN VARCHAR2
) AS
    v_count NUMBER;
BEGIN
    -- Exceção 1: data no passado
    IF p_data < TRUNC(SYSDATE) THEN
        RAISE_APPLICATION_ERROR(-20009, 'Não é possível agendar para uma data passada');
    END IF;

    -- Exceção 2: conflito de agenda do veterinário
    SELECT COUNT(*) INTO v_count
    FROM evento_clinico
    WHERE veterinario_id = p_vet_id
      AND data_evento = p_data
      AND hora_evento = p_hora;
    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20010,
            'Horário já ocupado para este veterinário em ' ||
            TO_CHAR(p_data,'DD/MM/YYYY') || ' ' || p_hora);
    END IF;

    INSERT INTO evento_clinico (data_evento, hora_evento, descricao, tipo_evento,
                                veterinario_id, animal_id, clinica_id)
    VALUES (p_data, p_hora, p_descricao, p_tipo_evento,
            p_vet_id, p_animal_id, p_clinica_id);

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        INSERT INTO log_erros (nome_procedure, codigo_erro, mensagem_erro)
        VALUES ('prc_inserir_evento_clinico', SQLCODE, SQLERRM);
        COMMIT;
        RAISE;
END prc_inserir_evento_clinico;
/

-- ------------------------------------------------------------
-- PROCEDURE: prc_inserir_pagamento
-- ------------------------------------------------------------
CREATE OR REPLACE PROCEDURE prc_inserir_pagamento (
    p_metodo    IN VARCHAR2,
    p_valor     IN NUMBER,
    p_status    IN VARCHAR2  DEFAULT 'PENDENTE',
    p_data_pgto IN DATE      DEFAULT NULL,
    p_descricao IN VARCHAR2  DEFAULT NULL,
    p_notas     IN VARCHAR2  DEFAULT NULL,
    p_evento_id IN VARCHAR2
) AS
    v_count NUMBER;
BEGIN
    -- Exceção 1: evento clínico não encontrado
    SELECT COUNT(*) INTO v_count FROM evento_clinico WHERE id = p_evento_id;
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20011, 'Evento clínico não encontrado: ' || p_evento_id);
    END IF;

    -- Exceção 2: pagamento já cadastrado para este evento
    SELECT COUNT(*) INTO v_count FROM pagamento WHERE evento_id = p_evento_id;
    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20012, 'Pagamento já cadastrado para este evento');
    END IF;

    INSERT INTO pagamento (metodo_pagamento, valor, status_pagamento,
                           data_pagamento, descricao, notas, evento_id)
    VALUES (p_metodo, p_valor, p_status,
            p_data_pgto, p_descricao, p_notas, p_evento_id);

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        INSERT INTO log_erros (nome_procedure, codigo_erro, mensagem_erro)
        VALUES ('prc_inserir_pagamento', SQLCODE, SQLERRM);
        COMMIT;
        RAISE;
END prc_inserir_pagamento;
/
