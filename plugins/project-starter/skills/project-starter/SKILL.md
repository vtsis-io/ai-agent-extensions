---
name: project-starter
description: Padrões do time para iniciar ou estruturar um projeto — estrutura de repositório com o submodule devops, convenção AGENTS.md, documentação (TRD, ADRs, PRDs, OpenSpec), regras invariantes e defaults de plataforma por perfil de deploy (Lambda TypeScript, Lambda Python, SPA estática, container). Use ao iniciar um projeto novo, montar a estrutura de um repositório, escolher linguagem, runtime ou perfil de deploy, ou quando o escrever-trd precisar dos defaults do time. Não decide framework de UI, ORM nem estrutura interna de pastas — isso é do TRD de cada projeto.
---

# Project Starter

Padrão do time em três camadas:

1. **Obrigatório** — estrutura de repositório, documentação e regras invariantes. Vale para todo projeto.
2. **Defaults de plataforma** — linguagem, runtime, empacotamento, testes e logger por perfil de deploy.
   Padronizados porque o pipeline e a IaC do `devops` dependem deles.
3. **Livre** — o resto da stack, decidido no TRD do projeto.

Desviar de qualquer item das camadas 1 ou 2 exige um ADR no projeto. Uma vez registrado, o TRD e os
ADRs do projeto prevalecem sobre este skill para aquele projeto — este skill não reabre decisões já
registradas.

## 1. Obrigatório

### Repositório

```
{projeto}/
├── AGENTS.md              # instruções canônicas para agentes de IA
├── CLAUDE.md              # contém só a linha @AGENTS.md
├── azure-pipelines.yml    # só referencia o template em devops/pipeline/azure/{projeto}/
├── docs/
│   ├── trd.md             # stack, arquitetura, padrões técnicos do projeto
│   ├── adrs/              # NNN-titulo.md, uma decisão por arquivo
│   └── prds/              # requisitos de produto, um por feature
├── openspec/              # changes em andamento (design, tasks)
└── devops/                # submodule Git do repositório de DevOps
```

- IaC (Terraform/Terragrunt) e pipelines ficam **exclusivamente** no submodule `devops`, que tem o
  próprio `AGENTS.md`. O repo de app não duplica configuração de infra.
- Outros repositórios do mesmo produto podem entrar como submodules adicionais. Decisões que afetam
  mais de um repositório ficam como ADR no repo que as origina; os demais referenciam.

### AGENTS.md

- Um `AGENTS.md` canônico na raiz de cada repositório (app e `devops`). Markdown puro.
- `CLAUDE.md` contém apenas `@AGENTS.md` — import do Claude Code, que carrega o `CLAUDE.md`. O
  `devops/` segue o mesmo par de arquivos.
- Não criar `.cursorrules`, `.github/copilot-instructions.md` ou similares duplicando conteúdo. A
  sintaxe `@AGENTS.md` só funciona no `CLAUDE.md`.
- O `AGENTS.md` do app referencia `devops/AGENTS.md` na seção de infraestrutura.
- Conteúdo enxuto: propósito, documentos de referência, estrutura, comandos e regras. Profundidade
  fica em `docs/`; o `AGENTS.md` referencia, não duplica.

### Documentação

- `docs/trd.md` e ADRs: skill `escrever-trd` (Modo Decision para ADR).
- `docs/prds/`: skill `escrever-prd`.
- Changes de implementação: OpenSpec em `openspec/changes/`.

### Regras invariantes

- **Commits:** Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`...).
- **Release:** tag `vX.Y.Z` dispara o pipeline do `devops` (UAT → PRD com aprovação).
- **Segredos:** em runtime, só no SSM Parameter Store. `.env` apenas para dev local, com
  `.env.example` versionado. Nenhum segredo no repositório.
- **Logs:** estruturados, via Powertools Logger da linguagem. Nunca conteúdo sensível nem dado
  pessoal completo (telefone, e-mail, documento).
- **Dev local:** `docker-compose.yml` para as dependências (banco, emuladores) quando houver.
  `Dockerfile` da aplicação só no perfil container.
- **Qualidade:** lint, formatação e testes passam antes do commit e no pipeline.

## 2. Defaults de plataforma

Escolha um perfil por unidade deployável — um repo pode ter mais de um (ex.: SPA + API em Lambda).
Os perfis e seus defaults estão em `references/perfis-de-deploy.md`; leia antes de propor a stack.

Defaults comuns a todo código TypeScript: strict mode, `any` só com justificativa, pnpm (com workspaces
quando houver mais de um app), ESLint + Prettier, Vitest, nada de `console.log` em produção.

## 3. Livre — decidido no TRD do projeto

Framework de UI e de API, estado, formulários, ORM ou query builder, banco de dados, autenticação,
estrutura interna de pastas. O TRD registra a escolha e o motivo; este skill não prescreve.

## Ao iniciar um projeto

1. Identifique o(s) perfil(is) de deploy.
2. Crie a estrutura obrigatória (repo, `AGENTS.md` + `CLAUDE.md`, `docs/`, submodule `devops`).
3. Escreva o TRD com o `escrever-trd`, partindo dos defaults do perfil. Desvio dos defaults vira ADR.
4. Pipeline e IaC: no `devops`, seguindo `devops/AGENTS.md`.

## Evoluir este padrão

Mudança de padrão é PR em `vtsis-io/ai-agent-extensions` (plugin `project-starter`), nunca edição em
`~/.claude/CLAUDE.md`. Perfil novo só quando exige empacotamento ou pipeline diferente no `devops`;
escolhas de biblioteca ficam nos TRDs. Suba a versão do plugin a cada mudança.
