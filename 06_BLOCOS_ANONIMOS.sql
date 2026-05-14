-- ============================================================
-- CLYVO VET -- ORACLE DATABASE
-- Arquivo 06: Blocos Anônimos para Consultas e Relatórios
-- ============================================================

-- ------------------------------------------------------------
-- BLOCO 1: Faturamento por clínica
-- JOIN evento_clinico + clinica + pagamento
-- GROUP BY clínica | ORDER BY total_eventos DESC
-- ------------------------------------------------------------
DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE('==============================================');
    DBMS_OUTPUT.PUT_LINE(' FATURAMENTO POR CLÍNICA');
    DBMS_OUTPUT.PUT_LINE('==============================================');
    DBMS_OUTPUT.PUT_LINE(RPAD('Clínica',22) || RPAD('Eventos',9) || RPAD('Pgtos',7) || RPAD('Recebido',12) || 'Pendente');
    DBMS_OUTPUT.PUT_LINE(RPAD('-',62,'-'));

    FOR reg IN (
        SELECT
            c.nome                                                                        AS clinica,
            COUNT(DISTINCT ec.id)                                                         AS total_eventos,
            COUNT(DISTINCT p.id)                                                          AS total_pgtos,
            NVL(SUM(CASE WHEN p.status_pagamento = 'PAGO'     THEN p.valor END), 0)     AS recebido,
            NVL(SUM(CASE WHEN p.status_pagamento = 'PENDENTE' THEN p.valor END), 0)     AS pendente
        FROM clinica c
        LEFT JOIN evento_clinico ec ON ec.clinica_id = c.id
        LEFT JOIN pagamento       p  ON p.evento_id  = ec.id
        GROUP BY c.nome
        ORDER BY total_eventos DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(SUBSTR(reg.clinica,1,20), 22) ||
            RPAD(reg.total_eventos, 9) ||
            RPAD(reg.total_pgtos,   7) ||
            RPAD('R$ ' || TO_CHAR(reg.recebido,'FM99990.00'), 12) ||
            'R$ ' || TO_CHAR(reg.pendente,'FM99990.00')
        );
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('==============================================');
END;
/

-- ------------------------------------------------------------
-- BLOCO 2: Histórico de eventos por animal e tutor
-- JOIN animal + tutor + evento_clinico + pagamento
-- GROUP BY tutor, animal, espécie | ORDER BY total DESC
-- ------------------------------------------------------------
DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE('==============================================');
    DBMS_OUTPUT.PUT_LINE(' EVENTOS POR ANIMAL E TUTOR');
    DBMS_OUTPUT.PUT_LINE('==============================================');
    DBMS_OUTPUT.PUT_LINE(RPAD('Tutor',20) || RPAD('Animal',12) || RPAD('Espécie',10) || RPAD('Eventos',9) || 'Total Gasto');
    DBMS_OUTPUT.PUT_LINE(RPAD('-',62,'-'));

    FOR reg IN (
        SELECT
            t.nome                          AS tutor,
            a.nome                          AS animal,
            a.especie,
            COUNT(ec.id)                    AS total_eventos,
            NVL(SUM(p.valor), 0)            AS total_gasto
        FROM animal a
        JOIN tutor               t  ON t.id  = a.tutor_id
        LEFT JOIN evento_clinico ec ON ec.animal_id = a.id
        LEFT JOIN pagamento       p  ON p.evento_id = ec.id
        GROUP BY t.nome, a.nome, a.especie
        ORDER BY t.nome, total_eventos DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(SUBSTR(reg.tutor,1,18),  20) ||
            RPAD(SUBSTR(reg.animal,1,10), 12) ||
            RPAD(reg.especie, 10) ||
            RPAD(reg.total_eventos, 9) ||
            'R$ ' || TO_CHAR(reg.total_gasto,'FM99990.00')
        );
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('==============================================');
END;
/

