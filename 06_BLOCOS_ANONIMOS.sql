-- ============================================================
-- CLYVO VET -- BANCO DE DADOS ORACLE
-- Arquivo 06: Blocos Anonimos para Consultas e Relatorios
-- Exigencias do professor:
-- 1. Blocos com JOINs + GROUP BY + ORDER BY
-- 2. Bloco com LAG/LEAD (anterior/atual/proximo)
-- 3. Relatorios com cursor explicito, sumarizacao e decisao
-- ============================================================

-- ------------------------------------------------------------
-- BLOCO 1: Consultas com JOINs
-- Agendamentos por clinica com total e media de duracao
-- ------------------------------------------------------------
DECLARE
    v_linha VARCHAR2(200);
BEGIN
    DBMS_OUTPUT.PUT_LINE('==============================================');
    DBMS_OUTPUT.PUT_LINE(' CONSULTAS POR CLINICA');
    DBMS_OUTPUT.PUT_LINE('==============================================');
    DBMS_OUTPUT.PUT_LINE(RPAD('Clinica',30) || RPAD('Total',8) || RPAD('Duracao Med',12) || 'Situacao');
    DBMS_OUTPUT.PUT_LINE(RPAD('-',62,'-'));

    FOR reg IN (
        SELECT
            c.nome                              AS clinica,
            COUNT(con.id)                       AS total_consultas,
            ROUND(AVG(con.duracao_min), 1)      AS media_duracao,
            con.situacao
        FROM tb_consultas con
        JOIN tb_clinicas c ON c.id = con.clinica_id
        GROUP BY c.nome, con.situacao
        ORDER BY c.nome, con.situacao
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(reg.clinica, 30) ||
            RPAD(reg.total_consultas, 8) ||
            RPAD(reg.media_duracao || ' min', 12) ||
            reg.situacao
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('==============================================');
END;
/

-- ------------------------------------------------------------
-- BLOCO 2: Eventos de saude por tipo e situacao
-- JOIN de animais + eventos_saude + usuarios (tutor)
-- ------------------------------------------------------------
DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE('==============================================');
    DBMS_OUTPUT.PUT_LINE(' EVENTOS DE SAUDE DOS ANIMAIS');
    DBMS_OUTPUT.PUT_LINE('==============================================');
    DBMS_OUTPUT.PUT_LINE(RPAD('Animal', 15) || RPAD('Tutor', 20) || RPAD('Tipo', 14) || RPAD('Total', 7) || 'Proxima Data');
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 72, '-'));

    FOR reg IN (
        SELECT
            a.nome                                  AS nome_animal,
            u.nome                                  AS nome_tutor,
            es.tipo                                 AS tipo,
            COUNT(es.id)                            AS total,
            MIN(es.data_prevista)                   AS proxima_data
        FROM tb_eventos_saude es
        JOIN tb_animais      a  ON a.id  = es.animal_id
        JOIN tb_donos_animal da ON da.animal_id = a.id AND da.papel = 'principal'
        JOIN tb_usuarios     u  ON u.id  = da.usuario_id
        WHERE es.situacao IN ('pendente', 'urgente', 'agendado')
        GROUP BY a.nome, u.nome, es.tipo
        ORDER BY a.nome, proxima_data ASC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(reg.nome_animal, 15) ||
            RPAD(reg.nome_tutor, 20) ||
            RPAD(reg.tipo, 14) ||
            RPAD(reg.total, 7) ||
            TO_CHAR(reg.proxima_data, 'DD/MM/YYYY')
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('==============================================');
END;
/

-- ------------------------------------------------------------
-- BLOCO 3: Score medio de saude agrupado por especie e raca
-- JOIN de animais + scores_saude com GROUP BY e ORDER BY
-- ------------------------------------------------------------
DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE('==============================================');
    DBMS_OUTPUT.PUT_LINE(' SCORE MEDIO DE SAUDE POR ESPECIE E RACA');
    DBMS_OUTPUT.PUT_LINE('==============================================');
    DBMS_OUTPUT.PUT_LINE(RPAD('Especie', 15) || RPAD('Raca', 20) || RPAD('Animais', 8) || RPAD('Sc.Med', 8) || RPAD('Vacina', 8) || 'Nutricao');
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 72, '-'));

    FOR reg IN (
        SELECT
            a.especie                               AS especie,
            a.raca                                  AS raca,
            COUNT(DISTINCT a.id)                    AS total_animais,
            ROUND(AVG(ss.pontuacao), 1)             AS media_score,
            ROUND(AVG(ss.pontuacao_vacina), 1)      AS media_vacina,
            ROUND(AVG(ss.pontuacao_nutricao), 1)    AS media_nutricao
        FROM tb_animais a
        JOIN tb_scores_saude ss ON ss.animal_id = a.id
        WHERE a.ativo = 1
        GROUP BY a.especie, a.raca
        ORDER BY media_score DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(reg.especie, 15) ||
            RPAD(reg.raca, 20) ||
            RPAD(reg.total_animais, 8) ||
            RPAD(reg.media_score, 8) ||
            RPAD(reg.media_vacina, 8) ||
            reg.media_nutricao
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('==============================================');
END;
/

-- ------------------------------------------------------------
-- BLOCO 4: LAG/LEAD -- Eventos anteriores, atuais e proximos
-- Mostra para cada animal o evento anterior, atual e proximo
-- ------------------------------------------------------------
DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE('==============================================');
    DBMS_OUTPUT.PUT_LINE(' HISTORICO DE EVENTOS (ANTERIOR/ATUAL/PROXIMO)');
    DBMS_OUTPUT.PUT_LINE('==============================================');
    DBMS_OUTPUT.PUT_LINE(
        RPAD('Animal', 12) ||
        RPAD('Anterior', 22) ||
        RPAD('Atual', 22) ||
        RPAD('Proximo', 22)
    );
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 80, '-'));

    FOR reg IN (
        SELECT
            nome_animal,
            NVL(LAG(nome_evento)  OVER (PARTITION BY animal_id ORDER BY data_prevista), 'Vazio') AS anterior,
            nome_evento                                                                            AS atual,
            NVL(LEAD(nome_evento) OVER (PARTITION BY animal_id ORDER BY data_prevista), 'Vazio') AS proximo,
            data_prevista
        FROM (
            SELECT
                a.id            AS animal_id,
                a.nome          AS nome_animal,
                es.nome         AS nome_evento,
                es.data_prevista
            FROM tb_eventos_saude es
            JOIN tb_animais a ON a.id = es.animal_id
            ORDER BY a.nome, es.data_prevista
        )
        ORDER BY nome_animal, data_prevista
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(reg.nome_animal, 12) ||
            RPAD(SUBSTR(reg.anterior, 1, 20), 22) ||
            RPAD(SUBSTR(reg.atual,    1, 20), 22) ||
            RPAD(SUBSTR(reg.proximo,  1, 20), 22)
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('==============================================');
END;
/

-- ------------------------------------------------------------
-- BLOCO 5: RELATORIO com cursor explicito + sumarizacao
-- Lista todos os agendamentos com subtotal por clinica
-- Tomada de decisao: classifica situacao de cada consulta
-- ------------------------------------------------------------
DECLARE
    CURSOR cur_clinicas IS
        SELECT DISTINCT c.id, c.nome
        FROM tb_clinicas c
        JOIN tb_consultas con ON con.clinica_id = c.id
        ORDER BY c.nome;

    CURSOR cur_consultas (p_clinica_id NUMBER) IS
        SELECT
            con.data_consulta,
            con.hora_consulta,
            a.nome          AS nome_animal,
            v.nome          AS nome_vet,
            con.tipo_atendimento,
            con.situacao,
            con.duracao_min
        FROM tb_consultas  con
        JOIN tb_animais    a ON a.id = con.animal_id
        JOIN tb_veterinarios v ON v.id = con.veterinario_id
        WHERE con.clinica_id = p_clinica_id
        ORDER BY con.data_consulta, con.hora_consulta;

    v_subtotal_clinica  NUMBER := 0;
    v_subtotal_duracao  NUMBER := 0;
    v_total_geral       NUMBER := 0;
    v_total_duracao     NUMBER := 0;
    v_linha             VARCHAR2(300);
    v_obs               VARCHAR2(30);
BEGIN
    DBMS_OUTPUT.PUT_LINE('==========================================================');
    DBMS_OUTPUT.PUT_LINE(' RELATORIO DE CONSULTAS POR CLINICA');
    DBMS_OUTPUT.PUT_LINE('==========================================================');

    FOR clin IN cur_clinicas LOOP
        v_subtotal_clinica := 0;
        v_subtotal_duracao := 0;

        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('Clinica: ' || clin.nome);
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 60, '-'));
        DBMS_OUTPUT.PUT_LINE(
            RPAD('Data',12) ||
            RPAD('Hora',7) ||
            RPAD('Animal',12) ||
            RPAD('Veterinario',22) ||
            RPAD('Tipo',13) ||
            RPAD('Situacao',12)
        );
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 78, '-'));

        FOR con IN cur_consultas(clin.id) LOOP
            -- Tomada de decisao: classificar observacao por situacao e tipo
            IF con.situacao = 'cancelada' THEN
                v_obs := '[CANCELADA]';
            ELSIF con.situacao = 'confirmada' AND con.tipo_atendimento = 'domiciliar' THEN
                v_obs := '[DOM. CONFIRMADA]';
            ELSIF con.situacao = 'agendada' THEN
                v_obs := '[AGUARD. CONFIRM.]';
            ELSE
                v_obs := '';
            END IF;

            DBMS_OUTPUT.PUT_LINE(
                RPAD(TO_CHAR(con.data_consulta,'DD/MM/YYYY'), 12) ||
                RPAD(con.hora_consulta, 7) ||
                RPAD(SUBSTR(con.nome_animal, 1, 10), 12) ||
                RPAD(SUBSTR(con.nome_vet,    1, 20), 22) ||
                RPAD(con.tipo_atendimento, 13) ||
                RPAD(con.situacao, 12) ||
                v_obs
            );
            v_subtotal_clinica := v_subtotal_clinica + 1;
            v_subtotal_duracao := v_subtotal_duracao + con.duracao_min;
        END LOOP;

        DBMS_OUTPUT.PUT_LINE(RPAD('-', 60, '-'));
        DBMS_OUTPUT.PUT_LINE(
            'Sub-Total Clinica: ' || v_subtotal_clinica ||
            ' consultas | ' || v_subtotal_duracao || ' min total'
        );

        v_total_geral   := v_total_geral   + v_subtotal_clinica;
        v_total_duracao := v_total_duracao + v_subtotal_duracao;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('==========================================================');
    DBMS_OUTPUT.PUT_LINE('TOTAL GERAL: ' || v_total_geral || ' consultas | ' || v_total_duracao || ' min');
    DBMS_OUTPUT.PUT_LINE('==========================================================');

