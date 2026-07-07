# Modelo 2 — Frontend / Fullstack

**Quando usar:** Web apps, dashboards, aplicações fullstack com SSR/SSG.

## Stack

- Framework: **Next.js** (App Router)
- Estilização: **Tailwind CSS** + **shadcn/ui**
- Estado global: **Zustand** (evitar Redux salvo complexidade justificada)
- Data fetching: **TanStack Query** para client-side; Server Components para SSR
- Formulários: **React Hook Form** + **Zod**

## Estrutura de pastas

```
src/
├── app/             # Rotas Next.js (App Router)
├── components/
│   ├── ui/          # Componentes base (shadcn — não editar diretamente)
│   └── {feature}/   # Componentes de domínio
├── lib/             # Utilitários, clients de API, helpers
├── hooks/           # Custom hooks
├── stores/          # Zustand stores
├── types/           # Tipos TypeScript globais
└── config/          # Constantes e configurações
```

## Padrões

- Server Components por padrão; `"use client"` apenas quando necessário
- Sem lógica de negócio em componentes (extrair para hooks ou lib)
- API routes do Next.js apenas para BFF; lógica pesada em serviço separado

## Infraestrutura

- Definições de infra (S3+CloudFront, ECS, Amplify) ficam no submodule `devops/`
- Ver `devops/AGENTS.md` para padrões de pipeline e deploy
