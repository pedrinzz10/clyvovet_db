-- ============================================================
-- CLYVO VET -- BANCO DE DADOS ORACLE
-- Arquivo 00: Script mestre de execucao
-- Execute este arquivo no SQL Developer para rodar tudo em ordem
-- ============================================================

-- PASSO 1: Habilitar saida do DBMS_OUTPUT
SET SERVEROUTPUT ON SIZE UNLIMITED;

-- PASSO 2: Tabelas e sequences
@@01_DDL_TABLES.sql

-- PASSO 3: Indices
@@02_DDL_INDEXES.sql

-- PASSO 4: Views
@@03_VIEWS.sql

-- PASSO 5: Procedures
@@04_PROCEDURES.sql

-- PASSO 6: Seed data
@@05_SEED_DATA.sql

-- PASSO 7: Blocos anonimos e relatorios
@@06_BLOCOS_ANONIMOS.sql

PROMPT ============================================
PROMPT CLYVO VET -- Banco criado com sucesso!
PROMPT ============================================
