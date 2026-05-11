-- ============================================================
-- CLYVO VET -- BANCO DE DADOS ORACLE
-- Arquivo 06: Blocos Anonimos para Consultas e Relatorios
-- ============================================================

-- ------------------------------------------------------------
-- BLOCO 1: Faturamento por clinica
-- JOIN evento_clinico + clinica + pagamento
-- GROUP BY clinica | ORDER BY total_eventos DESC
-- ------------------------------------------------------------
DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE('==============================================');
    DBMS_OUTPUT.PUT_LINE(' FATURAMENTO POR CLINICA');
    DBMS_OUTPUT.PUT_LINE('==============================================');
    DBMS_OUTPUT.PUT_LINE(RPAD('Clinica',22) || RPAD('Eventos',9) || RPAD('Pgtos',7) || RPAD('Recebido',12) || 'Pendente');
    DBMS_OUTPUT.PUT_LINE(RPAD('-',62,'-'));

    FOR reg IN (
        SELECT
            c.nome                                                                      AS clinica,
            COUNT(DISTINCT ec.id)                                                       AS total_eventos,
            COUNT(DISTINCT p.id)                                                        AS total_pgtos,
            NVL(SUM(CASE WHEN p.status_pagamento = 'PAGO'     THEN p.valor END), 0)    AS recebido,
            NVL(SUM(CASE WHEN p.status_pagamento = 'PENDENTE' THEN p.valor END), 0)    AS pendente
        FROM clinica c
        LEFT JOIN evento_clinico ec ON ec.clinica_id = c.id
        LEFT JOIN pagamento       p  ON p.evento_clinico_id = ec.id
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
-- BLOCO 2: Historico de eventos por animal e tutor
-- JOIN animal + tutor + evento_clinico + pagamento
-- GROUP BY tutor, animal, especie | ORDER BY total DESC
-- ------------------------------------------------------------
DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE('==============================================');
    DBMS_OUTPUT.PUT_LINE(' EVENTOS POR ANIMAL E TUTOR');
    DBMS_OUTPUT.PUT_LINE('==============================================');
    DBMS_OUTPUT.PUT_LINE(RPAD('Tutor',20) || RPAD('Animal',12) || RPAD('Especie',10) || RPAD('Eventos',9) || 'Total Gasto');
    DBMS_OUTPUT.PUT_LINE(RPAD('-',62,'-'));

    FOR reg IN (
        SELECT
            t.nome                          AS tutor,
            a.nome                          AS animal,
            a.especie,
            COUNT(ec.id)                    AS total_eventos,
            NVL(SUM(p.valor), 0)            AS total_gasto
        FROM animal a
        JOIN tutor            t  ON t.id  = a.tutor_id
        LEFT JOIN evento_clinico ec ON ec.animal_id = a.id
        LEFT JOIN pagamento       p  ON p.evento_clinico_id = ec.id
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
-- BLOCO 3: Ranking de veterinarios por volume de atendimentos
-- JOIN veterinario + clinica + evento_clinico + pagamento
-- GROUP BY especialidade, vet | ORDER BY total_eventos DESC
-- ------------------------------------------------------------
DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE('==============================================');
    DBMS_OUTPUT.PUT_LINE(' RANKING DE VETERINARIOS POR ATENDIMENTOS');
    DBMS_OUTPUT.PUT_LINE('==============================================');
    DBMS_OUTPUT.PUT_LINE(RPAD('Veterinario',22) || RPAD('Especialidade',16) || RPAD('Eventos',9) || 'Faturado');
    DBMS_OUTPUT.PUT_LINE(RPAD('-',62,'-'));

    FOR reg IN (
        SELECT
            v.nome                          AS veterinario,
            v.especialidade,
            COUNT(ec.id)                    AS total_eventos,
            NVL(SUM(p.valor), 0)            AS total_faturado
        FROM veterinario v
        LEFT JOIN evento_clinico ec ON ec.veterinario_id = v.id
        LEFT JOIN pagamento       p  ON p.evento_clinico_id = ec.id
        GROUP BY v.nome, v.especialidade
        ORDER BY total_eventos DESC, total_faturado DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(SUBSTR(reg.veterinario,1,20),    22) ||
            RPAD(SUBSTR(reg.especialidade,1,14),  16) ||
            RPAD(reg.total_eventos, 9) ||
            'R$ ' || TO_CHAR(reg.total_faturado,'FM99990.00')
        );
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('==============================================');
END;
/

-- ------------------------------------------------------------
-- BLOCO 4: LAG/LEAD -- Historico de eventos por animal
-- Mostra evento anterior, atual e proximo de cada animal
-- NVL exibe "Vazio" quando nao existe anterior ou proximo
-- ------------------------------------------------------------
DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE('==============================================');
    DBMS_OUTPUT.PUT_LINE(' HISTORICO DE EVENTOS (ANTERIOR/ATUAL/PROXIMO)');
    DBMS_OUTPUT.PUT_LINE('==============================================');
    DBMS_OUTPUT.PUT_LINE(
        RPAD('Animal',10)    ||
        RPAD('Data',12)      ||
        RPAD('Anterior',18)  ||
        RPAD('Atual',18)     ||
        'Proximo'
    );
    DBMS_OUTPUT.PUT_LINE(RPAD('-',80,'-'));

    FOR reg IN (
        SELECT
            nome_animal,
            data_evento,
            NVL(LAG(tipo_evento)  OVER (PARTITION BY animal_id ORDER BY data_evento, hora), 'Vazio') AS anterior,
            tipo_evento                                                                                 AS atual,
            NVL(LEAD(tipo_evento) OVER (PARTITION BY animal_id ORDER BY data_evento, hora), 'Vazio') AS proximo
        FROM (
            SELECT
                ec.animal_id,
                a.nome  AS nome_animal,
                ec.tipo_evento,
                ec.data AS data_evento,
                ec.hora
            FROM evento_clinico ec
            JOIN animal a ON a.id = ec.animal_id
        )
        ORDER BY nome_animal, data_evento, hora
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(SUBSTR(reg.nome_animal,1,8), 10) ||
            RPAD(TO_CHAR(reg.data_evento,'DD/MM/YYYY'), 12) ||
            RPAD(SUBSTR(reg.anterior,1,16), 18) ||
            RPAD(SUBSTR(reg.atual,   1,16), 18) ||
            SUBSTR(reg.proximo, 1,16)
        );
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('==============================================');
END;
/

-- ------------------------------------------------------------
-- BLOCO 5: RELATORIO DE EVENTOS POR CLINICA (cursor explicito)
-- Tomada de decisao: classifica cada evento pelo tipo_evento
-- Sumariza subtotal por clinica e total geral
-- ------------------------------------------------------------
DECLARE
    CURSOR cur_clinicas IS
        SELECT DISTINCT c.id, c.nome, c.cidade
        FROM clinica c
        JOIN evento_clinico ec ON ec.clinica_id = c.id
        ORDER BY c.nome;

    CURSOR cur_eventos (p_clinica_id VARCHAR2) IS
        SELECT
            ec.data,
            ec.hora,
            ec.tipo_evento,
            a.nome      AS animal,
            v.nome      AS veterinario,
            NVL(p.valor, 0)             AS valor,
            NVL(p.status_pagamento, '-') AS status_pgto
        FROM evento_clinico  ec
        JOIN animal          a  ON a.id  = ec.animal_id
        JOIN veterinario     v  ON v.id  = ec.veterinario_id
        LEFT JOIN pagamento  p  ON p.evento_clinico_id = ec.id
        WHERE ec.clinica_id = p_clinica_id
        ORDER BY ec.data, ec.hora;

    v_sub_eventos  NUMBER := 0;
    v_sub_valor    NUMBER := 0;
    v_total_geral  NUMBER := 0;
    v_total_valor  NUMBER := 0;
    v_classificacao VARCHAR2(20);
BEGIN
    DBMS_OUTPUT.PUT_LINE('==========================================================');
    DBMS_OUTPUT.PUT_LINE(' RELATORIO DE EVENTOS POR CLINICA');
    DBMS_OUTPUT.PUT_LINE('==========================================================');

    FOR clin IN cur_clinicas LOOP
        v_sub_eventos := 0;
        v_sub_valor   := 0;

        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('Clinica: ' || clin.nome || ' (' || clin.cidade || ')');
        DBMS_OUTPUT.PUT_LINE(RPAD('-',70,'-'));
        DBMS_OUTPUT.PUT_LINE(RPAD('Data',12) || RPAD('Tipo',12) || RPAD('Animal',12) ||
                             RPAD('Veterinario',22) || RPAD('Valor',10) || 'Status');
        DBMS_OUTPUT.PUT_LINE(RPAD('-',70,'-'));

        FOR ev IN cur_eventos(clin.id) LOOP
            -- Tomada de decisao: classificar o tipo de evento
            IF ev.tipo_evento = 'CONSULTA' THEN
                v_classificacao := 'Consulta Clinica';
            ELSIF ev.tipo_evento = 'VACINA' THEN
                v_classificacao := 'Vacinacao';
            ELSIF ev.tipo_evento = 'EXAME' THEN
                v_classificacao := 'Exame Diagnostico';
            ELSIF ev.tipo_evento = 'CIRURGIA' THEN
                v_classificacao := '*** CIRURGIA ***';
            ELSE
                v_classificacao := 'Outro Procedimento';
            END IF;

            DBMS_OUTPUT.PUT_LINE(
                RPAD(TO_CHAR(ev.data,'DD/MM/YYYY'), 12) ||
                RPAD(SUBSTR(v_classificacao,1,10),  12) ||
                RPAD(SUBSTR(ev.animal,1,10),         12) ||
                RPAD(SUBSTR(ev.veterinario,1,20),    22) ||
                RPAD('R$' || TO_CHAR(ev.valor,'FM9990.00'), 10) ||
                ev.status_pgto
            );

            v_sub_eventos := v_sub_eventos + 1;
            v_sub_valor   := v_sub_valor   + ev.valor;
        END LOOP;

        DBMS_OUTPUT.PUT_LINE(RPAD('-',50,'-'));
        DBMS_OUTPUT.PUT_LINE('Sub-total: ' || v_sub_eventos ||
                             ' eventos | R$ ' || TO_CHAR(v_sub_valor,'FM99990.00'));

        v_total_geral := v_total_geral + v_sub_eventos;
        v_total_valor := v_total_valor + v_sub_valor;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('==========================================================');
    DBMS_OUTPUT.PUT_LINE('TOTAL GERAL: ' || v_total_geral ||
                         ' eventos | R$ ' || TO_CHAR(v_total_valor,'FM99990.00'));
    DBMS_OUTPUT.PUT_LINE('==========================================================');

EXCEPTION
    WHEN OTHERS THEN
        INSERT INTO tb_log_erros (nome_procedure, codigo_erro, mensagem_erro)
        VALUES ('bloco_eventos_clinica', SQLCODE, SQLERRM);
        COMMIT;
        RAISE;
END;
/

-- ------------------------------------------------------------
-- BLOCO 6: RELATORIO COMPLETO DE ANIMAIS (cursor explicito)
-- Lista TODOS os registros de animal com classificacao de porte
-- Sumarizacao numerica total + sumarizacao agrupada por especie
-- ------------------------------------------------------------
DECLARE
    CURSOR cur_todos_animais IS
        SELECT
            a.nome,
            a.especie,
            a.raca,
            a.porte,
            a.sexo,
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
            ), 1)                           AS idade_media_anos,
            COUNT(CASE WHEN a.sexo = 'MACHO'  THEN 1 END) AS machos,
            COUNT(CASE WHEN a.sexo = 'FEMEA'  THEN 1 END) AS femeas
        FROM animal a
        WHERE a.data_nascimento IS NOT NULL
        GROUP BY a.especie
        ORDER BY total DESC;

    v_total     NUMBER := 0;
    v_machos    NUMBER := 0;
    v_femeas    NUMBER := 0;
    v_classif   VARCHAR2(15);
