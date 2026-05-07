-- ============================================================
-- CLYVO VET -- BANCO DE DADOS ORACLE
-- Arquivo 03: Views
-- ============================================================

-- ------------------------------------------------------------
-- VIEW 1: vw_slots_disponiveis
-- Retorna slots livres por veterinario e data
-- Cruza tb_agendas_vet com tb_consultas e tb_bloqueios_vet
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vw_slots_disponiveis AS
WITH slots_agenda AS (
    SELECT
        av.veterinario_id,
        av.clinica_id,
        av.dia_semana,
        av.hora_inicio,
        av.hora_fim,
        av.duracao_slot_min,
        av.max_slots,
        c.nome AS nome_clinica
    FROM tb_agendas_vet av
    JOIN tb_clinicas c ON c.id = av.clinica_id
    WHERE av.ativo = 1
),
slots_ocupados AS (
    SELECT
        con.veterinario_id,
        con.data_consulta,
        con.hora_consulta,
        COUNT(*) AS total_ocupados
    FROM tb_consultas con
    WHERE con.situacao NOT IN ('cancelada')
    GROUP BY con.veterinario_id, con.data_consulta, con.hora_consulta
)
SELECT
    sa.veterinario_id,
    sa.clinica_id,
    sa.nome_clinica,
    sa.dia_semana,
    sa.hora_inicio,
    sa.hora_fim,
    sa.duracao_slot_min,
    sa.max_slots,
    NVL(so.total_ocupados, 0)                     AS total_ocupados,
    (sa.max_slots - NVL(so.total_ocupados, 0))     AS slots_disponiveis
FROM slots_agenda sa
LEFT JOIN slots_ocupados so
    ON  so.veterinario_id = sa.veterinario_id
    AND TO_CHAR(so.data_consulta, 'D') - 1 = sa.dia_semana
WHERE
    (sa.max_slots - NVL(so.total_ocupados, 0)) > 0;

-- ------------------------------------------------------------
-- VIEW 2: vw_painel_animal
-- Retorna dados consolidados do animal para a home do tutor
-- Score de saude, proximo evento e status de vacinas
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vw_painel_animal AS
SELECT
    a.id                            AS animal_id,
    a.nome                          AS nome_animal,
    a.especie,
    a.raca,
    a.sexo,
    a.data_nascimento,
    a.peso_kg,
    a.url_foto,
    a.modalidade,
    -- Score de saude mais recente
    ss.pontuacao                    AS pontuacao_saude,
    ss.pontuacao_vacina,
    ss.pontuacao_nutricao,
    ss.pontuacao_atividade,
    ss.registrado_em                AS score_registrado_em,
    -- Proximo evento pendente
    prox_ev.nome                    AS nome_prox_evento,
    prox_ev.tipo                    AS tipo_prox_evento,
    prox_ev.data_prevista           AS prazo_prox_evento,
    prox_ev.situacao                AS situacao_prox_evento,
    -- Contagem de vacinas em dia vs atrasadas
    (SELECT COUNT(*) FROM tb_eventos_saude es2
     WHERE es2.animal_id = a.id
       AND es2.tipo      = 'vacina'
       AND es2.situacao  = 'concluido')             AS vacinas_concluidas,
    (SELECT COUNT(*) FROM tb_eventos_saude es3
     WHERE es3.animal_id = a.id
       AND es3.tipo      = 'vacina'
       AND es3.situacao  IN ('pendente','urgente')) AS vacinas_pendentes,
    -- Proxima consulta confirmada
    prox_con.data_consulta          AS data_proxima_consulta,
    prox_con.hora_consulta          AS hora_proxima_consulta,
    nv.nome                         AS vet_proxima_consulta,
    nc.nome                         AS clinica_proxima_consulta
FROM tb_animais a
-- Score mais recente (subquery com row_number)
LEFT JOIN (
    SELECT ss2.*,
           ROW_NUMBER() OVER (PARTITION BY ss2.animal_id ORDER BY ss2.registrado_em DESC) AS rn
    FROM tb_scores_saude ss2
) ss ON ss.animal_id = a.id AND ss.rn = 1
-- Proximo evento de saude
LEFT JOIN (
    SELECT es4.*,
           ROW_NUMBER() OVER (PARTITION BY es4.animal_id ORDER BY es4.data_prevista ASC) AS rn
    FROM tb_eventos_saude es4
    WHERE es4.situacao IN ('pendente','urgente','agendado')
      AND es4.data_prevista >= TRUNC(SYSDATE)
) prox_ev ON prox_ev.animal_id = a.id AND prox_ev.rn = 1
-- Proxima consulta
LEFT JOIN (
    SELECT con2.*,
           ROW_NUMBER() OVER (PARTITION BY con2.animal_id ORDER BY con2.data_consulta ASC) AS rn
    FROM tb_consultas con2
    WHERE con2.situacao IN ('agendada','confirmada')
      AND con2.data_consulta >= TRUNC(SYSDATE)
) prox_con ON prox_con.animal_id = a.id AND prox_con.rn = 1
LEFT JOIN tb_veterinarios nv ON nv.id = prox_con.veterinario_id
LEFT JOIN tb_clinicas     nc ON nc.id = prox_con.clinica_id
WHERE a.ativo = 1;

-- ------------------------------------------------------------
-- VIEW 3: vw_mapa_clinicas
-- Retorna clinicas para o mapa com info resumida
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vw_mapa_clinicas AS
SELECT
    c.id,
    c.nome,
    e.logradouro        AS endereco,
    e.bairro,
    e.cidade,
    e.estado,
    e.cep,
    e.latitude,
    e.longitude,
    c.telefone,
    c.url_logo,
    c.atende_domicilio,
    c.aberta_24h,
    c.media_avaliacao,
    c.total_avaliacoes,
    COUNT(vc.veterinario_id) AS total_veterinarios
FROM tb_clinicas c
JOIN  tb_enderecos   e  ON e.id  = c.endereco_id
LEFT JOIN tb_vet_clinicas vc ON vc.clinica_id = c.id
WHERE c.ativo    = 1
  AND c.parceira = 1
GROUP BY
    c.id, c.nome, e.logradouro, e.bairro, e.cidade, e.estado, e.cep,
    e.latitude, e.longitude, c.telefone, c.url_logo,
    c.atende_domicilio, c.aberta_24h,
    c.media_avaliacao, c.total_avaliacoes;

-- ------------------------------------------------------------
-- VIEW 4: vw_notificacoes_nao_lidas
-- Notificacoes nao lidas por usuario ordenadas por data
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vw_notificacoes_nao_lidas AS
SELECT
    n.id,
    n.usuario_id,
    n.tipo,
    n.titulo,
    n.mensagem,
    n.tipo_entidade,
    n.id_entidade,
    n.criado_em
FROM tb_notificacoes n
WHERE n.lido = 0
ORDER BY n.criado_em DESC;
