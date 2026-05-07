-- ============================================================
-- CLYVO VET -- BANCO DE DADOS ORACLE
-- Arquivo 05: Seed Data
-- Dados: 4 clinicas, 7 veterinarios, tutor Lucas, animal Bolinha
-- ============================================================

-- ------------------------------------------------------------
-- CLINICAS
-- ------------------------------------------------------------
BEGIN
    prc_inserir_clinica('VetCare Prime',     'Av. Paulista, 1000',   'Sao Paulo', 'SP', -23.5640, -46.6529, '(11) 3100-0001', 'contato@vetcareprime.com.br',   1, 1, 0);
    prc_inserir_clinica('PetMed Centro',     'R. Augusta, 420',      'Sao Paulo', 'SP', -23.5520, -46.6528, '(11) 3100-0002', 'contato@petmedcentro.com.br',   1, 0, 1);
    prc_inserir_clinica('AnimalSaude SP',    'R. Oscar Freire, 88',  'Sao Paulo', 'SP', -23.5630, -46.6680, '(11) 3100-0003', 'contato@animalsaudesp.com.br',  1, 1, 0);
    prc_inserir_clinica('CliniPet Jardins',  'Al. Santos, 200',      'Sao Paulo', 'SP', -23.5645, -46.6551, '(11) 3100-0004', 'contato@clinipetjardins.com.br',1, 0, 0);
    COMMIT;
END;
/

-- Horarios de funcionamento das clinicas
INSERT INTO tb_horarios_clinica (clinica_id, dia_semana, abre_as, fecha_as, fechado)
SELECT id, 1, '08:00', '18:00', 0 FROM tb_clinicas WHERE nome = 'VetCare Prime';
INSERT INTO tb_horarios_clinica (clinica_id, dia_semana, abre_as, fecha_as, fechado)
SELECT id, 2, '08:00', '18:00', 0 FROM tb_clinicas WHERE nome = 'VetCare Prime';
INSERT INTO tb_horarios_clinica (clinica_id, dia_semana, abre_as, fecha_as, fechado)
SELECT id, 3, '08:00', '18:00', 0 FROM tb_clinicas WHERE nome = 'VetCare Prime';
INSERT INTO tb_horarios_clinica (clinica_id, dia_semana, abre_as, fecha_as, fechado)
SELECT id, 4, '08:00', '18:00', 0 FROM tb_clinicas WHERE nome = 'VetCare Prime';
INSERT INTO tb_horarios_clinica (clinica_id, dia_semana, abre_as, fecha_as, fechado)
SELECT id, 5, '08:00', '18:00', 0 FROM tb_clinicas WHERE nome = 'VetCare Prime';
INSERT INTO tb_horarios_clinica (clinica_id, dia_semana, abre_as, fecha_as, fechado)
SELECT id, 6, '09:00', '13:00', 0 FROM tb_clinicas WHERE nome = 'VetCare Prime';
INSERT INTO tb_horarios_clinica (clinica_id, dia_semana, abre_as, fecha_as, fechado)
SELECT id, 0, NULL, NULL, 1 FROM tb_clinicas WHERE nome = 'VetCare Prime';
COMMIT;

-- ------------------------------------------------------------
-- VETERINARIOS (via procedure)
-- ------------------------------------------------------------
DECLARE
    v_clinica1 NUMBER;
    v_clinica2 NUMBER;
    v_clinica3 NUMBER;
    v_clinica4 NUMBER;
