# Perfis de deploy

Defaults de plataforma por perfil. Cobrem só o que o `devops` precisa saber para construir, empacotar e
publicar; frameworks e bibliotecas ficam no TRD do projeto. Infra e pipeline de todos os perfis ficam no
submodule `devops/`.

## Lambda TypeScript

**Quando:** API HTTP ou job serverless (API Gateway HTTP API, SQS, EventBridge Scheduler).

- Runtime: Node.js na versão LTS suportada pela Lambda (`nodejs24.x`), arm64
- Artefato: zip com bundle esbuild
- Testes e lint: Vitest; ESLint + Prettier
- Logger: Powertools for AWS Lambda (TypeScript)
- Referências: `backoffice-clients`, `backoffice-gerencial` (API)

## Lambda Python

**Quando:** só com ADR justificando a exceção ao TypeScript (ex.: SDK ou ecossistema disponível apenas
em Python).

- Runtime: versão de Python mais recente suportada pela Lambda, arm64
- Dependências e ambiente: `uv`
- Artefato: zip
- Testes e lint: pytest; Ruff (lint e formatação)
- Logger: Powertools for AWS Lambda (Python)
- Referência: `agents-whatsapp` (ADR 010)

## SPA estática

**Quando:** front-end servido como arquivos estáticos, sem renderização no servidor.

- Build: Vite; TypeScript strict
- Artefato: diretório estático publicado em S3 + CloudFront (sync + invalidação)
- Testes: Vitest; Playwright para ponta a ponta
- Referências: `backoffice-clients`, `backoffice-gerencial` (front)

Precisa de SSR? Não use este perfil — S3 + CloudFront não executa código de servidor. Use o perfil
container ou registre um perfil novo.

## Container

**Quando:** processo de longa duração, SSR, ou carga que não cabe nos limites da Lambda.

- Artefato: imagem a partir de `Dockerfile` multi-stage, publicada no ECR
- Destinos: ECS ou Kubernetes, conforme `devops/AGENTS.md`
- Linguagem, testes e logger: os defaults TypeScript do `SKILL.md`
- Referência: nenhum projeto ainda — o primeiro a usar este perfil deve revisar esta seção