-- ------------------------------------------------------------
-- BLOCO 3: Ranking de veterinários por volume de atendimentos
-- JOIN veterinario + clinica + evento_clinico + pagamento
-- GROUP BY especialidade, vet | ORDER BY total_eventos DESC
-- ------------------------------------------------------------
DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE('==============================================');
    DBMS_OUTPUT.PUT_LINE(' RANKING DE VETERINÁRIOS POR ATENDIMENTOS');
    DBMS_OUTPUT.PUT_LINE('==============================================');
    DBMS_OUTPUT.PUT_LINE(RPAD('Veterinário',22) || RPAD('Especialidade',16) || RPAD('Eventos',9) || 'Faturado');
    DBMS_OUTPUT.PUT_LINE(RPAD('-',62,'-'));

    FOR reg IN (
        SELECT
            v.nome                          AS veterinario,
            v.especialidade,
            COUNT(ec.id)                    AS total_eventos,
            NVL(SUM(p.valor), 0)            AS total_faturado
        FROM veterinario v
        LEFT JOIN evento_clinico ec ON ec.veterinario_id = v.id
        LEFT JOIN pagamento       p  ON p.evento_id = ec.id
        GROUP BY v.nome, v.especialidade
        ORDER BY total_eventos DESC, total_faturado DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(SUBSTR(reg.veterinario,1,20),   22) ||
            RPAD(SUBSTR(reg.especialidade,1,14), 16) ||
            RPAD(reg.total_eventos, 9) ||
            'R$ ' || TO_CHAR(reg.total_faturado,'FM99990.00')
        );
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('==============================================');
END;
/

-- ------------------------------------------------------------
-- BLOCO 4: LAG/LEAD -- Histórico de eventos por animal
-- Mostra o evento anterior, atual e próximo para cada animal
-- NVL exibe "Vazio" quando não há anterior ou próximo
-- ------------------------------------------------------------
DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE('==============================================');
    DBMS_OUTPUT.PUT_LINE(' HISTÓRICO DE EVENTOS (ANTERIOR/ATUAL/PRÓXIMO)');
    DBMS_OUTPUT.PUT_LINE('==============================================');
    DBMS_OUTPUT.PUT_LINE(
        RPAD('Animal',10)   ||
        RPAD('Data',12)     ||
        RPAD('Anterior',18) ||
        RPAD('Atual',18)    ||
        'Próximo'
    );
    DBMS_OUTPUT.PUT_LINE(RPAD('-',80,'-'));

    FOR reg IN (
        SELECT
            nome_animal,
            data_evento,
            NVL(LAG(tipo_evento)  OVER (PARTITION BY animal_id ORDER BY data_evento, hora_evento), 'Vazio') AS evento_anterior,
            tipo_evento                                                                                        AS evento_atual,
            NVL(LEAD(tipo_evento) OVER (PARTITION BY animal_id ORDER BY data_evento, hora_evento), 'Vazio') AS proximo_evento
        FROM (
            SELECT
                ec.animal_id,
                a.nome      AS nome_animal,
                ec.tipo_evento,
                ec.data_evento,
                ec.hora_evento
            FROM evento_clinico ec
            JOIN animal a ON a.id = ec.animal_id
        )
        ORDER BY nome_animal, data_evento, hora_evento
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(SUBSTR(reg.nome_animal,1,8), 10) ||
            RPAD(TO_CHAR(reg.data_evento,'DD/MM/YYYY'), 12) ||
            RPAD(SUBSTR(reg.evento_anterior,1,16), 18) ||
            RPAD(SUBSTR(reg.evento_atual,   1,16), 18) ||
            SUBSTR(reg.proximo_evento, 1,16)
        );
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('==============================================');
END;
/