BEGIN
    SELECT id INTO v_clinica1 FROM tb_clinicas WHERE nome = 'VetCare Prime';
    SELECT id INTO v_clinica2 FROM tb_clinicas WHERE nome = 'PetMed Centro';
    SELECT id INTO v_clinica3 FROM tb_clinicas WHERE nome = 'AnimalSaude SP';
    SELECT id INTO v_clinica4 FROM tb_clinicas WHERE nome = 'CliniPet Jardins';

    prc_inserir_veterinario('Dra. Camila Ferreira', 'camila.ferreira@vetcare.com.br',  '(11) 99001-0001', 'CRMV-SP 14320', 'Clinica Geral',       'Especialista em pequenos animais com 10 anos de experiencia.', 10, v_clinica1);
    prc_inserir_veterinario('Dr. Rafael Matos',     'rafael.matos@petmed.com.br',      '(11) 99001-0002', 'CRMV-SP 18741', 'Cardiologia',         'Cardiologista veterinario com foco em caes de grande porte.',  8,  v_clinica2);
    prc_inserir_veterinario('Dr. Andre Costa',      'andre.costa@animalsaude.com.br',  '(11) 99001-0003', 'CRMV-SP 9812',  'Ortopedia',           'Ortopedista com experiencia em cirurgias de quadril.',         15, v_clinica3);
    prc_inserir_veterinario('Dra. Livia Rocha',     'livia.rocha@clinipet.com.br',     '(11) 99001-0004', 'CRMV-SP 16540', 'Dermatologia',        'Especialista em dermatologia e alergias em animais.',          7,  v_clinica4);
    prc_inserir_veterinario('Dr. Tomas Oliveira',   'tomas.oliveira@vetcare.com.br',   '(11) 99001-0005', 'CRMV-SP 11204', 'Clinica Geral',       'Atendimento domiciliar e urgencias veterinarias.',             12, v_clinica1);
    prc_inserir_veterinario('Dra. Beatriz Lima',    'beatriz.lima@petmed.com.br',      '(11) 99001-0006', 'CRMV-SP 20333', 'Oncologia',           'Oncologista veterinaria com pesquisa em tratamentos modernos.',6,  v_clinica2);
    prc_inserir_veterinario('Dr. Felipe Souza',     'felipe.souza@animalsaude.com.br', '(11) 99001-0007', 'CRMV-SP 25101', 'Nutricao Animal',     'Nutricionista veterinario e comportamentalista.',              3,  v_clinica3);
    COMMIT;
END;
/

-- Agendas semanais dos veterinarios
DECLARE
    v_vet1    NUMBER;
    v_vet2    NUMBER;
    v_clinica1 NUMBER;
    v_clinica2 NUMBER;
BEGIN
    SELECT v.id INTO v_vet1    FROM tb_veterinarios v WHERE v.crm = 'CRMV-SP 14320';
    SELECT v.id INTO v_vet2    FROM tb_veterinarios v WHERE v.crm = 'CRMV-SP 18741';
    SELECT c.id INTO v_clinica1 FROM tb_clinicas c WHERE nome = 'VetCare Prime';
    SELECT c.id INTO v_clinica2 FROM tb_clinicas c WHERE nome = 'PetMed Centro';

    -- Dra. Camila: seg a sex, 08:00-17:00, slots de 30min
    INSERT INTO tb_agendas_vet (veterinario_id, clinica_id, dia_semana, hora_inicio, hora_fim, duracao_slot_min, max_slots)
    VALUES (v_vet1, v_clinica1, 1, '08:00', '17:00', 30, 18);
    INSERT INTO tb_agendas_vet (veterinario_id, clinica_id, dia_semana, hora_inicio, hora_fim, duracao_slot_min, max_slots)
    VALUES (v_vet1, v_clinica1, 2, '08:00', '17:00', 30, 18);
    INSERT INTO tb_agendas_vet (veterinario_id, clinica_id, dia_semana, hora_inicio, hora_fim, duracao_slot_min, max_slots)
    VALUES (v_vet1, v_clinica1, 3, '08:00', '17:00', 30, 18);
    INSERT INTO tb_agendas_vet (veterinario_id, clinica_id, dia_semana, hora_inicio, hora_fim, duracao_slot_min, max_slots)
    VALUES (v_vet1, v_clinica1, 4, '08:00', '17:00', 30, 18);
    INSERT INTO tb_agendas_vet (veterinario_id, clinica_id, dia_semana, hora_inicio, hora_fim, duracao_slot_min, max_slots)
    VALUES (v_vet1, v_clinica1, 5, '08:00', '17:00', 30, 18);

    -- Dr. Rafael: ter e qui, 09:00-16:00
    INSERT INTO tb_agendas_vet (veterinario_id, clinica_id, dia_semana, hora_inicio, hora_fim, duracao_slot_min, max_slots)
    VALUES (v_vet2, v_clinica2, 2, '09:00', '16:00', 30, 14);
    INSERT INTO tb_agendas_vet (veterinario_id, clinica_id, dia_semana, hora_inicio, hora_fim, duracao_slot_min, max_slots)
    VALUES (v_vet2, v_clinica2, 4, '09:00', '16:00', 30, 14);

    COMMIT;
