-- ============================================================
-- CLYVO VET -- ORACLE DATABASE
-- Arquivo 02: DDL -- Índices Otimizados
-- ============================================================

-- tutor
CREATE INDEX idx_tutor_email  ON tutor(email);
CREATE INDEX idx_tutor_cpf    ON tutor(cpf);
CREATE INDEX idx_tutor_cidade ON tutor(cidade);

-- animal
CREATE INDEX idx_animal_tutor   ON animal(tutor_id);
CREATE INDEX idx_animal_especie ON animal(especie);
CREATE INDEX idx_animal_porte   ON animal(porte);

-- clinica
CREATE INDEX idx_clinica_cnpj   ON clinica(cnpj);
CREATE INDEX idx_clinica_cidade ON clinica(cidade);

-- veterinario
CREATE INDEX idx_vet_clinica       ON veterinario(clinica_id);
CREATE INDEX idx_vet_crmv          ON veterinario(crmv);
CREATE INDEX idx_vet_cpf           ON veterinario(cpf);
CREATE INDEX idx_vet_especialidade ON veterinario(especialidade);

-- evento_clinico (consultas mais frequentes: por animal, por vet+data, por clínica)
CREATE INDEX idx_evento_animal      ON evento_clinico(animal_id);
CREATE INDEX idx_evento_veterinario ON evento_clinico(veterinario_id);
CREATE INDEX idx_evento_clinica     ON evento_clinico(clinica_id);
CREATE INDEX idx_evento_data        ON evento_clinico(data_evento);
CREATE INDEX idx_evento_tipo        ON evento_clinico(tipo_evento);
CREATE INDEX idx_evento_vet_data    ON evento_clinico(veterinario_id, data_evento);

-- pagamento
CREATE INDEX idx_pagamento_evento  ON pagamento(evento_id);
CREATE INDEX idx_pagamento_status  ON pagamento(status_pagamento);
CREATE INDEX idx_pagamento_metodo  ON pagamento(metodo_pagamento);
CREATE INDEX idx_pagamento_data    ON pagamento(data_pagamento);

-- produto
CREATE INDEX idx_produto_categoria ON produto(categoria);
CREATE INDEX idx_produto_especie   ON produto(especie_indicada);
CREATE INDEX idx_produto_ativo     ON produto(ativo);

-- sugestao_produto
CREATE INDEX idx_sugestao_animal  ON sugestao_produto(animal_id);
CREATE INDEX idx_sugestao_produto ON sugestao_produto(produto_id);
CREATE INDEX idx_sugestao_ativo   ON sugestao_produto(ativo);

-- lembrete
CREATE INDEX idx_lembrete_animal   ON lembrete(animal_id);
CREATE INDEX idx_lembrete_status   ON lembrete(status);
CREATE INDEX idx_lembrete_agendado ON lembrete(agendado_em);
CREATE INDEX idx_lembrete_tipo     ON lembrete(tipo);

-- evento_pet
CREATE INDEX idx_evento_pet_cidade       ON evento_pet(cidade);
CREATE INDEX idx_evento_pet_tipo         ON evento_pet(tipo);
CREATE INDEX idx_evento_pet_data_inicio  ON evento_pet(data_inicio);
CREATE INDEX idx_evento_pet_ativo        ON evento_pet(ativo);
CREATE INDEX idx_evento_pet_especie_alvo ON evento_pet(especie_alvo);