EXCEPTION
    WHEN OTHERS THEN
        INSERT INTO tb_log_erros (nome_procedure, codigo_erro, mensagem_erro)
        VALUES ('bloco_relatorio_consultas', SQLCODE, SQLERRM);
        COMMIT;
        RAISE;
END;
/

-- ------------------------------------------------------------
-- BLOCO 6: RELATORIO COMPLETO DE ANIMAIS
-- Cursor explicito + tomada de decisao
-- Lista TODOS os dados de tb_animais, sumariza numericamente
-- e exibe sumarizacao agrupada por especie (exigencia do professor)
-- ------------------------------------------------------------
DECLARE
    CURSOR cur_todos_animais IS
        SELECT
            a.id,
            a.nome,
            a.especie,
            a.raca,
            a.sexo,
            a.peso_kg,
            a.modalidade,
            a.ativo
        FROM tb_animais a
        ORDER BY a.especie, a.nome;

    CURSOR cur_por_especie IS
        SELECT
            a.especie,
            COUNT(a.id)                     AS total,
            ROUND(AVG(a.peso_kg), 2)        AS peso_medio,
            MIN(a.peso_kg)                  AS peso_min,
            MAX(a.peso_kg)                  AS peso_max
        FROM tb_animais a
        WHERE a.ativo = 1
        GROUP BY a.especie
        ORDER BY total DESC;

    v_total_animais NUMBER := 0;
    v_total_ativos  NUMBER := 0;
    v_total_peso    NUMBER := 0;
    v_porte         VARCHAR2(12);