END;
/

-- ------------------------------------------------------------
-- TUTOR: Lucas M. Santos
-- ------------------------------------------------------------
BEGIN
    prc_inserir_usuario('Lucas M. Santos', 'lucas.santos@email.com', '(11) 98000-0001',
                        '$2b$12$seed_hash_lucas_santos', 'dono', 'pt');
    COMMIT;
END;
/

-- ------------------------------------------------------------
-- ANIMAL: Bolinha
-- ------------------------------------------------------------
DECLARE
    v_dono_id NUMBER;
BEGIN
    SELECT id INTO v_dono_id FROM tb_usuarios WHERE email = 'lucas.santos@email.com';

    prc_inserir_animal(
        p_nome             => 'Bolinha',
        p_especie          => 'cao',
        p_raca             => 'Golden Retriever',
        p_sexo             => 'macho',
        p_data_nascimento  => TO_DATE('12/03/2022', 'DD/MM/YYYY'),
        p_cor              => 'Dourado',
        p_peso_kg          => 28.5,
        p_codigo_microchip => '985112007432891',
        p_url_foto         => 'https://storage.clyvovet.com.br/animais/bolinha.jpg',
        p_modalidade       => 'domestico',
        p_dono_id          => v_dono_id
    );
    COMMIT;
END;
/

-- ------------------------------------------------------------
-- EVENTOS DE SAUDE DO BOLINHA
-- ------------------------------------------------------------
DECLARE
    v_animal_id NUMBER;
    v_dono_id   NUMBER;
BEGIN
    SELECT id INTO v_animal_id FROM tb_animais  WHERE codigo_microchip = '985112007432891';
    SELECT id INTO v_dono_id   FROM tb_usuarios WHERE email = 'lucas.santos@email.com';

    prc_inserir_evento_saude(v_animal_id, 'vacina',       'V10 - Polivalente',    'Vacina anual obrigatoria',        TO_DATE('15/05/2025','DD/MM/YYYY'), NULL,                               'pendente',  v_dono_id);
    prc_inserir_evento_saude(v_animal_id, 'vacina',       'Antirabica',           'Vacina antirabica anual',         TO_DATE('20/06/2025','DD/MM/YYYY'), NULL,                               'pendente',  v_dono_id);
    prc_inserir_evento_saude(v_animal_id, 'vermifugacao', 'Vermifugo trimestral', 'Drontal Plus para caes',          TO_DATE('10/05/2025','DD/MM/YYYY'), NULL,                               'urgente',   v_dono_id);
    prc_inserir_evento_saude(v_animal_id, 'exame',        'Hemograma completo',   'Check-up anual de rotina',        TO_DATE('30/05/2025','DD/MM/YYYY'), NULL,                               'agendado',  v_dono_id);
    prc_inserir_evento_saude(v_animal_id, 'medicamento',  'NexGard - antipulgas', 'Comprimido mensal antipulgas',    TO_DATE('01/06/2025','DD/MM/YYYY'), NULL,                               'pendente',  v_dono_id);
    prc_inserir_evento_saude(v_animal_id, 'vacina',       'V10 - Polivalente',    'Vacina do ano anterior',          TO_DATE('15/05/2024','DD/MM/YYYY'), TO_DATE('15/05/2024','DD/MM/YYYY'), 'concluido', v_dono_id);
    COMMIT;
