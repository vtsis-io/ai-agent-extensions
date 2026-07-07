---
name: project-starter
description: Padrões de arquitetura de referência para iniciar um projeto novo — estrutura de repositório, convenção AGENTS.md e catálogo de stacks por tipo de projeto (Modelo 1 — API REST/Backend, Modelo 2 — Frontend/Fullstack). Use quando o usuário for iniciar um projeto novo, perguntar "qual stack usar para X", pedir a estrutura de pastas padrão, ou mencionar o submodule devops.
---

# Project Starter

Padrões arquiteturais de referência do time. Ao iniciar qualquer projeto, identifique o
modelo aplicável na tabela de Modelos abaixo e leia o `references/*` correspondente antes
de propor stack ou estrutura de pastas. Se nenhum modelo existente cobrir o tipo de projeto,
use o skill `arch-system-design` para propor um novo Modelo N.

## Estrutura padrão de repositório

Todo projeto segue esta convenção de repositórios:

```
{project}/          # Repositório principal da aplicação
└── devops/         # Submodule Git — repositório centralizado de DevOps
```

- O submodule `devops` é adicionado em **todo projeto** como `git submodule add <devops-repo> devops`
- Definições de IaC (Terraform/Terragrunt) e pipelines CI/CD ficam **exclusivamente** no repo `devops`
- O repo de app **aponta para templates de pipeline** dentro de `devops/` — não duplica configurações de infra
- O repo `devops` possui seu próprio `AGENTS.md` com padrões de IaC e pipelines

## Documentação como Fonte da Verdade — AGENTS.md

`AGENTS.md` é o arquivo canônico de instruções para agentes de IA em **todo repositório**
(app principal e o submodule `devops`, cada um com o seu). É um padrão aberto (formalizado
em 2025, doado à Agentic AI Foundation da Linux Foundation) lido nativamente por múltiplas
ferramentas — Claude Code, Cursor, Codex, Copilot, etc. — ao contrário de `CLAUDE.md`, que
só o Claude Code lê.

- **Um único arquivo canônico por repo:** `AGENTS.md` na raiz. Markdown puro, sem
  frontmatter obrigatório.
- **Arquivos específicos de ferramenta viram pointer:** `CLAUDE.md` (e qualquer outro que
  surgir, como `.cursorrules` ou `.github/copilot-instructions.md`) contém apenas uma linha:
  ```
  @AGENTS.md
  ```
  Nunca duplicar conteúdo entre `AGENTS.md` e esses pointers — toda mudança de convenção é
  feita uma vez, no `AGENTS.md`.
- **Referência cruzada app ↔ devops:** como `devops/` é um submodule (fisicamente um
  subdiretório do app no disco), ferramentas compatíveis já resolvem `devops/AGENTS.md`
  automaticamente ao editar arquivos dentro dele (mesma lógica de "arquivo mais próximo
  vence" usada em monorepos). Ainda assim, o `AGENTS.md` do app principal mantém uma
  referência explícita a `devops/AGENTS.md` na seção de infraestrutura — cobre ferramentas
  que só leem o arquivo raiz uma vez, sem re-scan por diretório.
- Documentação de profundidade (arquitetura detalhada, padrões de API, etc.) continua em
  arquivos próprios (ex: `docs/architecture.md`) — `AGENTS.md` referencia, não duplica.

## Princípios Gerais (sempre aplicar)

- **Linguagem padrão:** TypeScript (strict mode ativado)
- **Runtime:** Node.js LTS
- **Gerenciador de pacotes:** npm ou pnpm (preferir pnpm em monorepos)
- **Formatação:** Prettier + ESLint (nunca commitar código sem passar)
- **Testes:** Vitest para unitários; separar testes de integração em pasta dedicada
- **Variáveis de ambiente:** sempre via `.env` com `.env.example` versionado; nunca hardcodar secrets
- **Commits:** Conventional Commits (`feat:`, `fix:`, `chore:`, etc.)
- **Containerização:** todo projeto deve ter `Dockerfile` e `docker-compose.yml` para dev local
- **Nunca usar:** `any` em TypeScript sem justificativa explícita; `console.log` em produção (usar logger estruturado)

## Catálogo de Modelos

| Modelo | Quando usar | Referência |
|---|---|---|
| Modelo 1 — API REST / Backend | APIs REST, serviços backend, microserviços | `references/modelo-1-api-rest.md` |
| Modelo 2 — Frontend / Fullstack | Web apps, dashboards, aplicações fullstack com SSR/SSG | `references/modelo-2-frontend-fullstack.md` |

Cada `reference` só deve ser lido quando o tipo de projeto em questão bate com aquele modelo —
não carregue todos os modelos de uma vez.

## Quando nenhum Modelo existente cobre o projeto

Use o skill `arch-system-design` deste mesmo plugin para levantar a stack, gerar o novo
arquivo `references/modelo-N-{tipo}.md` e o trecho de índice a acrescentar na tabela acima,
prontos para virar PR neste repo.
