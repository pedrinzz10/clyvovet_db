-- ============================================================
-- CLYVO VET -- BANCO DE DADOS ORACLE
-- Arquivo 02: DDL -- Indices otimizados
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

-- evento_clinico (queries mais frequentes: por animal, por vet+data, por clinica)
CREATE INDEX idx_evento_animal   ON evento_clinico(animal_id);
CREATE INDEX idx_evento_vet      ON evento_clinico(veterinario_id);
CREATE INDEX idx_evento_clinica  ON evento_clinico(clinica_id);
CREATE INDEX idx_evento_data     ON evento_clinico(data);
CREATE INDEX idx_evento_tipo     ON evento_clinico(tipo_evento);
CREATE INDEX idx_evento_vet_data ON evento_clinico(veterinario_id, data);

-- pagamento
CREATE INDEX idx_pagamento_evento ON pagamento(evento_clinico_id);
CREATE INDEX idx_pagamento_status ON pagamento(status_pagamento);
CREATE INDEX idx_pagamento_forma  ON pagamento(forma_pagamento);
CREATE INDEX idx_pagamento_data   ON pagamento(data_pagamento);
