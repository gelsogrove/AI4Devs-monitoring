# Usar una imagen base de Node.js
FROM node:18-alpine

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar los archivos de package.json y package-lock.json
COPY package*.json ./
RUN npm ci

# Copiar el esquema de Prisma
COPY prisma ./prisma/

# Generar el cliente de Prisma
RUN npx prisma generate

# Copiar el resto del código de la aplicación
COPY . .

# Construir la aplicación
RUN npm run build

# Exponer el puerto 8080
EXPOSE 8080

# Establecer variables de entorno
ENV NODE_ENV=production
ENV PORT=8080

# Ejecutar migraciones y iniciar la aplicación
CMD npx prisma migrate deploy && npm start