-- ------------------------------------------------------------
-- BLOCO 5: RELATÓRIO DE EVENTOS POR CLÍNICA (cursor explícito)
-- Tomada de decisão: classifica cada evento por tipo_evento
-- Totaliza subtotal por clínica e total geral
-- ------------------------------------------------------------
DECLARE
    CURSOR cur_clinicas IS
        SELECT DISTINCT c.id, c.nome, c.cidade
        FROM clinica c
        JOIN evento_clinico ec ON ec.clinica_id = c.id
        ORDER BY c.nome;

    CURSOR cur_eventos (p_clinica_id VARCHAR2) IS
        SELECT
            ec.data_evento,
            ec.hora_evento,
            ec.tipo_evento,
            a.nome      AS animal,
            v.nome      AS veterinario,
            NVL(p.valor, 0)                 AS valor,
            NVL(p.status_pagamento, '-')    AS status_pagamento
        FROM evento_clinico  ec
        JOIN animal          a  ON a.id  = ec.animal_id
        JOIN veterinario     v  ON v.id  = ec.veterinario_id
        LEFT JOIN pagamento  p  ON p.evento_id = ec.id
        WHERE ec.clinica_id = p_clinica_id
        ORDER BY ec.data_evento, ec.hora_evento;

    v_sub_eventos   NUMBER := 0;
    v_sub_valor     NUMBER := 0;
    v_total_eventos NUMBER := 0;
    v_total_valor   NUMBER := 0;
    v_label         VARCHAR2(20);
BEGIN
    DBMS_OUTPUT.PUT_LINE('==========================================================');
    DBMS_OUTPUT.PUT_LINE(' RELATÓRIO DE EVENTOS POR CLÍNICA');
    DBMS_OUTPUT.PUT_LINE('==========================================================');

    FOR clin IN cur_clinicas LOOP
        v_sub_eventos := 0;
        v_sub_valor   := 0;

        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('Clínica: ' || clin.nome || ' (' || clin.cidade || ')');
        DBMS_OUTPUT.PUT_LINE(RPAD('-',70,'-'));
        DBMS_OUTPUT.PUT_LINE(RPAD('Data',12) || RPAD('Tipo',12) || RPAD('Animal',12) ||
                             RPAD('Veterinário',22) || RPAD('Valor',10) || 'Status');
        DBMS_OUTPUT.PUT_LINE(RPAD('-',70,'-'));

        FOR ev IN cur_eventos(clin.id) LOOP
            -- Tomada de decisão: classificar tipo de evento
            IF ev.tipo_evento = 'CONSULTA' THEN
                v_label := 'Consulta';
            ELSIF ev.tipo_evento = 'VACINA' THEN
                v_label := 'Vacinação';
            ELSIF ev.tipo_evento = 'EXAME' THEN
                v_label := 'Exame Diagnóst.';
            ELSIF ev.tipo_evento = 'CIRURGIA' THEN
                v_label := '*** CIRURGIA ***';
            ELSE
                v_label := 'Outro Proced.';
            END IF;

            DBMS_OUTPUT.PUT_LINE(
                RPAD(TO_CHAR(ev.data_evento,'DD/MM/YYYY'), 12) ||
                RPAD(SUBSTR(v_label,1,10),                  12) ||
                RPAD(SUBSTR(ev.animal,1,10),                12) ||
                RPAD(SUBSTR(ev.veterinario,1,20),           22) ||
                RPAD('R$' || TO_CHAR(ev.valor,'FM9990.00'), 10) ||
                ev.status_pagamento
            );

            v_sub_eventos := v_sub_eventos + 1;
            v_sub_valor   := v_sub_valor   + ev.valor;
        END LOOP;

        DBMS_OUTPUT.PUT_LINE(RPAD('-',50,'-'));
        DBMS_OUTPUT.PUT_LINE('Subtotal: ' || v_sub_eventos ||
                             ' eventos | R$ ' || TO_CHAR(v_sub_valor,'FM99990.00'));

        v_total_eventos := v_total_eventos + v_sub_eventos;
        v_total_valor   := v_total_valor   + v_sub_valor;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('==========================================================');
    DBMS_OUTPUT.PUT_LINE('TOTAL GERAL: ' || v_total_eventos ||
                         ' eventos | R$ ' || TO_CHAR(v_total_valor,'FM99990.00'));
    DBMS_OUTPUT.PUT_LINE('==========================================================');

EXCEPTION
    WHEN OTHERS THEN
        INSERT INTO log_erros (nome_procedure, codigo_erro, mensagem_erro)
        VALUES ('bloco_eventos_por_clinica', SQLCODE, SQLERRM);
        COMMIT;
        RAISE;
END;
/

