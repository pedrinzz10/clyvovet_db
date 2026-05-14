-- ============================================================
-- CLYVO VET -- ORACLE DATABASE
-- Arquivo 03: Views
-- ============================================================

-- ------------------------------------------------------------
-- VIEW 1: vw_eventos_completos
-- Painel operacional: JOIN de todas as entidades principais
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vw_eventos_completos AS
SELECT
    ec.id               AS evento_id,
    ec.data_evento,
    ec.hora_evento,
    ec.tipo_evento,
    ec.descricao        AS descricao_evento,
    a.id                AS animal_id,
    a.nome              AS nome_animal,
    a.especie,
    a.raca,
    a.porte,
    t.id                AS tutor_id,
    t.nome              AS nome_tutor,
    t.telefone          AS telefone_tutor,
    v.id                AS veterinario_id,
    v.nome              AS nome_veterinario,
    v.especialidade,
    v.crmv,
    c.id                AS clinica_id,
    c.nome              AS nome_clinica,
    c.cidade,
    p.id                AS pagamento_id,
    p.valor,
    p.metodo_pagamento,
    p.status_pagamento,
    p.data_pagamento
FROM evento_clinico  ec
JOIN animal          a  ON a.id  = ec.animal_id
JOIN tutor           t  ON t.id  = a.tutor_id
JOIN veterinario     v  ON v.id  = ec.veterinario_id
JOIN clinica         c  ON c.id  = ec.clinica_id
LEFT JOIN pagamento  p  ON p.evento_id = ec.id;

-- ------------------------------------------------------------
-- VIEW 2: vw_resumo_financeiro_clinica
-- Faturamento consolidado por clínica
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vw_resumo_financeiro_clinica AS
SELECT
    c.id                                                                        AS clinica_id,
    c.nome                                                                      AS clinica,
    c.cidade,
    COUNT(DISTINCT ec.id)                                                       AS total_eventos,
    COUNT(DISTINCT p.id)                                                        AS total_pagamentos,
    NVL(SUM(CASE WHEN p.status_pagamento = 'PAGO'     THEN p.valor END), 0)   AS total_recebido,
    NVL(SUM(CASE WHEN p.status_pagamento = 'PENDENTE' THEN p.valor END), 0)   AS total_pendente,
    NVL(SUM(p.valor), 0)                                                        AS total_faturado
FROM clinica c
LEFT JOIN evento_clinico ec ON ec.clinica_id = c.id
LEFT JOIN pagamento       p  ON p.evento_id  = ec.id
GROUP BY c.id, c.nome, c.cidade;

-- ------------------------------------------------------------
-- VIEW 3: vw_historico_animal
-- Histórico consolidado por animal: eventos, gastos e dono
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vw_historico_animal AS
SELECT
    a.id                                                                            AS animal_id,
    a.nome                                                                          AS nome_animal,
    a.especie,
    a.raca,
    a.porte,
    a.genero,
    a.data_nascimento,
    t.nome                                                                          AS nome_tutor,
    t.telefone                                                                      AS telefone_tutor,
    t.email                                                                         AS email_tutor,
    COUNT(ec.id)                                                                    AS total_eventos,
    MIN(ec.data_evento)                                                             AS primeiro_evento,
    MAX(ec.data_evento)                                                             AS ultimo_evento,
    NVL(SUM(p.valor), 0)                                                           AS total_gasto,
    NVL(SUM(CASE WHEN p.status_pagamento = 'PENDENTE' THEN p.valor END), 0)       AS total_pendente
FROM animal a
JOIN tutor t ON t.id = a.tutor_id
LEFT JOIN evento_clinico ec ON ec.animal_id = a.id
LEFT JOIN pagamento       p  ON p.evento_id = ec.id
GROUP BY a.id, a.nome, a.especie, a.raca, a.porte, a.genero, a.data_nascimento,
         t.nome, t.telefone, t.email;

-- ------------------------------------------------------------
-- VIEW 4: vw_agenda_veterinario
-- Próximos eventos por veterinário com dados do animal e tutor
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vw_agenda_veterinario AS
SELECT
    v.id              AS veterinario_id,
    v.nome            AS nome_veterinario,
    v.especialidade,
    v.crmv,
    c.nome            AS clinica,
    c.cidade,
    ec.id             AS evento_id,
    ec.data_evento,
    ec.hora_evento,
    ec.tipo_evento,
    a.nome            AS nome_animal,
    a.especie,
    t.nome            AS nome_tutor,
    t.telefone        AS telefone_tutor
FROM veterinario     v
JOIN clinica         c  ON c.id  = v.clinica_id
JOIN evento_clinico  ec ON ec.veterinario_id = v.id
JOIN animal          a  ON a.id  = ec.animal_id
JOIN tutor           t  ON t.id  = a.tutor_id
WHERE ec.data_evento >= TRUNC(SYSDATE)
ORDER BY v.nome, ec.data_evento, ec.hora_evento;
