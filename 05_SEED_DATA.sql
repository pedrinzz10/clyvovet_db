-- ============================================================
-- CLYVO VET -- BANCO DE DADOS ORACLE
-- Arquivo 05: Seed Data
-- ============================================================

-- ------------------------------------------------------------
-- CLINICAS
-- ------------------------------------------------------------
BEGIN
    prc_inserir_clinica('VetCare Prime',    '12345678000191', '(11) 3100-0001',
        'contato@vetcareprime.com.br',    'Av. Paulista',    '1000', 'Bela Vista',      'Sao Paulo', 'SP', '01310100');
    prc_inserir_clinica('PetMed Centro',    '23456789000102', '(11) 3100-0002',
        'contato@petmed.com.br',          'R. Augusta',      '420',  'Consolacao',      'Sao Paulo', 'SP', '01304000');
    prc_inserir_clinica('AnimalSaude SP',   '34567890000113', '(11) 3100-0003',
        'contato@animalsaude.com.br',     'R. Oscar Freire', '88',   'Jardins',         'Sao Paulo', 'SP', '01426001');
    prc_inserir_clinica('CliniPet Jardins', '45678901000124', '(11) 3100-0004',
        'contato@clinipet.com.br',        'Al. Santos',      '200',  'Jardim Paulista', 'Sao Paulo', 'SP', '01419001');
END;
/

-- ------------------------------------------------------------
-- VETERINARIOS
-- ------------------------------------------------------------
DECLARE
    v_c1 VARCHAR2(36);
    v_c2 VARCHAR2(36);
    v_c3 VARCHAR2(36);
    v_c4 VARCHAR2(36);
BEGIN
    SELECT id INTO v_c1 FROM clinica WHERE cnpj = '12345678000191';
    SELECT id INTO v_c2 FROM clinica WHERE cnpj = '23456789000102';
    SELECT id INTO v_c3 FROM clinica WHERE cnpj = '34567890000113';
    SELECT id INTO v_c4 FROM clinica WHERE cnpj = '45678901000124';

    prc_inserir_veterinario('Dra. Camila Ferreira', 'CRMV-SP 14320', 'Clinica Geral',
        'camila.ferreira@vetcare.com.br', '11122233344', '(11) 99001-0001', 'FEMININO',
        TO_DATE('15/03/1985','DD/MM/YYYY'), v_c1,
        'Av. Paulista', '1500', 'Bela Vista', 'Sao Paulo', 'SP', '01310200');
    prc_inserir_veterinario('Dr. Rafael Matos', 'CRMV-SP 18741', 'Cardiologia',
        'rafael.matos@petmed.com.br', '22233344455', '(11) 99001-0002', 'MASCULINO',
        TO_DATE('22/07/1980','DD/MM/YYYY'), v_c2,
        'R. Augusta', '500', 'Consolacao', 'Sao Paulo', 'SP', '01305000');
    prc_inserir_veterinario('Dr. Andre Costa', 'CRMV-SP 9812', 'Ortopedia',
        'andre.costa@animalsaude.com.br', '33344455566', '(11) 99001-0003', 'MASCULINO',
        TO_DATE('05/11/1978','DD/MM/YYYY'), v_c3,
        'R. Oscar Freire', '90', 'Jardins', 'Sao Paulo', 'SP', '01426002');
    prc_inserir_veterinario('Dra. Livia Rocha', 'CRMV-SP 16540', 'Dermatologia',
        'livia.rocha@clinipet.com.br', '44455566677', '(11) 99001-0004', 'FEMININO',
        TO_DATE('18/09/1990','DD/MM/YYYY'), v_c4,
        'Al. Santos', '300', 'Jardim Paulista', 'Sao Paulo', 'SP', '01419002');
    prc_inserir_veterinario('Dr. Tomas Oliveira', 'CRMV-SP 11204', 'Clinica Geral',
        'tomas.oliveira@vetcare.com.br', '55566677788', '(11) 99001-0005', 'MASCULINO',
        TO_DATE('30/01/1982','DD/MM/YYYY'), v_c1,
        'Av. Paulista', '1200', 'Bela Vista', 'Sao Paulo', 'SP', '01310300');
    prc_inserir_veterinario('Dra. Beatriz Lima', 'CRMV-SP 20333', 'Oncologia',
        'beatriz.lima@petmed.com.br', '66677788899', '(11) 99001-0006', 'FEMININO',
        TO_DATE('14/06/1992','DD/MM/YYYY'), v_c2,
        'R. Augusta', '600', 'Consolacao', 'Sao Paulo', 'SP', '01305100');
    prc_inserir_veterinario('Dr. Felipe Souza', 'CRMV-SP 25101', 'Nutricao Animal',
        'felipe.souza@animalsaude.com.br', '77788899900', '(11) 99001-0007', 'MASCULINO',
        TO_DATE('09/04/1995','DD/MM/YYYY'), v_c3,
        'R. Oscar Freire', '100', 'Jardins', 'Sao Paulo', 'SP', '01426003');