BEGIN
    DBMS_OUTPUT.PUT_LINE('==========================================================');
    DBMS_OUTPUT.PUT_LINE(' RELATORIO COMPLETO DE ANIMAIS');
    DBMS_OUTPUT.PUT_LINE('==========================================================');
    DBMS_OUTPUT.PUT_LINE(RPAD('Nome',10) || RPAD('Especie',9) || RPAD('Raca',18) ||
                         RPAD('Sexo',7)  || RPAD('Porte',10)  || 'Tutor');
    DBMS_OUTPUT.PUT_LINE(RPAD('-',72,'-'));

    FOR an IN cur_todos_animais LOOP
        -- Tomada de decisao: classificar porte
        IF an.porte = 'PEQUENO' THEN
            v_classif := 'Pequeno Porte';
        ELSIF an.porte = 'MEDIO' THEN
            v_classif := 'Medio Porte';
        ELSIF an.porte = 'GRANDE' THEN
            v_classif := 'Grande Porte';
        ELSE
            v_classif := 'N/D';
        END IF;

        DBMS_OUTPUT.PUT_LINE(
            RPAD(SUBSTR(an.nome,1,8),     10) ||
            RPAD(an.especie,               9) ||
            RPAD(SUBSTR(an.raca,1,16),    18) ||
            RPAD(NVL(an.sexo,'-'),         7) ||
            RPAD(v_classif,               10) ||
            SUBSTR(an.tutor,1,20)
        );

        v_total  := v_total + 1;
        IF an.sexo = 'MACHO'  THEN v_machos := v_machos + 1; END IF;
        IF an.sexo = 'FEMEA'  THEN v_femeas := v_femeas + 1; END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(RPAD('-',72,'-'));
    DBMS_OUTPUT.PUT_LINE('TOTAL: ' || v_total || ' animais  |  Machos: ' ||
                         v_machos  || '  |  Femeas: ' || v_femeas);

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== SUMARIZACAO POR ESPECIE ===');
    DBMS_OUTPUT.PUT_LINE(RPAD('Especie',10) || RPAD('Total',7) ||
                         RPAD('Idade Media',13) || RPAD('Machos',8) || 'Femeas');
    DBMS_OUTPUT.PUT_LINE(RPAD('-',46,'-'));

    FOR esp IN cur_por_especie LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(esp.especie,       10) ||
            RPAD(esp.total,          7) ||
            RPAD(esp.idade_media_anos || ' anos', 13) ||
            RPAD(esp.machos,         8) ||
            esp.femeas
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
-- BLOCO 7: RELATORIO DE VETERINARIOS POR ESPECIALIDADE (cursor explicito)
-- Tomada de decisao: classifica nivel de atividade pelo volume de eventos
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

    v_esp_atual     VARCHAR2(100) := '##';
    v_sub_esp       NUMBER := 0;
    v_total_geral   NUMBER := 0;
    v_nivel         VARCHAR2(15);