BEGIN
    DBMS_OUTPUT.PUT_LINE('==========================================================');
    DBMS_OUTPUT.PUT_LINE(' RELATORIO COMPLETO DE ANIMAIS CADASTRADOS');
    DBMS_OUTPUT.PUT_LINE('==========================================================');
    DBMS_OUTPUT.PUT_LINE(
        RPAD('Nome', 12) || RPAD('Especie', 12) || RPAD('Raca', 18) ||
        RPAD('Sexo', 8) || RPAD('Peso', 8) || RPAD('Porte', 10) || 'Situacao'
    );
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 78, '-'));

    FOR animal IN cur_todos_animais LOOP
        -- Tomada de decisao: classificar porte pelo peso
        IF animal.peso_kg IS NULL THEN
            v_porte := 'N/D';
        ELSIF animal.peso_kg < 10 THEN
            v_porte := 'Pequeno';
        ELSIF animal.peso_kg < 25 THEN
            v_porte := 'Medio';
        ELSE
            v_porte := 'Grande';
        END IF;

        DBMS_OUTPUT.PUT_LINE(
            RPAD(SUBSTR(animal.nome, 1, 10), 12) ||
            RPAD(animal.especie, 12) ||
            RPAD(SUBSTR(animal.raca, 1, 16), 18) ||
            RPAD(animal.sexo, 8) ||
            RPAD(NVL(TO_CHAR(animal.peso_kg), '-') || ' kg', 8) ||
            RPAD(v_porte, 10) ||
            CASE WHEN animal.ativo = 1 THEN 'Ativo' ELSE 'Inativo' END
        );

        v_total_animais := v_total_animais + 1;
        IF animal.ativo = 1 THEN
            v_total_ativos := v_total_ativos + 1;
        END IF;
        IF animal.peso_kg IS NOT NULL THEN
            v_total_peso := v_total_peso + animal.peso_kg;
        END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(RPAD('-', 78, '-'));
    DBMS_OUTPUT.PUT_LINE(
        'TOTAL: ' || v_total_animais || ' animais' ||
        '  |  Ativos: ' || v_total_ativos ||
        '  |  Inativos: ' || (v_total_animais - v_total_ativos) ||
        '  |  Peso total: ' || v_total_peso || ' kg'
    );

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== SUMARIZACAO POR ESPECIE ===');
    DBMS_OUTPUT.PUT_LINE(
        RPAD('Especie', 15) || RPAD('Total', 7) ||
        RPAD('Peso Med', 10) || RPAD('Peso Min', 10) || 'Peso Max'
    );
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 50, '-'));

    FOR esp IN cur_por_especie LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(esp.especie, 15) ||
            RPAD(esp.total, 7) ||
            RPAD(esp.peso_medio || ' kg', 10) ||
            RPAD(esp.peso_min   || ' kg', 10) ||
            esp.peso_max || ' kg'
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('==========================================================');

