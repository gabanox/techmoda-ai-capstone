# Commit: Migración de región `us-west-2` → `us-east-1`

**SHA**: `23fe2f5` · **Rama**: `feat/migrate-region-us-east-1` · **Estado**: Commiteado local (sin push)

---

## 1. Resumen (51 archivos, +153 −150)

Migra la región de trabajo del capstone dentro del mismo sandbox re/Start (cuenta `879652687082`):
149 ocurrencias de `us-west-2` en 50 archivos, más el rename de `samconfig.us-west-2.example`.
`LabRoleArn` no cambia — IAM es global y el ARN no lleva región.

**Commits de este pase**:

| SHA | Commit |
|---|---|
| `534698c` | `docs(epcc): agregar CLAUDE.md y artefactos del flujo EPCC` |
| `23fe2f5` | `refactor(region): migrar us-west-2 → us-east-1 en todo el repo` |

**Distribución del cambio**: scripts ejecutables (6 defaults `AWS_REGION`), `samconfig` (rename + 8
refs), frontend (placeholder, `.env.example`, fixture + assert), 3 templates SAM (solo comentarios),
`docs/` (~45), 11 `GUIA.md` + `sessions/README.md`, `instructor/` (11), `ai/seed/`.

---

## 2. Validación

Corrida completa **sin credenciales AWS** (fases 2 y 3 del plan, que no tocan AWS):

| Gate | Baseline (HEAD) | Post-migración | Veredicto |
|---|---|---|---|
| `vitest run` | 36 fail / 81 pass (117) | 36 fail / 81 pass (117) | ✅ cero regresiones |
| `npm run typecheck` | 17 errores | 17 errores | ✅ cero regresiones |
| `sam validate --lint` ×3 | — | OK / OK / OK | ✅ |
| `bash -n` (15 scripts) | — | sintaxis válida | ✅ |
| `us-west-2` residual | 167 | 0 fuera de `EPCC_PLAN.md` | ✅ |
| `Oregón` residual | 2 | 0 fuera de `EPCC_PLAN.md` | ✅ |
| Secretos en el diff | — | 0 | ✅ |

**El baseline se midió, no se asumió**: `git stash push` de los 3 archivos de frontend que la
migración toca → correr tests → `git stash pop`. Resultado idéntico, lo que prueba que los 36 fallos
y los 17 errores de tipo son **preexistentes**, no introducidos aquí. Su causa raíz es el contrato
roto snake_case ↔ camelCase documentado en `EPCC_EXPLORE.md` §5, más warnings de `act()` y `global`
sin tipos de Node.

⚠️ **Se commitea con tests en rojo, a conciencia.** El criterio aplicado no es "los tests pasan" sino
"la migración no empeora nada", verificado contra baseline. Arreglar los 36 fallos es trabajo
separado y de mayor alcance (implica decidir de qué lado se corrige el contrato).

---

## 3. Cambios de criterio (no sustitución mecánica)

Cuatro casos donde un `sed` ciego habría producido texto falso o absurdo:

- **`Oregón` → `Norte de Virginia`** (`README.md:123`, `samconfig.*.example:6`). Oregón es us-west-2;
  un sed dejaba `us-east-1 (Oregón)`. En el `samconfig` además se quitó "fija": la migración misma
  demuestra que la región es una elección del proyecto, no un candado del sandbox.
- **`docs/prompts/03_DEPLOYMENT.md`** — nota de mapeo *"donde veas X, interpretá Y"* que tenía
  `us-east-1` de un lado y `us-west-2` del otro. Post-migración se volvía "donde veas us-east-1,
  interpretá us-east-1". Se **quitó el término de ambas listas** en vez de sustituirlo.
- **`sessions/README.md`** — el contraste sandbox vs. cuenta Bootcamp colapsaba. Reformulado para que
  siga siendo cierto: Pista B no corre en el sandbox porque el `LabRole` deniega
  `bedrock:InvokeModel` y `translate:TranslateText` **por acción, no por región**.
- **Notas de la alarma de billing** (`template.sandbox.yaml`, `template.full.yaml`, `S10/GUIA.md`) —
  decían "va en us-east-1, creala aparte", contradictorio ahora que el stack vive ahí. Reformuladas.
  **No se agregó ningún recurso de alarma**: quedó fuera de alcance por decisión explícita.

**Preservado a propósito**: las URLs públicas `public-data-669070217575.s3.us-east-1.amazonaws.com`
(bucket real ajeno al proyecto) y el fallback `us-east-1` de `fix-failed-delete.sh:123`.

---

## 4. Cierre

**PR**: no creado. Commits locales, sin push.

**Reversión**: el rename es un commit atómico → `git revert 23fe2f5` lo deshace entero. Caveat
honesto: `CLAUDE.md` y `EPCC_EXPLORE.md` viajaron en `534698c` ya con `us-east-1` escrito, así que un
revert de `23fe2f5` los dejaría inconsistentes con el resto. Son dos menciones; ajuste trivial.

**Siguiente acción — deuda diferida (`EPCC_PLAN.md` fases 0, 1 y 4, ~2.5 h), requiere credenciales**:

1. 🚦 **Gate**: validar que el sandbox permita `us-east-1` (`aws dynamodb list-tables`,
   `lambda list-functions`, `s3 ls`, `cloudformation list-stacks`, todos `--region us-east-1`). Si un
   SCP fija la región → `git revert 23fe2f5`.
2. Borrar el stack en `us-west-2` hasta `DELETE_COMPLETE` — los buckets `${StackName}-frontend` y
   `-audio` son de **nombre global** y colisionan. Luego `rm -rf .aws-sam`.
3. `bootstrap.sh` → verificar Pista A end-to-end → `deploy-frontend.sh`.
4. Rehabilitar **Model access de Bedrock en `us-east-1`** (es un setting por región) si se van a
   demostrar S06–S09.

**Deuda preexistente registrada, ortogonal a este cambio**: el contrato snake_case ↔ camelCase
(`EPCC_EXPLORE.md` §5) y el model ID de Bedrock vencido (`claude-3-haiku-20240307`, retiro
2026-04-19).