END;
/

-- ------------------------------------------------------------
-- SCORE DE SAUDE INICIAL DO BOLINHA
-- ------------------------------------------------------------
DECLARE
    v_animal_id NUMBER;
BEGIN
    SELECT id INTO v_animal_id FROM tb_animais WHERE codigo_microchip = '985112007432891';

    INSERT INTO tb_scores_saude (animal_id, pontuacao, pontuacao_nutricao, pontuacao_atividade, pontuacao_vacina)
    VALUES (v_animal_id, 72.5, 80.0, 85.0, 55.0);
    COMMIT;
END;
/

-- ------------------------------------------------------------
-- VACINAS NO CARTAO DIGITAL DO BOLINHA
-- ------------------------------------------------------------
DECLARE
    v_carteirinha_id NUMBER;
    v_animal_id      NUMBER;
BEGIN
    SELECT id INTO v_animal_id      FROM tb_animais      WHERE codigo_microchip = '985112007432891';
    SELECT id INTO v_carteirinha_id FROM tb_carteirinhas WHERE animal_id = v_animal_id;

    INSERT INTO tb_vacinas_carteirinha (carteirinha_id, nome_vacina, situacao, aplicada_em, valida_ate)
    VALUES (v_carteirinha_id, 'V10 - Polivalente', 'ok',      TO_DATE('15/05/2024','DD/MM/YYYY'), TO_DATE('15/05/2025','DD/MM/YYYY'));
    INSERT INTO tb_vacinas_carteirinha (carteirinha_id, nome_vacina, situacao, aplicada_em, valida_ate)
    VALUES (v_carteirinha_id, 'Antirabica',         'vencida',  TO_DATE('20/06/2023','DD/MM/YYYY'), TO_DATE('20/06/2024','DD/MM/YYYY'));
    INSERT INTO tb_vacinas_carteirinha (carteirinha_id, nome_vacina, situacao, aplicada_em, valida_ate)
    VALUES (v_carteirinha_id, 'Giardíase',           'ok',       TO_DATE('10/01/2024','DD/MM/YYYY'), TO_DATE('10/01/2025','DD/MM/YYYY'));

    COMMIT;
END;
/

-- ------------------------------------------------------------
-- CONSULTA DO BOLINHA
-- ------------------------------------------------------------
DECLARE
    v_animal_id  NUMBER;
    v_dono_id    NUMBER;
    v_vet_id     NUMBER;
    v_clinica_id NUMBER;
BEGIN
    SELECT id INTO v_animal_id  FROM tb_animais      WHERE codigo_microchip = '985112007432891';
    SELECT id INTO v_dono_id    FROM tb_usuarios      WHERE email = 'lucas.santos@email.com';
    SELECT id INTO v_vet_id     FROM tb_veterinarios  WHERE crm   = 'CRMV-SP 14320';
    SELECT id INTO v_clinica_id FROM tb_clinicas       WHERE nome  = 'VetCare Prime';

    prc_inserir_consulta(
        p_animal_id        => v_animal_id,
        p_dono_id          => v_dono_id,
        p_veterinario_id   => v_vet_id,
        p_clinica_id       => v_clinica_id,
        p_especialidade    => 'Clinica Geral',
        p_data             => TRUNC(SYSDATE) + 7,
        p_hora             => '10:00',
        p_duracao_min      => 30,
        p_tipo_atendimento => 'presencial',
        p_observacoes      => 'Check-up anual e vermifugacao do Bolinha'
    );
    COMMIT;
END;
/
