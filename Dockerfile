# Stage 1: Strapi backend
FROM node:18-alpine AS backend-build

WORKDIR /app/backend

COPY backend/package*.json ./
RUN npm install

COPY backend/ ./
RUN npm run build
RUN npm rebuild better-sqlite3

# Stage 2: Next.js frontend
FROM node:18-alpine AS frontend-build

WORKDIR /app/frontend

COPY frontend/package*.json ./
RUN npm install

COPY frontend/ ./
RUN npm run build

# Stage 3: final image
FROM node:18-alpine

# Create directories for frontend and backend
WORKDIR /app

# Copy the built backend
COPY --from=backend-build /app/backend ./backend

# Copy the built frontend
COPY --from=frontend-build /app/frontend/.next ./frontend/.next
COPY --from=frontend-build /app/frontend/public ./frontend/public
COPY --from=frontend-build /app/frontend/package*.json ./frontend/
COPY --from=frontend-build /app/frontend/next.config.js ./frontend/

# Install only production dependencies for frontend and backend
RUN cd backend && npm install --only=production
RUN cd frontend && npm install --only=production

# Expose necessary ports
EXPOSE 1337 3000 

# Start both frontend and backend
CMD ["sh", "-c", "cd backend && npm run start & cd frontend && npm run start"]