END;
/

-- ------------------------------------------------------------
-- TUTORES
-- ------------------------------------------------------------
BEGIN
    prc_inserir_tutor('Lucas M. Santos', 'lucas.santos@email.com', '11100011100',
        '(11) 98000-0001', TO_DATE('10/05/1990','DD/MM/YYYY'), 'MASCULINO',
        'R. Haddock Lobo', '595', 'Cerqueira Cesar', 'Sao Paulo', 'SP', '01414002');
    prc_inserir_tutor('Maria Oliveira', 'maria.oliveira@email.com', '22200022200',
        '(11) 97000-0002', TO_DATE('22/08/1985','DD/MM/YYYY'), 'FEMININO',
        'R. Estados Unidos', '1000', 'Jardins', 'Sao Paulo', 'SP', '01427002');
END;
/

-- ------------------------------------------------------------
-- ANIMAIS
-- ------------------------------------------------------------
DECLARE
    v_tutor1 VARCHAR2(36);
    v_tutor2 VARCHAR2(36);
BEGIN
    SELECT id INTO v_tutor1 FROM tutor WHERE cpf = '11100011100';
    SELECT id INTO v_tutor2 FROM tutor WHERE cpf = '22200022200';

    prc_inserir_animal('Bolinha', 'CAO', 'Golden Retriever', 'GRANDE', 'Dourado',
        'MACHO', TO_DATE('12/03/2022','DD/MM/YYYY'), 'Cachorro brincalhao e afetivo', v_tutor1);
    prc_inserir_animal('Mimi', 'GATO', 'Siames', 'PEQUENO', 'Bege e marrom',
        'FEMEA', TO_DATE('05/07/2021','DD/MM/YYYY'), 'Gata independente', v_tutor2);
    prc_inserir_animal('Rex', 'CAO', 'Pastor Alemao', 'GRANDE', 'Preto e marrom',
        'MACHO', TO_DATE('18/01/2020','DD/MM/YYYY'), 'Cao de guarda, obediente', v_tutor2);
END;
/

-- ------------------------------------------------------------
-- EVENTOS CLINICOS
-- INSERT direto: datas historicas nao passam pela validacao
-- de data futura da procedure prc_inserir_evento_clinico
-- ------------------------------------------------------------
DECLARE
    v_vet1    VARCHAR2(36);
    v_vet2    VARCHAR2(36);
    v_vet3    VARCHAR2(36);
    v_vet4    VARCHAR2(36);
    v_vet5    VARCHAR2(36);
    v_c1      VARCHAR2(36);
    v_c2      VARCHAR2(36);
    v_c3      VARCHAR2(36);
    v_c4      VARCHAR2(36);
    v_animal1 VARCHAR2(36);
    v_animal2 VARCHAR2(36);
    v_animal3 VARCHAR2(36);