-- ------------------------------------------------------------
-- BLOCO 6: RELATÓRIO COMPLETO DE ANIMAIS (cursor explícito)
-- Lista TODOS os registros de animais com classificação de porte
-- Totais numéricos + resumo agrupado por espécie
-- ------------------------------------------------------------
DECLARE
    CURSOR cur_todos_animais IS
        SELECT
            a.nome,
            a.especie,
            a.raca,
            a.porte,
            a.genero,
            a.data_nascimento,
            t.nome AS tutor
        FROM animal a
        JOIN tutor t ON t.id = a.tutor_id
        ORDER BY a.especie, a.nome;

    CURSOR cur_por_especie IS
        SELECT
            a.especie,
            COUNT(a.id)                     AS total,
            ROUND(AVG(
                MONTHS_BETWEEN(SYSDATE, a.data_nascimento) / 12
            ), 1)                           AS media_idade_anos,
            COUNT(CASE WHEN a.genero = 'MACHO' THEN 1 END) AS machos,
            COUNT(CASE WHEN a.genero = 'FEMEA' THEN 1 END) AS femeas
        FROM animal a
        WHERE a.data_nascimento IS NOT NULL
        GROUP BY a.especie
        ORDER BY total DESC;

    v_total  NUMBER := 0;
    v_machos NUMBER := 0;
    v_femeas NUMBER := 0;
    v_label  VARCHAR2(20);
BEGIN
    DBMS_OUTPUT.PUT_LINE('==========================================================');
    DBMS_OUTPUT.PUT_LINE(' RELATÓRIO COMPLETO DE ANIMAIS');
    DBMS_OUTPUT.PUT_LINE('==========================================================');
    DBMS_OUTPUT.PUT_LINE(RPAD('Nome',10) || RPAD('Espécie',9) || RPAD('Raça',18) ||
                         RPAD('Gênero',8) || RPAD('Porte',14) || 'Tutor');
    DBMS_OUTPUT.PUT_LINE(RPAD('-',72,'-'));

    FOR an IN cur_todos_animais LOOP
        -- Tomada de decisão: classificar porte
        IF an.porte = 'PEQUENO' THEN
            v_label := 'Pequeno Porte';
        ELSIF an.porte = 'MEDIO' THEN
            v_label := 'Médio Porte';
        ELSIF an.porte = 'GRANDE' THEN
            v_label := 'Grande Porte';
        ELSE
            v_label := 'N/D';
        END IF;

        DBMS_OUTPUT.PUT_LINE(
            RPAD(SUBSTR(an.nome,1,8),   10) ||
            RPAD(an.especie,             9) ||
            RPAD(SUBSTR(an.raca,1,16),  18) ||
            RPAD(NVL(an.genero,'-'),     8) ||
            RPAD(v_label,               14) ||
            SUBSTR(an.tutor,1,20)
        );

        v_total := v_total + 1;
        IF an.genero = 'MACHO' THEN v_machos := v_machos + 1; END IF;
        IF an.genero = 'FEMEA' THEN v_femeas := v_femeas + 1; END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(RPAD('-',72,'-'));
    DBMS_OUTPUT.PUT_LINE('TOTAL: ' || v_total || ' animais  |  Machos: ' ||
                         v_machos  || '  |  Fêmeas: ' || v_femeas);

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== RESUMO POR ESPÉCIE ===');
    DBMS_OUTPUT.PUT_LINE(RPAD('Espécie',10) || RPAD('Total',7) ||
                         RPAD('Média Idade',13) || RPAD('Machos',8) || 'Fêmeas');
    DBMS_OUTPUT.PUT_LINE(RPAD('-',46,'-'));

    FOR sp IN cur_por_especie LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(sp.especie,            10) ||
            RPAD(sp.total,               7) ||
            RPAD(sp.media_idade_anos || ' anos', 13) ||
            RPAD(sp.machos,              8) ||
            sp.femeas
        );
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('==========================================================');

EXCEPTION
    WHEN OTHERS THEN
        INSERT INTO log_erros (nome_procedure, codigo_erro, mensagem_erro)
        VALUES ('bloco_relatorio_animais', SQLCODE, SQLERRM);
        COMMIT;
        RAISE;
