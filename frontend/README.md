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

El frontend se comunica con el API TechModa desplegado en AWS. La URL del API se configura vía la variable de entorno `VITE_API_URL`.

Ver `src/lib/api.ts` para la implementación del cliente API.