EXCEPTION
    WHEN OTHERS THEN
        INSERT INTO tb_log_erros (nome_procedure, codigo_erro, mensagem_erro)
        VALUES ('bloco_relatorio_animais', SQLCODE, SQLERRM);
        COMMIT;
        RAISE;
END;
/

-- ------------------------------------------------------------
-- BLOCO 7: RELATORIO DE VETERINARIOS POR NIVEL DE EXPERIENCIA
-- Cursor explicito + tomada de decisao (Senior/Pleno/Junior)
-- ------------------------------------------------------------
DECLARE
    CURSOR cur_veterinarios IS
        SELECT
            u.nome              AS nome,
            v.crm,
            v.especialidade,
            v.anos_experiencia,
            v.disponivel,
            c.nome              AS clinica
        FROM tb_veterinarios v
        JOIN tb_usuarios      u  ON u.id  = v.usuario_id
        JOIN tb_vet_clinicas  vc ON vc.veterinario_id = v.id AND vc.principal = 1
        JOIN tb_clinicas      c  ON c.id  = vc.clinica_id
        ORDER BY v.especialidade, v.anos_experiencia DESC;

    v_total_vets    NUMBER := 0;
    v_total_senior  NUMBER := 0;
    v_total_pleno   NUMBER := 0;
    v_total_junior  NUMBER := 0;
    v_nivel         VARCHAR2(8);