END;
/

-- ------------------------------------------------------------
-- BLOCO 7: RELATÓRIO DE VETERINÁRIOS POR ESPECIALIDADE (cursor explícito)
-- Tomada de decisão: classifica nível de atividade por volume de eventos
-- Subtotal por especialidade + total geral
-- ------------------------------------------------------------
DECLARE
    CURSOR cur_veterinarios IS
        SELECT
            v.nome                  AS veterinario,
            v.especialidade,
            v.crmv,
            c.nome                  AS clinica,
            COUNT(ec.id)            AS total_eventos
        FROM veterinario     v
        JOIN clinica          c  ON c.id  = v.clinica_id
        LEFT JOIN evento_clinico ec ON ec.veterinario_id = v.id
        GROUP BY v.nome, v.especialidade, v.crmv, c.nome
        ORDER BY v.especialidade, total_eventos DESC;

    v_espec_atual VARCHAR2(100) := '##';
    v_sub_espec   NUMBER := 0;
    v_total_geral NUMBER := 0;
    v_nivel       VARCHAR2(15);
BEGIN
    DBMS_OUTPUT.PUT_LINE('==========================================================');
    DBMS_OUTPUT.PUT_LINE(' RELATÓRIO DE VETERINÁRIOS POR ESPECIALIDADE');
    DBMS_OUTPUT.PUT_LINE('==========================================================');

    FOR vet IN cur_veterinarios LOOP
        -- Quebra de grupo por especialidade
        IF vet.especialidade != v_espec_atual THEN
            IF v_espec_atual != '##' THEN
                DBMS_OUTPUT.PUT_LINE(RPAD('-',50,'-'));
                DBMS_OUTPUT.PUT_LINE('Subtotal [' || v_espec_atual || ']: ' || v_sub_espec || ' vet(s)');
            END IF;
            v_espec_atual := vet.especialidade;
            v_sub_espec   := 0;
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('Especialidade: ' || vet.especialidade);
            DBMS_OUTPUT.PUT_LINE(RPAD('Nome',22) || RPAD('CRMV',16) ||
                                 RPAD('Clínica',18) || RPAD('Eventos',9) || 'Nível');
            DBMS_OUTPUT.PUT_LINE(RPAD('-',78,'-'));
        END IF;

        -- Tomada de decisão: nível de atividade por volume de eventos
        IF vet.total_eventos >= 5 THEN
            v_nivel := 'Muito Ativo';
        ELSIF vet.total_eventos >= 2 THEN
            v_nivel := 'Ativo';
        ELSE
            v_nivel := 'Baixa Atividade';
        END IF;

        DBMS_OUTPUT.PUT_LINE(
            RPAD(SUBSTR(vet.veterinario,1,20), 22) ||
            RPAD(vet.crmv,                     16) ||
            RPAD(SUBSTR(vet.clinica,1,16),     18) ||
            RPAD(vet.total_eventos,             9) ||
            v_nivel
        );

        v_sub_espec   := v_sub_espec   + 1;
        v_total_geral := v_total_geral + 1;
    END LOOP;

    IF v_espec_atual != '##' THEN
        DBMS_OUTPUT.PUT_LINE(RPAD('-',50,'-'));
        DBMS_OUTPUT.PUT_LINE('Subtotal [' || v_espec_atual || ']: ' || v_sub_espec || ' vet(s)');
    END IF;

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('==========================================================');
    DBMS_OUTPUT.PUT_LINE('TOTAL GERAL: ' || v_total_geral || ' veterinários');
    DBMS_OUTPUT.PUT_LINE('==========================================================');

EXCEPTION
    WHEN OTHERS THEN
        INSERT INTO log_erros (nome_procedure, codigo_erro, mensagem_erro)
        VALUES ('bloco_relatorio_veterinarios', SQLCODE, SQLERRM);
        COMMIT;
        RAISE;
END;
/

