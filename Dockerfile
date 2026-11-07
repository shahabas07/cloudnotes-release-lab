# --- Stage 1: install dependencies -----------------------------------------
FROM node:20-alpine AS deps
WORKDIR /app
COPY app/package.json ./
RUN npm install --omit=dev

# --- Stage 2: runtime --------------------------------------------------------
# Intended shape: copy only the installed node_modules + app source from the
# "deps" stage above, so the final image stays small.
FROM node:20-alpine AS runtime
WORKDIR /app

# Fixed: copy from the "deps" stage (the correct stage name)
COPY --from=deps /app/node_modules ./node_modules
COPY app/ ./

# Fixed: API_KEY removed - supplied at runtime via .env file
ENV PORT=8080

EXPOSE 8080
CMD ["node", "server.js"]
