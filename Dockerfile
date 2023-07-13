FROM node:18-alpine as base
ENV NEXT_TELEMETRY_DISABLED 1

FROM base as deps
RUN apk add --no-cache libc6-compat
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn --frozen-lockfile

FROM deps as builder
ENV NEXT_PRIVATE_STANDALONE=true
WORKDIR /app
COPY . .
RUN yarn build

FROM base as runner
WORKDIR /app
ENV NODE_ENV=production

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
# https://github.com/vercel/next.js/issues/48077#issuecomment-1504501461
COPY --from=builder /app/node_modules/next/dist/compiled/jest-worker ./node_modules/next/dist/compiled/jest-worker

USER nextjs
EXPOSE 3000
ENV PORT 3000

CMD ["node", "server.js"]
