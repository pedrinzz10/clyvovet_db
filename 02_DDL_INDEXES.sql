-- ============================================================
-- CLYVO VET -- BANCO DE DADOS ORACLE
-- Arquivo 02: DDL -- Indices otimizados
-- ============================================================

-- tb_usuarios
CREATE INDEX idx_usuarios_email    ON tb_usuarios(email);
CREATE INDEX idx_usuarios_perfil   ON tb_usuarios(perfil);
CREATE INDEX idx_usuarios_endereco ON tb_usuarios(endereco_id);

-- tb_animais
CREATE INDEX idx_animais_especie    ON tb_animais(especie);
CREATE INDEX idx_animais_modalidade ON tb_animais(modalidade);
CREATE INDEX idx_animais_microchip  ON tb_animais(codigo_microchip);

-- tb_donos_animal
CREATE INDEX idx_dono_usuario ON tb_donos_animal(usuario_id);
CREATE INDEX idx_dono_animal  ON tb_donos_animal(animal_id);

-- tb_enderecos (busca geografica por proximidade)
CREATE INDEX idx_enderecos_cidade    ON tb_enderecos(cidade);
CREATE INDEX idx_enderecos_estado    ON tb_enderecos(estado);
CREATE INDEX idx_enderecos_cep       ON tb_enderecos(cep);
CREATE INDEX idx_enderecos_latitude  ON tb_enderecos(latitude);
CREATE INDEX idx_enderecos_longitude ON tb_enderecos(longitude);

-- tb_clinicas
CREATE INDEX idx_clinicas_endereco   ON tb_clinicas(endereco_id);
CREATE INDEX idx_clinicas_ativo      ON tb_clinicas(ativo, parceira);

-- tb_veterinarios
CREATE INDEX idx_vet_usuario    ON tb_veterinarios(usuario_id);
CREATE INDEX idx_vet_crm        ON tb_veterinarios(crm);
CREATE INDEX idx_vet_disponivel ON tb_veterinarios(disponivel);

-- tb_vet_clinicas
CREATE INDEX idx_vc_veterinario ON tb_vet_clinicas(veterinario_id);
CREATE INDEX idx_vc_clinica     ON tb_vet_clinicas(clinica_id);

-- tb_agendas_vet (busca de slots por vet + dia)
CREATE INDEX idx_agenda_vet_dia ON tb_agendas_vet(veterinario_id, dia_semana);
CREATE INDEX idx_agenda_clinica ON tb_agendas_vet(clinica_id);

-- tb_bloqueios_vet (busca de bloqueios por vet + data)
CREATE INDEX idx_bloqueio_vet_data ON tb_bloqueios_vet(veterinario_id, data_bloqueio);

-- tb_consultas (queries mais comuns: por vet+data, por animal, por situacao)
CREATE INDEX idx_consulta_vet_data ON tb_consultas(veterinario_id, data_consulta);
CREATE INDEX idx_consulta_animal   ON tb_consultas(animal_id);
CREATE INDEX idx_consulta_dono     ON tb_consultas(dono_id);
CREATE INDEX idx_consulta_situacao ON tb_consultas(situacao);
CREATE INDEX idx_consulta_clinica  ON tb_consultas(clinica_id);
CREATE INDEX idx_consulta_data     ON tb_consultas(data_consulta);

-- tb_lembretes_consulta
CREATE INDEX idx_lembrete_consulta ON tb_lembretes_consulta(consulta_id);
CREATE INDEX idx_lembrete_situacao ON tb_lembretes_consulta(situacao, lembrar_em);

-- tb_eventos_saude (busca por animal + data_prevista, query mais comum)
CREATE INDEX idx_evento_animal_prazo ON tb_eventos_saude(animal_id, data_prevista);
CREATE INDEX idx_evento_situacao     ON tb_eventos_saude(situacao);
CREATE INDEX idx_evento_tipo         ON tb_eventos_saude(tipo);

-- tb_registros_vacina
CREATE INDEX idx_registro_animal ON tb_registros_vacina(animal_id);
CREATE INDEX idx_registro_vet    ON tb_registros_vacina(veterinario_id);

-- tb_documentos_animal
CREATE INDEX idx_doc_animal ON tb_documentos_animal(animal_id);
CREATE INDEX idx_doc_tipo   ON tb_documentos_animal(tipo);

-- tb_notificacoes (nao lidas por usuario -- query mais frequente)
CREATE INDEX idx_notif_usuario_lido ON tb_notificacoes(usuario_id, lido, criado_em DESC);
CREATE INDEX idx_notif_tipo         ON tb_notificacoes(tipo);

-- tb_avaliacoes
CREATE INDEX idx_avaliacao_alvo      ON tb_avaliacoes(tipo_alvo, id_alvo);
CREATE INDEX idx_avaliacao_avaliador ON tb_avaliacoes(avaliador_id);

-- tb_carteirinhas
CREATE INDEX idx_carteirinha_qr ON tb_carteirinhas(token_qr_code);
