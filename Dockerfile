# syntax=docker/dockerfile:1

# 1) Dependencias
FROM node:20-alpine AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app
COPY package.json ./
RUN npm install --ignore-scripts

# 2) Build
FROM node:20-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
# Opcional: generar salida standalone para runtime más liviano
# (añade output: 'standalone' en next.config.js)
RUN npm run build

# 3) Runtime
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3000
# Si usas output: 'standalone'
# COPY --from=builder /app/.next/standalone ./
# COPY --from=builder /app/public ./public
# COPY --from=builder /app/.next/static ./.next/static
# CMD ["node", "server.js"]

# Si NO usas 'standalone', copia artefactos necesarios:
COPY --from=builder /app/next.config.ts ./next.config.ts
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next

EXPOSE 3000

CMD ["npm", "run", "start"]