BEGIN
    DBMS_OUTPUT.PUT_LINE('==========================================================');
    DBMS_OUTPUT.PUT_LINE(' RELATORIO DE VETERINARIOS POR NIVEL DE EXPERIENCIA');
    DBMS_OUTPUT.PUT_LINE('==========================================================');
    DBMS_OUTPUT.PUT_LINE(
        RPAD('Nome', 22) || RPAD('CRM', 16) || RPAD('Especialidade', 18) ||
        RPAD('Exp.', 6) || RPAD('Nivel', 8) || 'Clinica Principal'
    );
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 90, '-'));

    FOR vet IN cur_veterinarios LOOP
        -- Tomada de decisao: nivel por anos de experiencia
        IF vet.anos_experiencia >= 10 THEN
            v_nivel := 'Senior';
            v_total_senior := v_total_senior + 1;
        ELSIF vet.anos_experiencia >= 5 THEN
            v_nivel := 'Pleno';
            v_total_pleno := v_total_pleno + 1;
        ELSE
            v_nivel := 'Junior';
            v_total_junior := v_total_junior + 1;
        END IF;

        DBMS_OUTPUT.PUT_LINE(
            RPAD(SUBSTR(vet.nome, 1, 20), 22) ||
            RPAD(vet.crm, 16) ||
            RPAD(SUBSTR(vet.especialidade, 1, 16), 18) ||
            RPAD(vet.anos_experiencia || 'a', 6) ||
            RPAD(v_nivel, 8) ||
            SUBSTR(vet.clinica, 1, 25)
        );

        v_total_vets := v_total_vets + 1;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(RPAD('-', 90, '-'));
    DBMS_OUTPUT.PUT_LINE('TOTAL: ' || v_total_vets || ' veterinarios');
    DBMS_OUTPUT.PUT_LINE(
        '  Senior (>=10 anos): ' || v_total_senior ||
        '  |  Pleno (5-9 anos): ' || v_total_pleno ||
        '  |  Junior (<5 anos): ' || v_total_junior
    );
    DBMS_OUTPUT.PUT_LINE('==========================================================');

EXCEPTION
    WHEN OTHERS THEN
        INSERT INTO tb_log_erros (nome_procedure, codigo_erro, mensagem_erro)
        VALUES ('bloco_relatorio_veterinarios', SQLCODE, SQLERRM);
        COMMIT;
        RAISE;
END;
/

-- ------------------------------------------------------------
-- BLOCO 8: RELATORIO DE EVENTOS DE SAUDE POR URGENCIA
-- Cursor explicito + tomada de decisao (Atrasado/Urgente/No Prazo)
-- ------------------------------------------------------------
DECLARE
    CURSOR cur_eventos IS
        SELECT
            a.nome          AS nome_animal,
            es.nome         AS evento,
            es.tipo,
            es.situacao,
            es.data_prevista AS prazo
        FROM tb_eventos_saude es
        JOIN tb_animais a ON a.id = es.animal_id
        WHERE es.situacao NOT IN ('concluido', 'cancelada')
        ORDER BY es.data_prevista ASC;

    v_total_atrasados   NUMBER := 0;
    v_total_urgentes    NUMBER := 0;
    v_total_prazo       NUMBER := 0;
    v_prioridade        VARCHAR2(16);
    v_dias              NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('==========================================================');
    DBMS_OUTPUT.PUT_LINE(' RELATORIO DE EVENTOS PENDENTES POR URGENCIA');
    DBMS_OUTPUT.PUT_LINE('==========================================================');
    DBMS_OUTPUT.PUT_LINE(
        RPAD('Animal', 12) || RPAD('Evento', 28) || RPAD('Tipo', 14) ||
        RPAD('Prazo', 13) || 'Prioridade'
    );
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 80, '-'));

    FOR ev IN cur_eventos LOOP
        v_dias := TRUNC(ev.prazo) - TRUNC(SYSDATE);

        -- Tomada de decisao: classificar prioridade pelo prazo restante
        IF v_dias < 0 THEN
            v_prioridade := '*** ATRASADO';
            v_total_atrasados := v_total_atrasados + 1;
        ELSIF v_dias <= 7 THEN
            v_prioridade := '** URGENTE';
            v_total_urgentes := v_total_urgentes + 1;
        ELSE
            v_prioridade := 'No Prazo';
            v_total_prazo := v_total_prazo + 1;
        END IF;

        DBMS_OUTPUT.PUT_LINE(
            RPAD(SUBSTR(ev.nome_animal, 1, 10), 12) ||
            RPAD(SUBSTR(ev.evento, 1, 26), 28) ||
            RPAD(ev.tipo, 14) ||
            RPAD(TO_CHAR(ev.prazo, 'DD/MM/YYYY'), 13) ||
            v_prioridade
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(RPAD('-', 80, '-'));
    DBMS_OUTPUT.PUT_LINE('RESUMO:');
    DBMS_OUTPUT.PUT_LINE(
        '  Atrasados: '          || v_total_atrasados ||
        '  |  Urgentes (<=7d): ' || v_total_urgentes  ||
        '  |  No Prazo: '        || v_total_prazo
    );
    DBMS_OUTPUT.PUT_LINE('==========================================================');

EXCEPTION
    WHEN OTHERS THEN
        INSERT INTO tb_log_erros (nome_procedure, codigo_erro, mensagem_erro)
        VALUES ('bloco_relatorio_eventos', SQLCODE, SQLERRM);
        COMMIT;
        RAISE;
END;
/
