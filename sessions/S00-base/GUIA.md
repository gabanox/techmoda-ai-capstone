# S0 · Desplegar TechModa base (CRUD serverless)

**Duración:** ~60 min · **Servicio de IA:** ninguno (cimiento) · **Dominio AIF-C01:** base para todo

---

## 🎯 Objetivo

Dejar corriendo, en tu cuenta sandbox **us-west-2**, la tienda TechModa serverless **sin IA todavía**:
API Gateway REST + 5 Lambdas (CRUD) + DynamoDB + frontend React en S3/CloudFront. Este es el lienzo
sobre el que las 11 sesiones siguientes irán pegando capacidades de IA, una por hora.

Al terminar S0 vas a poder **crear, listar, ver, editar y borrar productos** desde el navegador.

---

## 🧩 Prerequisitos

- Cuenta sandbox **AWS re/Start (vocareum)** activa y el **VS Code IDE** del sandbox abierto.
- En una terminal del IDE: `aws sts get-caller-identity` debe responder (estás autenticado como `LabRole`).
- `sam --version`, `aws --version`, `node --version` (≥18), `python3 --version` (3.12) responden.

> 📍 **Todo se ejecuta dentro del VS Code IDE del sandbox.** No necesitás credenciales en tu laptop.

---

## 🧠 El concepto (qué es "serverless" y por qué importa para IA)

"Serverless" no significa "sin servidores": significa que **vos no administrás servidores**. AWS ejecuta
tu código (Lambda) solo cuando llega una petición y te cobra por milisegundo de ejecución. Para un
proyecto de IA esto es ideal porque:

- **Pagás por uso, igual que los servicios de IA.** Una Lambda que llama a Rekognition solo cuesta cuando alguien sube una foto.
- **Escala solo.** Si 1.000 clientes piden traducciones a la vez, Lambda crea 1.000 ejecuciones; no aprovisionás nada.
- **Aísla cada capacidad.** Cada feature de IA será **su propia Lambda con su propio permiso IAM** → mínimo privilegio fácil.

Esa última idea es el patrón central del capstone: **una Lambda = un servicio de IA = un permiso acotado.**

---

## 🚶 Paso a paso

### 1. Clonar y configurar
```bash
git clone <este-repo> techmoda-ai-capstone && cd techmoda-ai-capstone
cp samconfig.us-west-2.example samconfig.toml
```

### 2. Construir
```bash
sam build
```
SAM empaqueta las 5 Lambdas Node.js y valida el `template.yaml`.

### 3. Desplegar
```bash
sam deploy --guided     # solo la primera vez
```
Aceptá los defaults (stack `techmoda-ai`, región `us-west-2`, `CAPABILITY_IAM`). En despliegues
posteriores basta con `sam deploy`.

> 🔐 **Sobre IAM en el sandbox:** SAM crea un rol de ejecución por Lambda con permisos mínimos
> (las `Policies:` del `template.yaml`). El sandbox re/Start permite esta creación de roles acotados
> — es justamente el patrón que usaremos para los servicios de IA. Si tu sandbox bloqueara la
> creación de roles, mirá la nota de *LabRole fallback* en `sessions/S10-iam-logging-costos/GUIA.md`.

### 4. Anotar las salidas
Al final del deploy, CloudFormation imprime:
- `ApiUrl` → la URL base de tu API (`https://xxxx.execute-api.us-west-2.amazonaws.com/Prod`)
- `FrontendUrl` → la URL de CloudFront del catálogo
- `ProductsTableName` → la tabla DynamoDB

### 5. Cargar datos de ejemplo
```bash
bash ai/seed/seed-products.sh
```

### 6. Publicar el frontend
```bash
bash scripts/deploy-frontend.sh
```

### 7. Ver funcionar
Abrí `FrontendUrl` en el navegador → deberías ver el catálogo con los 4 productos sembrados.

---

## ✅ Checklist de validación

- [ ] `sam deploy` terminó en estado `CREATE_COMPLETE` / `UPDATE_COMPLETE`.
- [ ] `curl "$ApiUrl/products"` devuelve un JSON con `products: [...]`.
- [ ] La `FrontendUrl` carga y muestra los productos.
- [ ] Podés crear un producto desde la UI y aparece al refrescar.
- [ ] En CloudWatch Logs ves el log group `/aws/lambda/techmoda-ai-ListItems`.

```bash
# Prueba rápida desde la terminal del IDE:
curl -s "$ApiUrl/products" | python3 -m json.tool
```

---

## 📝 Qué entra en el examen (de este cimiento)

S0 no cubre un dominio de IA, pero fija el **vocabulario de arquitectura** que el examen asume:

- **Servicios administrados vs. autoadministrados.** AIF-C01 premia elegir el servicio administrado (Lambda, Rekognition, Bedrock) en vez de montar infra propia.
- **Modelo de responsabilidad compartida.** AWS opera el servicio; vos sos responsable de **datos, permisos (IAM) y configuración**. Lo veremos a fondo en S10 (D5).
- **Pago por uso / elasticidad** como ventaja de la nube para cargas de IA.

---

## 💸 Costo + 🧹 Cleanup

**Costo de S0:** prácticamente **$0** en sandbox (Lambda + DynamoDB on-demand + API Gateway entran en
volúmenes mínimos; CloudFront/S3 centavos). *Verificar contra los precios oficiales de AWS.*

**Cleanup:** no borres todavía — las sesiones siguientes construyen sobre este stack. El cleanup total
está en S11:
```bash
bash scripts/delete-all.sh   # SOLO cuando termines TODO el capstone
```