BEGIN
    DBMS_OUTPUT.PUT_LINE('==========================================================');
    DBMS_OUTPUT.PUT_LINE(' RELATORIO DE VETERINARIOS POR ESPECIALIDADE');
    DBMS_OUTPUT.PUT_LINE('==========================================================');

    FOR vet IN cur_veterinarios LOOP
        -- Quebra de grupo por especialidade
        IF vet.especialidade != v_esp_atual THEN
            IF v_esp_atual != '##' THEN
                DBMS_OUTPUT.PUT_LINE(RPAD('-',50,'-'));
                DBMS_OUTPUT.PUT_LINE('Sub-total [' || v_esp_atual || ']: ' || v_sub_esp || ' vet(s)');
            END IF;
            v_esp_atual := vet.especialidade;
            v_sub_esp   := 0;
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('Especialidade: ' || vet.especialidade);
            DBMS_OUTPUT.PUT_LINE(RPAD('Nome',22) || RPAD('CRMV',16) ||
                                 RPAD('Clinica',18) || RPAD('Eventos',9) || 'Nivel');
            DBMS_OUTPUT.PUT_LINE(RPAD('-',78,'-'));
        END IF;

        -- Tomada de decisao: nivel de atividade pelo volume de eventos
        IF vet.total_eventos >= 5 THEN
            v_nivel := 'Muito Ativo';
        ELSIF vet.total_eventos >= 2 THEN
            v_nivel := 'Ativo';
        ELSE
            v_nivel := 'Pouco Ativo';
        END IF;

        DBMS_OUTPUT.PUT_LINE(
            RPAD(SUBSTR(vet.veterinario,1,20), 22) ||
            RPAD(vet.crmv,                     16) ||
            RPAD(SUBSTR(vet.clinica,1,16),      18) ||
            RPAD(vet.total_eventos,              9) ||
            v_nivel
        );

        v_sub_esp     := v_sub_esp     + 1;
        v_total_geral := v_total_geral + 1;
    END LOOP;

    IF v_esp_atual != '##' THEN
        DBMS_OUTPUT.PUT_LINE(RPAD('-',50,'-'));
        DBMS_OUTPUT.PUT_LINE('Sub-total [' || v_esp_atual || ']: ' || v_sub_esp || ' vet(s)');
    END IF;

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('==========================================================');
    DBMS_OUTPUT.PUT_LINE('TOTAL GERAL: ' || v_total_geral || ' veterinarios');
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
-- BLOCO 8: RELATORIO DE PAGAMENTOS POR STATUS (cursor explicito)
-- Tomada de decisao: classifica cada pagamento pelo status
-- Sumariza totais por status e forma de pagamento
-- ------------------------------------------------------------
DECLARE
    CURSOR cur_pagamentos IS
        SELECT
            p.forma_pagamento,
            p.valor,
            p.status_pagamento,
            p.data_pagamento,
            a.nome  AS animal,
            t.nome  AS tutor,
            ec.tipo_evento
        FROM pagamento       p
        JOIN evento_clinico  ec ON ec.id  = p.evento_clinico_id
        JOIN animal          a  ON a.id   = ec.animal_id
        JOIN tutor           t  ON t.id   = a.tutor_id
        ORDER BY p.status_pagamento, p.data_pagamento DESC;

    v_total_pgtos   NUMBER := 0;
    v_total_pago    NUMBER := 0;
    v_total_pend    NUMBER := 0;
    v_total_canc    NUMBER := 0;
    v_val_pago      NUMBER := 0;
    v_val_pend      NUMBER := 0;
    v_classificacao VARCHAR2(20);
