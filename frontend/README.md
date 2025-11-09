# TechModa Frontend

Frontend React + TypeScript + Vite para el catálogo de productos TechModa.

## Desarrollo Local

1. Configurar URL del API en `.env`:
```bash
cp .env.example .env
```

Editar `.env` y agregar tu URL del API:
```
VITE_API_URL=https://your-api-id.execute-api.us-east-1.amazonaws.com/Prod
```

2. Instalar dependencias:
```bash
npm install
```

3. Ejecutar servidor de desarrollo:
```bash
npm run dev
```

4. Abrir tu navegador en http://localhost:5173

## Build para Producción

```bash
npm run build
```

Los archivos construidos estarán en el directorio `dist/`.

## Despliegue

El frontend se despliega en S3 + CloudFront usando el template SAM.

Usar los scripts del directorio padre:
```bash
cd ..
./scripts/build-frontend.sh
./scripts/deploy-frontend.sh
```

## Estructura del Proyecto

```
frontend/
├── src/
│   ├── components/       # Componentes React
│   ├── hooks/           # Hooks personalizados de React
│   ├── lib/             # Librerías de utilidad
│   │   ├── api.ts       # Cliente API
│   │   └── types.ts     # Tipos TypeScript
│   ├── App.tsx          # Componente principal de la aplicación
│   └── main.tsx         # Punto de entrada de la aplicación
├── public/              # Recursos estáticos
├── index.html           # Template HTML
└── vite.config.ts       # Configuración de Vite
```

## Scripts Disponibles

- `npm run dev` - Iniciar servidor de desarrollo
- `npm run build` - Construir para producción
- `npm run preview` - Previsualizar build de producción localmente
- `npm run lint` - Ejecutar ESLint
- `npm run typecheck` - Ejecutar verificación de tipos TypeScript

## Tecnologías Utilizadas

- **React 18** - Librería UI
- **TypeScript** - Seguridad de tipos
- **Vite** - Herramienta de build y servidor de desarrollo
- **Tailwind CSS** - Estilos
- **Lucide React** - Iconos

## Integración con API

El frontend se comunica con el API TechModa desplegado en AWS. La configuración de la URL del API soporta dos métodos:

### 🔧 Runtime Configuration (Producción - Recomendado)

En producción, la URL del API se inyecta en **tiempo de despliegue** sin necesidad de reconstruir el bundle. Esto permite:
- ✅ Desplegar una sola vez y cambiar la URL según el entorno
- ✅ Evitar rebuilds innecesarios
- ✅ Mayor flexibilidad en CI/CD

**Cómo funciona:**
1. El archivo `public/env-config.js.template` contiene un token `%%VITE_API_URL%%`
2. Durante el despliegue, `scripts/inject-env.sh` reemplaza el token con la URL real
3. El archivo `env-config.js` se genera en `dist/` con la configuración real
4. `index.html` carga `env-config.js` antes del bundle principal
5. `src/lib/api.ts` lee `window.__ENV.VITE_API_URL` (prioridad sobre build-time)

**Prioridad de configuración:**
```
window.__ENV.VITE_API_URL (runtime) > import.meta.env.VITE_API_URL (build-time) > fallback
```

**Verificar en el navegador:**
```javascript
// Abrir DevTools > Console
console.log(window.__ENV);
// Debería mostrar: { VITE_API_URL: "https://..." }
```

### 📦 Build-time Configuration (Desarrollo)

En desarrollo local, usa el archivo `.env`:

```bash
cp .env.example .env
# Editar .env con tu URL de API
```

El servidor de desarrollo de Vite leerá esta variable automáticamente.

### 🔍 Debugging

Si ves errores de red como `net::ERR_NAME_NOT_RESOLVED`:

1. Verifica que `window.__ENV.VITE_API_URL` esté definido (DevTools > Console)
2. Revisa que el archivo `env-config.js` exista en el sitio desplegado
3. Limpia el cache del navegador o invalida CloudFront
4. Verifica que el script `inject-env.sh` se ejecutó correctamente durante el despliegue

Ver `src/lib/api.ts` para la implementación del cliente API.

## Archivos de Configuración

- `public/env-config.js` - Versión de desarrollo (incluido en git)
- `public/env-config.js.template` - Template para producción
- `dist/env-config.js` - Generado durante despliegue (NO en git)
- `.env` - Variables de entorno locales (NO en git)
- `.env.example` - Ejemplo de configuración