BEGIN
    SELECT id INTO v_vet1    FROM veterinario WHERE crmv = 'CRMV-SP 14320';
    SELECT id INTO v_vet2    FROM veterinario WHERE crmv = 'CRMV-SP 18741';
    SELECT id INTO v_vet3    FROM veterinario WHERE crmv = 'CRMV-SP 9812';
    SELECT id INTO v_vet4    FROM veterinario WHERE crmv = 'CRMV-SP 16540';
    SELECT id INTO v_vet5    FROM veterinario WHERE crmv = 'CRMV-SP 11204';
    SELECT id INTO v_c1      FROM clinica     WHERE cnpj = '12345678000191';
    SELECT id INTO v_c2      FROM clinica     WHERE cnpj = '23456789000102';
    SELECT id INTO v_c3      FROM clinica     WHERE cnpj = '34567890000113';
    SELECT id INTO v_c4      FROM clinica     WHERE cnpj = '45678901000124';
    SELECT id INTO v_animal1 FROM animal      WHERE nome = 'Bolinha';
    SELECT id INTO v_animal2 FROM animal      WHERE nome = 'Mimi';
    SELECT id INTO v_animal3 FROM animal      WHERE nome = 'Rex';

    -- 6 eventos para Bolinha (garante LAG/LEAD com >= 5 linhas por animal)
    INSERT INTO evento_clinico (data, hora, tipo_evento, descricao, veterinario_id, animal_id, clinica_id)
    VALUES (TO_DATE('10/01/2024','DD/MM/YYYY'), '09:00', 'CONSULTA',
            'Check-up anual de rotina', v_vet1, v_animal1, v_c1);
    INSERT INTO evento_clinico (data, hora, tipo_evento, descricao, veterinario_id, animal_id, clinica_id)
    VALUES (TO_DATE('15/02/2024','DD/MM/YYYY'), '10:00', 'VACINA',
            'V10 - Vacina polivalente anual', v_vet1, v_animal1, v_c1);
    INSERT INTO evento_clinico (data, hora, tipo_evento, descricao, veterinario_id, animal_id, clinica_id)
    VALUES (TO_DATE('20/03/2024','DD/MM/YYYY'), '14:00', 'EXAME',
            'Hemograma completo e bioquimica', v_vet5, v_animal1, v_c1);
    INSERT INTO evento_clinico (data, hora, tipo_evento, descricao, veterinario_id, animal_id, clinica_id)
    VALUES (TO_DATE('05/06/2024','DD/MM/YYYY'), '11:00', 'RETORNO',
            'Retorno pos-exame, resultados normais', v_vet1, v_animal1, v_c1);
    INSERT INTO evento_clinico (data, hora, tipo_evento, descricao, veterinario_id, animal_id, clinica_id)
    VALUES (TO_DATE('10/09/2024','DD/MM/YYYY'), '09:30', 'VACINA',
            'Antirabica anual', v_vet5, v_animal1, v_c1);
    INSERT INTO evento_clinico (data, hora, tipo_evento, descricao, veterinario_id, animal_id, clinica_id)
    VALUES (TRUNC(SYSDATE) + 7, '10:00', 'CONSULTA',
            'Check-up e vermifugacao', v_vet1, v_animal1, v_c1);

    -- 3 eventos para Mimi
    INSERT INTO evento_clinico (data, hora, tipo_evento, descricao, veterinario_id, animal_id, clinica_id)
    VALUES (TO_DATE('20/02/2024','DD/MM/YYYY'), '15:00', 'CONSULTA',
            'Consulta de rotina', v_vet4, v_animal2, v_c4);
    INSERT INTO evento_clinico (data, hora, tipo_evento, descricao, veterinario_id, animal_id, clinica_id)
    VALUES (TO_DATE('15/04/2024','DD/MM/YYYY'), '16:00', 'VACINA',
            'Vacina triplice felina', v_vet4, v_animal2, v_c4);
    INSERT INTO evento_clinico (data, hora, tipo_evento, descricao, veterinario_id, animal_id, clinica_id)
    VALUES (TRUNC(SYSDATE) + 14, '14:00', 'EXAME',
            'Exame de urina e sangue', v_vet2, v_animal2, v_c2);

    -- 2 eventos para Rex
    INSERT INTO evento_clinico (data, hora, tipo_evento, descricao, veterinario_id, animal_id, clinica_id)
    VALUES (TO_DATE('08/03/2024','DD/MM/YYYY'), '08:00', 'CIRURGIA',
            'Cirurgia de castracao', v_vet3, v_animal3, v_c3);
    INSERT INTO evento_clinico (data, hora, tipo_evento, descricao, veterinario_id, animal_id, clinica_id)
    VALUES (TO_DATE('25/03/2024','DD/MM/YYYY'), '09:00', 'RETORNO',
            'Retorno pos-cirurgico', v_vet3, v_animal3, v_c3);

    COMMIT;
