# Modelo 1 — API REST / Backend

**Quando usar:** APIs REST, serviços backend, microserviços.

## Stack

- Framework: **Fastify** (preferir sobre Express por performance e tipagem nativa)
- ORM: **Prisma** (PostgreSQL como banco padrão)
- Validação: **Zod** (schemas compartilhados entre frontend e backend quando possível)
- Autenticação: JWT com refresh token ou AWS Cognito
- Documentação: OpenAPI via `@fastify/swagger`

## Estrutura de pastas

```
src/
├── config/          # Variáveis de ambiente e configurações centralizadas
├── modules/         # Domínios da aplicação (cada módulo = rota + serviço + schema)
│   └── {feature}/
│       ├── {feature}.routes.ts
│       ├── {feature}.service.ts
│       ├── {feature}.schema.ts
│       └── {feature}.test.ts
├── plugins/         # Plugins Fastify (auth, db, cors, etc.)
├── lib/             # Utilitários compartilhados (logger, errors, helpers)
└── server.ts        # Entry point
```

## Padrões

- Separar lógica de negócio do handler (handler chama serviço, serviço chama repositório)
- Erros tipados com classes de erro customizadas (nunca lançar strings)
- Health check em `/health` sempre presente

## Infraestrutura

- Definições de infra (Lambda, ECS, Kubernetes) ficam no submodule `devops/`
- Targets disponíveis: AWS Lambda, ECS, Kubernetes (k3s/k8s) — ver `devops/AGENTS.md`
