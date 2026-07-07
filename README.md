# claude-plugins

Marketplace de plugins Claude Code do time. Hoje contém um único plugin:

- **project-starter** — padrões de arquitetura de referência para iniciar projetos novos
  (estrutura de repositório, convenção `AGENTS.md`, princípios gerais e catálogo de stacks
  por tipo de projeto — "Modelo N"), com um skill complementar (`arch-system-design`) para
  propor novos Modelos quando o tipo de projeto ainda não está coberto.

## Instalação

Em cada máquina:

```
/plugin marketplace add vtsis-io/ai-agent-extensions
/plugin install project-starter@claude-plugins
```

Depois de instalado, os skills `project-starter` e `arch-system-design` disparam
automaticamente quando o Claude Code identificar um contexto relevante (ex: "quero iniciar
um projeto de API REST", "qual stack usar para um projeto CLI").

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
        SKILL.md                  # princípios gerais + estrutura devops/AGENTS.md + índice dos Modelos
        references/
          modelo-1-api-rest.md
          modelo-2-frontend-fullstack.md
      arch-system-design/
        SKILL.md                  # propõe novos Modelos N
```

## Evoluindo o catálogo

Novo tipo de projeto sem Modelo correspondente? Peça ao Claude Code para acionar o skill
`arch-system-design` — ele gera o novo `references/modelo-N-{tipo}.md` e o trecho de índice
para o `SKILL.md` do `project-starter`, prontos para virar PR neste repo. Depois do merge,
cada máquina recebe a atualização no próximo refresh do marketplace
(`/plugin marketplace update` ou automático, conforme configuração do Claude Code).
