# Usar una imagen base de Node.js
FROM node:18-alpine

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar los archivos de package.json y package-lock.json
COPY package*.json ./
RUN npm ci

# Copiar el resto del código de la aplicación
COPY . .

# Construir la aplicación
RUN npm run build

# Exponer el puerto 3000
EXPOSE 3000

# Establecer variables de entorno
ENV NODE_ENV=production
ENV PORT=3000

# Comando para ejecutar la aplicación
CMD ["npm", "start"]
