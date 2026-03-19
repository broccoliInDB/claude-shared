<!-- claude-shared optional module: backend -->
<!-- Generalized backend conventions. Replace provider-specific examples with your stack. -->

# Backend Convention

## API Design

### RESTful Principles
- Resource-oriented URLs: `/api/users`, `/api/bookmarks`
- Express actions through HTTP methods: GET (read), POST (create), PUT (full update), PATCH (partial update), DELETE (remove)
- No verbs in URLs

```
// ❌ Bad
GET  /api/getUsers
POST /api/createBookmark

// ✅ Good
GET    /api/users?role=admin&status=active
POST   /api/bookmarks
DELETE /api/bookmarks/:id
```

### Consistent Response Format

```typescript
// Success
{ data: T, meta?: { total: number, page: number } }

// Error
{ error: { code: string, message: string } }
```

- Use HTTP status codes accurately: 200 (OK), 201 (Created), 400 (Bad Request), 401 (Unauthorized), 403 (Forbidden), 404 (Not Found), 500 (Internal Server Error)
- Include a human-readable message in error responses

### Route Handler Pattern

```typescript
// ❌ Bad — no error handling
export async function GET(request: Request) {
  const data = await fetchData()
  return Response.json(data)
}

// ✅ Good — error handling + type safety
export async function GET(request: Request): Promise<Response> {
  try {
    const { searchParams } = new URL(request.url)
    const filters = parseFilters(searchParams)
    const data = await getItems(filters)
    return Response.json({ data })
  } catch (error) {
    return Response.json(
      { error: { code: 'FETCH_FAILED', message: 'Failed to fetch items' } },
      { status: 500 }
    )
  }
}
```

## Database

### Schema Design
- Table/column names: snake_case (`user_id`, `created_date`)
- Boolean columns: `is_` prefix (`is_active`, `is_deleted`)
- Date columns: `_at` suffix (`created_at`, `updated_at`)
- Every table must have `id` and `created_at`
- Soft delete: use `deleted_at` (nullable timestamp) when needed

### Query Principles
- Use ORM/Query Builder (minimize raw SQL)
- No N+1 queries — use joins or batch fetching
- Index columns used in filters and sorting
- Pagination: cursor-based recommended (offset degrades on large datasets)

### DB Provider Patterns
- Enable row-level access control if your DB supports it (e.g., RLS in PostgreSQL/Supabase, policies in Firebase)
- Push complex queries to the server side (stored procedures, DB functions)
- Enable realtime/subscriptions only on tables that need it

## CORS

### Principles
- Same-origin API calls: no CORS configuration needed
- Cross-origin calls: explicitly allow specific origins in middleware

```typescript
// Middleware example — apply only when needed
function corsMiddleware(request: Request, response: Response): Response {
  const origin = request.headers.get('origin')
  if (origin && ALLOWED_ORIGINS.includes(origin)) {
    response.headers.set('Access-Control-Allow-Origin', origin)
    response.headers.set('Access-Control-Allow-Methods', 'GET, POST, DELETE')
    response.headers.set('Access-Control-Allow-Headers', 'Content-Type, Authorization')
  }
  return response
}
```

- No wildcard `*` in production — list allowed domains explicitly
- Requests with credentials require an explicit origin
- Start without CORS (same-origin); add when external integrations are needed

## Caching

### Caching Strategy
- **Rarely changing data** (reference tables, categories): long-term cache
- **Periodically updated data** (prices, listings): invalidate on update cycle
- **Per-user data** (bookmarks, preferences): do not cache (or cache per user)

### HTTP Caching Pattern
```typescript
// Static data — cache for 1 day
return Response.json({ data }, {
  headers: { 'Cache-Control': 'public, s-maxage=86400, stale-while-revalidate=3600' }
})

// Dynamic data — no caching
// Use framework-specific opt-out (e.g., `export const dynamic = 'force-dynamic'`)
```

### Client-Side Caching
- Use your data-fetching library's cache as the source of truth
- Set `staleTime` to prevent unnecessary re-fetches

## Database Migration

### Migration Management
- All schema changes must be tracked via migration files
- Do not execute ad-hoc SQL directly in production dashboards
- Migration files must be version-controlled in git

### Principles
- Migrations are forward-only — fix mistakes with new migrations, not rollbacks
- Column/table removal requires caution (make nullable first, remove in a subsequent deploy)
- Seed data (reference tables, etc.) should also be managed via migrations

## Validation

### Validate at the Boundary
- API input: validate with a schema library (zod, yup, joi, etc.)
- Environment variables: validate at app startup
- Internal function calls: TypeScript types are sufficient (no redundant validation)

```typescript
// API input validation example
const SearchFilters = z.object({
  minPrice: z.number().optional(),
  maxPrice: z.number().optional(),
  category: z.string().optional(),
  page: z.number().int().positive().optional(),
})
```

## Error Handling

### Layered Approach
- **API boundary**: catch errors and return appropriate HTTP responses
- **Business logic**: use custom error classes to express intent
- **Expected errors**: handle explicitly (API failures, auth expiry)
- **Unexpected errors**: log and return a generic error response

```typescript
// ❌ Bad — all errors treated the same
catch (e) { return Response.json({ error: 'Error' }, { status: 500 }) }

// ✅ Good — differentiate by error type
catch (error) {
  if (error instanceof AuthError) {
    return Response.json(
      { error: { code: 'UNAUTHORIZED', message: error.message } },
      { status: 401 }
    )
  }
  console.error('Unexpected error:', error)
  return Response.json(
    { error: { code: 'INTERNAL', message: 'Internal server error' } },
    { status: 500 }
  )
}
```

## Environment Variables

- Store in `.env.local`, maintain a key list in `.env.example`
- Server-only variables: `DB_URL`, `API_KEY`, `SECRET_KEY`
- Client-exposed variables: use your framework's prefix convention (e.g., `NEXT_PUBLIC_`, `VITE_`, `NUXT_PUBLIC_`)
- Never expose secrets via client-prefixed variables
