<!-- claude-shared optional module: frontend -->
<!-- Generalized frontend conventions. Adapt examples to your framework. -->

# Frontend Convention

## Component Design

### Single Responsibility
- One component = one role
- Split when exceeding 200 lines
- Business logic goes in hooks/composables; components handle rendering only

```tsx
// ❌ Bad — data fetch + logic + UI mixed in one component
function ItemList() {
  const [data, setData] = useState([])
  useEffect(() => { fetch('/api/items').then(r => r.json()).then(setData) }, [])
  const filtered = data.filter(d => d.price < budget)
  return <ul>{filtered.map(...)}</ul>
}

// ✅ Good — logic extracted to a hook
function ItemList() {
  const { items, isLoading } = useItems(filters)
  if (isLoading) return <Skeleton />
  return <ul>{items.map(...)}</ul>
}
```

### Props Design
- Keep props to 5 or fewer. Group into an object or split the component if more are needed
- Boolean props: `isLoading`, `hasError` (is/has prefix)
- Event handlers: `onSubmit`, `onChange` (on prefix)
- Use children/slot patterns for flexible composition

### Composition over Configuration
- Prefer component composition over prop-driven branching

```tsx
// ❌ Bad — branching via props
<Card type="product" showPrice showBookmark />

// ✅ Good — composition
<Card>
  <Card.Header>{product.name}</Card.Header>
  <Card.Price value={product.price} />
  <Card.BookmarkButton id={product.id} />
</Card>
```

## State Management

### State Classification

| Category | Recommended Tools | Criteria |
|----------|-------------------|----------|
| Server state (API data) | TanStack Query, SWR, Apollo | Data that needs caching, revalidation, invalidation |
| Shared client state | Zustand, Pinia, Redux Toolkit | UI state shared across multiple components |
| Local state | useState, ref | State used only within a single component |
| URL state | searchParams, router query | Filters, pagination — shareable via URL |

### Rules
- Do not copy server data into a client store — the data-fetching cache is the single source of truth
- Store filters/search criteria in URL searchParams — enables link sharing and back navigation
- Minimize global state — ask "does this really need to be global?" first

## Data Fetching

### Server-First Rendering
- If your framework supports server components or SSR, fetch data on the server first
- Use client-side interactivity only where needed

### Data Fetching Library Patterns
- Design query keys hierarchically: `['items', 'list', filters]`
- Invalidate related queries after mutations
- Always handle error and loading states

```typescript
// Example: TanStack Query
// Reference data — rarely changes, long cache
useQuery({ queryKey: ['categories'], queryFn: getCategories, staleTime: 24 * 60 * 60 * 1000 })

// Search results — re-fetch on filter change, moderate cache
useQuery({ queryKey: ['items', filters], queryFn: () => searchItems(filters), staleTime: 5 * 60 * 1000 })
```

## Styling

### Utility-First CSS (e.g., Tailwind CSS)
- Avoid inline styles — use utility classes
- Extract repeated style combinations into components (not CSS abstractions)
- Responsive: mobile-first (`sm:`, `md:`, `lg:`)
- Dark mode: use framework-provided variant (e.g., `dark:`)

### Component Library Usage
- If a library component exists for your need, do not rebuild it from scratch
- When customization is needed, copy and modify rather than wrapping
- Use a class-merging utility (e.g., `cn()`, `clsx`) for conditional classes

## Performance

- Images: use framework-optimized image components (e.g., `next/image`, `nuxt-img`) for lazy loading and optimization
- Fonts: use framework font optimization to prevent FOUT/FOIT
- Bundle analysis: check bundle size impact before adding dependencies
- Memoization (`React.memo`, `useMemo`, `useCallback`, `computed`): apply only after measuring — no premature optimization

## Accessibility

- Semantic HTML first (`button`, `nav`, `main`, `section`)
- All images must have `alt` text
- Verify keyboard navigation works
- Color contrast minimum 4.5:1 (WCAG AA)
