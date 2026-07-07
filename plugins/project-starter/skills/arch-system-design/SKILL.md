---
name: arch-system-design
description: Propõe um novo "Modelo N" de arquitetura de projeto (stack, estrutura de pastas, padrões) quando o tipo de projeto do usuário não está coberto pelos Modelos existentes no skill project-starter. Use quando o usuário quiser iniciar um projeto de um tipo novo (ex: CLI, mobile, worker/job assíncrono, data pipeline), pedir para "criar um Modelo N", ou perguntar por uma stack não coberta pelos references atuais.
---

# Arch System Design

Gera o próximo "Modelo N" do catálogo de arquitetura de referência (`project-starter/SKILL.md`
e `project-starter/references/`), para tipos de projeto ainda não cobertos.

## Fluxo

1. **Entender o tipo de projeto e requisitos.** Confirme com o usuário o que o Modelo precisa
   cobrir e o que já foi descartado (ex: já existe Modelo 1 para API REST e Modelo 2 para
   Frontend/Fullstack — não recrie esses). Se o tipo já for próximo de um Modelo existente,
   prefira sugerir uma extensão do Modelo existente em vez de um Modelo N novo.
2. **Propor stack, estrutura de pastas e padrões**, seguindo exatamente o mesmo formato dos
   Modelos 1 e 2 (`references/modelo-1-api-rest.md`, `references/modelo-2-frontend-fullstack.md`):
   - `## Stack` — lista das escolhas principais com uma justificativa curta por item
   - `## Estrutura de pastas` — árvore de diretórios
   - `## Padrões` — regras específicas do tipo de projeto
   - `## Infraestrutura` — referência ao submodule `devops/AGENTS.md`
3. **Gerar os artefatos prontos para PR** neste repo (`claude-plugins` / plugin `project-starter`):
   - O arquivo novo `plugins/project-starter/skills/project-starter/references/modelo-N-{tipo}.md`
     com o conteúdo do passo 2.
   - O trecho de linha a acrescentar na tabela "Catálogo de Modelos" do
     `plugins/project-starter/skills/project-starter/SKILL.md`.
   - Um resumo do diff proposto para o usuário revisar antes de abrir o PR — este skill nunca
     faz commit ou push sozinho.

## Regras

- Nunca duplique um Modelo existente; se a stack proposta é uma variação pequena de um Modelo
  já cadastrado, prefira editar o `reference` existente a criar um Modelo N.
- Numeração de `N` é sequencial em relação aos Modelos já existentes na tabela do
  `project-starter/SKILL.md` no momento da execução — releia a tabela antes de escolher o número.
- Mudanças de padrão sempre viram PR neste repo, nunca edição direta em `~/.claude/CLAUDE.md`
  ou em outro arquivo pessoal — o catálogo é compartilhado pelo time via este plugin.
