# Changelog

## 0.3.0

- `project-starter` 0.2.0: skill reescrito em três camadas — obrigatório (estrutura de repo,
  `AGENTS.md`, `docs/{trd,adrs,prds}` + OpenSpec, regras invariantes), defaults de plataforma
  por perfil de deploy (`references/perfis-de-deploy.md`) e livre (decidido no TRD do projeto).
  Desvio das duas primeiras camadas exige ADR; TRD e ADRs do projeto prevalecem depois de
  registrados.
- Removidos os catálogos Modelo 1 (API REST) e Modelo 2 (Frontend/Fullstack) e o skill
  `arch-system-design`: stack completa por tipo de projeto conflitava com os TRDs.
- Corrigido: pointer `@AGENTS.md` só vale no `CLAUDE.md`; segredos de runtime no SSM (`.env`
  só local); `Dockerfile` só no perfil container; logger padrão Powertools.

## 0.2.0

- Novo plugin `iac-provision`: migração do skill local `~/.claude/skills/iac-provision`
  (provisionamento de infraestrutura AWS via Terraform/Terragrunt), com references
  (`module-conventions.md`, `terragrunt-template.hcl`) e evals.

## 0.1.0

- Repo inicial do marketplace `vtsis-plugins`.
- Plugin `project-starter`: migração dos padrões de arquitetura do `~/.claude/CLAUDE.md`
  pessoal (estrutura de repo/submodule `devops`, convenção `AGENTS.md`, princípios gerais,
  Modelo 1 — API REST/Backend, Modelo 2 — Frontend/Fullstack).
- Skill `arch-system-design` reescrito no formato padrão, substituindo a versão legada com
  frontmatter de subagente quebrado.
