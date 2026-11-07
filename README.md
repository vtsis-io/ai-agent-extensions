# vtsis-plugins

Marketplace de plugins Claude Code do time (repo `vtsis-io/ai-agent-extensions`). Plugins
disponíveis:

- **project-starter** — padrões do time para iniciar projetos: estrutura de repositório com
  o submodule `devops`, convenção `AGENTS.md`, documentação (TRD, ADRs, PRDs, OpenSpec),
  regras invariantes e defaults de plataforma por perfil de deploy. Framework, ORM e
  estrutura interna de pastas ficam no TRD de cada projeto.
- **iac-provision** — provisiona infraestrutura AWS (Terraform + Terragrunt) seguindo os
  padrões já estabelecidos no repositório do projeto (Lambda, API Gateway, SQS, Cognito,
  EventBridge, etc.).

## Instalação

Em cada máquina:

```
/plugin marketplace add vtsis-io/ai-agent-extensions
/plugin install project-starter@vtsis-plugins
/plugin install iac-provision@vtsis-plugins
```

Depois de instalado, os skills disparam automaticamente quando o Claude Code identificar
um contexto relevante (ex: "quero iniciar um projeto novo", "cria uma lambda nova").

## Estrutura do repo

```
.claude-plugin/
  marketplace.json                # manifesto do marketplace
plugins/
  project-starter/
    .claude-plugin/
      plugin.json                 # manifesto do plugin
    skills/
      project-starter/
        SKILL.md                  # obrigatório (repo, AGENTS.md, docs, regras) + defaults + livre
        references/
          perfis-de-deploy.md     # Lambda TS, Lambda Python, SPA estática, container
  iac-provision/
    .claude-plugin/
      plugin.json
    skills/
      iac-provision/
        SKILL.md                  # provisiona AWS via Terraform/Terragrunt
        references/
          module-conventions.md
          terragrunt-template.hcl
        evals/
          evals.json
```

## Evoluindo os padrões

Mudança de padrão é PR neste repo, com a versão do plugin incrementada em `plugin.json` e no
`marketplace.json` — sem bump de versão as máquinas já instaladas não recebem a atualização.
Perfil de deploy novo só quando exige empacotamento ou pipeline diferente no `devops`;
escolhas de biblioteca ficam nos TRDs dos projetos. Depois do merge, cada máquina recebe a
atualização no próximo `/plugin marketplace update`.