-- ------------------------------------------------------------
-- BLOCO 8: RELATÓRIO DE PAGAMENTOS POR STATUS (cursor explícito)
-- Tomada de decisão: classifica cada pagamento pelo status
-- Totaliza valores por status e método de pagamento
-- ------------------------------------------------------------
DECLARE
    CURSOR cur_pagamentos IS
        SELECT
            p.metodo_pagamento,
            p.valor,
            p.status_pagamento,
            p.data_pagamento,
            a.nome  AS animal,
            t.nome  AS tutor,
            ec.tipo_evento
        FROM pagamento       p
        JOIN evento_clinico  ec ON ec.id  = p.evento_id
        JOIN animal          a  ON a.id   = ec.animal_id
        JOIN tutor           t  ON t.id   = a.tutor_id
        ORDER BY p.status_pagamento, p.data_pagamento DESC;

    v_total_pgtos  NUMBER := 0;
    v_total_pago   NUMBER := 0;
    v_total_pend   NUMBER := 0;
    v_total_outros NUMBER := 0;
    v_val_pago     NUMBER := 0;
    v_val_pend     NUMBER := 0;
    v_label        VARCHAR2(20);
BEGIN
    DBMS_OUTPUT.PUT_LINE('==========================================================');
    DBMS_OUTPUT.PUT_LINE(' RELATÓRIO DE PAGAMENTOS POR STATUS');
    DBMS_OUTPUT.PUT_LINE('==========================================================');
    DBMS_OUTPUT.PUT_LINE(RPAD('Animal',10) || RPAD('Tutor',16) || RPAD('Evento',14) ||
                         RPAD('Método',9)  || RPAD('Valor',10) || RPAD('Status',12) || 'Classificação');
    DBMS_OUTPUT.PUT_LINE(RPAD('-',80,'-'));

    FOR pg IN cur_pagamentos LOOP
        -- Tomada de decisão: classificar status do pagamento
        IF pg.status_pagamento = 'PAGO' THEN
            v_label       := 'Liquidado';
            v_total_pago  := v_total_pago + 1;
            v_val_pago    := v_val_pago   + pg.valor;
        ELSIF pg.status_pagamento = 'PENDENTE' THEN
            v_label       := 'A Receber';
            v_total_pend  := v_total_pend + 1;
            v_val_pend    := v_val_pend   + pg.valor;
        ELSIF pg.status_pagamento = 'CANCELADO' THEN
            v_label        := 'Cancelado';
            v_total_outros := v_total_outros + 1;
        ELSE
            v_label        := 'Reembolsado';
            v_total_outros := v_total_outros + 1;
        END IF;

        DBMS_OUTPUT.PUT_LINE(
            RPAD(SUBSTR(pg.animal,1,8),       10) ||
            RPAD(SUBSTR(pg.tutor,1,14),       16) ||
            RPAD(SUBSTR(pg.tipo_evento,1,12), 14) ||
            RPAD(pg.metodo_pagamento,          9) ||
            RPAD('R$' || TO_CHAR(pg.valor,'FM9990.00'), 10) ||
            RPAD(pg.status_pagamento,         12) ||
            v_label
        );

        v_total_pgtos := v_total_pgtos + 1;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(RPAD('-',80,'-'));
    DBMS_OUTPUT.PUT_LINE('RESUMO:');
    DBMS_OUTPUT.PUT_LINE('  Total de pagamentos    : ' || v_total_pgtos);
    DBMS_OUTPUT.PUT_LINE('  Pagos                  : ' || v_total_pago ||
                         '  (R$ ' || TO_CHAR(v_val_pago,'FM99990.00') || ')');
    DBMS_OUTPUT.PUT_LINE('  A Receber              : ' || v_total_pend ||
                         '  (R$ ' || TO_CHAR(v_val_pend,'FM99990.00') || ')');
    DBMS_OUTPUT.PUT_LINE('  Cancelados/Reembolsados: ' || v_total_outros);
    DBMS_OUTPUT.PUT_LINE('==========================================================');

EXCEPTION
    WHEN OTHERS THEN
        INSERT INTO log_erros (nome_procedure, codigo_erro, mensagem_erro)
        VALUES ('bloco_relatorio_pagamentos', SQLCODE, SQLERRM);
        COMMIT;
        RAISE;
END;
/