END;
/

-- ------------------------------------------------------------
-- PAGAMENTOS
-- ------------------------------------------------------------
DECLARE
    v_ev  VARCHAR2(36);
    v_a1  VARCHAR2(36);
    v_a2  VARCHAR2(36);
    v_a3  VARCHAR2(36);
BEGIN
    SELECT id INTO v_a1 FROM animal WHERE nome = 'Bolinha';
    SELECT id INTO v_a2 FROM animal WHERE nome = 'Mimi';
    SELECT id INTO v_a3 FROM animal WHERE nome = 'Rex';

    SELECT id INTO v_ev FROM evento_clinico WHERE animal_id = v_a1 AND data = TO_DATE('10/01/2024','DD/MM/YYYY');
    prc_inserir_pagamento('PIX',     150.00, 'PAGO',      TO_DATE('10/01/2024','DD/MM/YYYY'), 'Consulta de rotina',     NULL, v_ev);

    SELECT id INTO v_ev FROM evento_clinico WHERE animal_id = v_a1 AND data = TO_DATE('15/02/2024','DD/MM/YYYY');
    prc_inserir_pagamento('CARTAO',  80.00,  'PAGO',      TO_DATE('15/02/2024','DD/MM/YYYY'), 'Vacina V10',             NULL, v_ev);

    SELECT id INTO v_ev FROM evento_clinico WHERE animal_id = v_a1 AND data = TO_DATE('20/03/2024','DD/MM/YYYY');
    prc_inserir_pagamento('DINHEIRO',200.00, 'PAGO',      TO_DATE('20/03/2024','DD/MM/YYYY'), 'Hemograma e bioquimica', NULL, v_ev);

    SELECT id INTO v_ev FROM evento_clinico WHERE animal_id = v_a1 AND data = TO_DATE('05/06/2024','DD/MM/YYYY');
    prc_inserir_pagamento('PIX',     120.00, 'PENDENTE',  NULL,                               'Retorno Bolinha',        NULL, v_ev);

    SELECT id INTO v_ev FROM evento_clinico WHERE animal_id = v_a2 AND data = TO_DATE('20/02/2024','DD/MM/YYYY');
    prc_inserir_pagamento('CARTAO',  100.00, 'PAGO',      TO_DATE('20/02/2024','DD/MM/YYYY'), 'Consulta Mimi',          NULL, v_ev);

    SELECT id INTO v_ev FROM evento_clinico WHERE animal_id = v_a2 AND data = TO_DATE('15/04/2024','DD/MM/YYYY');
    prc_inserir_pagamento('PIX',     90.00,  'PENDENTE',  NULL,                               'Vacina felina Mimi',     NULL, v_ev);

    SELECT id INTO v_ev FROM evento_clinico WHERE animal_id = v_a3 AND data = TO_DATE('08/03/2024','DD/MM/YYYY');
    prc_inserir_pagamento('BOLETO',  800.00, 'PAGO',      TO_DATE('08/03/2024','DD/MM/YYYY'), 'Cirurgia castracao Rex', NULL, v_ev);

    SELECT id INTO v_ev FROM evento_clinico WHERE animal_id = v_a3 AND data = TO_DATE('25/03/2024','DD/MM/YYYY');
    prc_inserir_pagamento('PIX',     150.00, 'CANCELADO', NULL,                               'Retorno cancelado',      NULL, v_ev);
END;
/