BEGIN
    DBMS_OUTPUT.PUT_LINE('==========================================================');
    DBMS_OUTPUT.PUT_LINE(' RELATORIO DE PAGAMENTOS POR STATUS');
    DBMS_OUTPUT.PUT_LINE('==========================================================');
    DBMS_OUTPUT.PUT_LINE(RPAD('Animal',10) || RPAD('Tutor',16) || RPAD('Evento',12) ||
                         RPAD('Forma',9)   || RPAD('Valor',10)  || RPAD('Status',12) || 'Classificacao');
    DBMS_OUTPUT.PUT_LINE(RPAD('-',80,'-'));

    FOR pg IN cur_pagamentos LOOP
        -- Tomada de decisao: classificar o status do pagamento
        IF pg.status_pagamento = 'PAGO' THEN
            v_classificacao := 'Quitado';
            v_total_pago := v_total_pago + 1;
            v_val_pago   := v_val_pago   + pg.valor;
        ELSIF pg.status_pagamento = 'PENDENTE' THEN
            v_classificacao := 'A Receber';
            v_total_pend := v_total_pend + 1;
            v_val_pend   := v_val_pend   + pg.valor;
        ELSIF pg.status_pagamento = 'CANCELADO' THEN
            v_classificacao := 'Cancelado';
            v_total_canc := v_total_canc + 1;
        ELSE
            v_classificacao := 'Estornado';
            v_total_canc := v_total_canc + 1;
        END IF;

        DBMS_OUTPUT.PUT_LINE(
            RPAD(SUBSTR(pg.animal,1,8),    10) ||
            RPAD(SUBSTR(pg.tutor,1,14),    16) ||
            RPAD(SUBSTR(pg.tipo_evento,1,10), 12) ||
            RPAD(pg.forma_pagamento,        9) ||
            RPAD('R$' || TO_CHAR(pg.valor,'FM9990.00'), 10) ||
            RPAD(pg.status_pagamento,      12) ||
            v_classificacao
        );

        v_total_pgtos := v_total_pgtos + 1;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(RPAD('-',80,'-'));
    DBMS_OUTPUT.PUT_LINE('RESUMO:');
    DBMS_OUTPUT.PUT_LINE('  Total de pagamentos : ' || v_total_pgtos);
    DBMS_OUTPUT.PUT_LINE('  Pagos               : ' || v_total_pago ||
                         '  (R$ ' || TO_CHAR(v_val_pago,'FM99990.00') || ')');
    DBMS_OUTPUT.PUT_LINE('  A receber           : ' || v_total_pend ||
                         '  (R$ ' || TO_CHAR(v_val_pend,'FM99990.00') || ')');
    DBMS_OUTPUT.PUT_LINE('  Cancelados/Estornados: ' || v_total_canc);
    DBMS_OUTPUT.PUT_LINE('==========================================================');

EXCEPTION
    WHEN OTHERS THEN
        INSERT INTO tb_log_erros (nome_procedure, codigo_erro, mensagem_erro)
        VALUES ('bloco_relatorio_pagamentos', SQLCODE, SQLERRM);
        COMMIT;
        RAISE;
END;
/
