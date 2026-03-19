<!-- claude-shared optional module: security -->
<!-- Generalized security conventions. Replace provider-specific examples with your stack. -->

# Security Convention

## Authentication

### Principles
- Never implement auth logic from scratch — use proven services (NextAuth, Clerk, Auth0, Firebase Auth, Supabase Auth, etc.)
- Store tokens in httpOnly cookies (not localStorage/sessionStorage)
- Auto-refresh sessions on expiry, or redirect to re-login

```typescript
// ❌ Bad — managing tokens directly in the client
localStorage.setItem('token', session.access_token)

// ✅ Good — let your auth provider handle cookie-based sessions
const user = await authProvider.getUser()
```

## Authorization

### Row-Level / Resource-Level Access Control
- Enable row-level security or equivalent for all user-data tables
- Default deny — no access without an explicit policy
- Enforce authorization on the server; never rely on client-side checks alone

```sql
-- Example: PostgreSQL RLS policy
-- Users can only access their own records
CREATE POLICY "Users can manage own records"
  ON user_records FOR ALL
  USING (auth.uid() = user_id);
```

### API Protection
- Authenticated APIs: validate session in middleware
- Admin APIs: role-based access control
- Public APIs: apply rate limiting

## Input Security

### XSS Prevention
- Never insert user input directly into HTML
- Use your framework's built-in escaping (React JSX, Vue templates, etc.)
- Avoid raw HTML injection (`dangerouslySetInnerHTML`, `v-html`) — sanitize if unavoidable

### SQL Injection Prevention
- Use parameterized queries only
- Never build SQL via string concatenation

```typescript
// ❌ Bad — string interpolation in SQL
const result = await sql`SELECT * FROM items WHERE name = '${userInput}'`

// ✅ Good — parameterized query / ORM
const result = await db.from('items').select().where('name', userInput)
```

### Input Validation
- Validate at API boundaries with a schema library (zod, yup, joi, etc.)
- Enforce numeric ranges, string length limits
- Use allowlists over denylists

## Secret Management

### Rules
- Never hardcode secrets in source code
- Store in `.env.local`, confirm `.gitignore` includes it
- `.env.example` contains key names only (no values)
- CI/CD secrets: use platform environment variable features

```
# .env.example
DATABASE_URL=
AUTH_SECRET=
API_KEY=
```

### Client-Exposed Variables
- Framework-specific public prefixes (`NEXT_PUBLIC_`, `VITE_`, `NUXT_PUBLIC_`) are exposed to the browser
- Never use public prefixes for DB passwords, service keys, or API secrets
- Only truly public values (e.g., public API URL, public analytics ID) may use public prefixes

## Dependency Security

- Run `npm audit` / `pnpm audit` regularly
- Update packages with known vulnerabilities immediately
- Remove unused dependencies — minimize attack surface
- Always commit lockfiles (prevents supply chain attacks)

## HTTPS

- HTTPS is mandatory in production
- Use HTTPS in development when possible (OAuth callbacks often require it)
- No mixed content (loading HTTP resources from HTTPS pages)

## OWASP Top 10 Checklist

| Threat | Mitigation |
|--------|------------|
| Injection | Parameterized queries, ORM usage |
| Broken Auth | Proven auth libraries, httpOnly cookies |
| Sensitive Data Exposure | HTTPS, secrets in env vars, access control |
| XSS | Framework escaping, CSP headers |
| Broken Access Control | Row-level security, server-side authorization |
| Security Misconfiguration | Change default passwords, remove unnecessary endpoints |
| CSRF | SameSite cookies, CSRF tokens (when needed) |
