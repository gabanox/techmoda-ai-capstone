# TechModa Frontend

React + TypeScript + Vite frontend for the TechModa product catalog.

## Local Development

1. Set API URL in `.env`:
```bash
cp .env.example .env
```

Edit `.env` and add your API URL:
```
VITE_API_URL=https://your-api-id.execute-api.us-east-1.amazonaws.com/Prod
```

2. Install dependencies:
```bash
npm install
```

3. Run development server:
```bash
npm run dev
```

4. Open your browser to http://localhost:5173

## Build for Production

```bash
npm run build
```

The built files will be in the `dist/` directory.

## Deployment

The frontend is deployed to S3 + CloudFront using the SAM template.

Use the parent directory scripts:
```bash
cd ..
./scripts/build-frontend.sh
./scripts/deploy-frontend.sh
```

## Project Structure

```
frontend/
├── src/
│   ├── components/       # React components
│   ├── hooks/           # Custom React hooks
│   ├── lib/             # Utility libraries
│   │   ├── api.ts       # API client
│   │   └── types.ts     # TypeScript types
│   ├── App.tsx          # Main application component
│   └── main.tsx         # Application entry point
├── public/              # Static assets
├── index.html           # HTML template
└── vite.config.ts       # Vite configuration
```

## Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build locally
- `npm run lint` - Run ESLint
- `npm run typecheck` - Run TypeScript type checking

## Technologies Used

- **React 18** - UI library
- **TypeScript** - Type safety
- **Vite** - Build tool and dev server
- **Tailwind CSS** - Styling
- **Lucide React** - Icons

## API Integration

The frontend communicates with the TechModa API deployed on AWS. The API URL is configured via the `VITE_API_URL` environment variable.

See `src/lib/api.ts` for the API client implementation.
