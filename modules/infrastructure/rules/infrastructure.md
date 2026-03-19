<!-- claude-shared optional module: infrastructure -->
<!-- Generalized infrastructure conventions. Replace platform-specific examples with your stack. -->

# Infrastructure Convention

## Deployment

### Environment Separation

| Environment | Purpose | Deployment |
|-------------|---------|------------|
| local | Development | `pnpm dev` / `npm run dev` |
| preview/staging | PR review, QA | Auto-deploy per PR (e.g., Vercel Preview, Netlify Deploy Preview, Railway PR environments) |
| production | Live service | Auto-deploy on main branch merge |

### Deployment Principles
- main branch = always deployable
- Automate deployments — no manual deploys
- Deployments must be rollback-capable (instant revert to previous version)
- Separate environment variables per environment (dev/preview/production)

### Platform Patterns (adapt to your provider)
- Use framework auto-detection when available
- Configure environment variables via the platform dashboard, not in code
- Preview deploys: auto-create per PR so reviewers can verify directly
- Custom domains: production only

## CI/CD

### Basic Pipeline

```yaml
# On PR
- install dependencies
- typecheck
- lint
- test
- preview deploy

# On main merge
- all above checks + production deploy
```

### Principles
- Block merges when CI fails (branch protection)
- CI speed target: under 5 minutes (parallelize if slow)
- Secrets go in CI platform secrets, never in code

## Monitoring

### Essential Monitoring Items

| Item | Example Tools | Priority |
|------|---------------|----------|
| Error tracking | Sentry, Bugsnag | MVP |
| Web performance (Core Web Vitals) | Platform analytics, Lighthouse CI | MVP |
| Logs | Platform logs, Datadog, Logtail | MVP |
| Uptime | UptimeRobot, Pingdom, Better Uptime | Post-MVP |
| User analytics | Plausible, PostHog, platform analytics | Post-MVP |

### Error Tracking Principles
- Production errors must trigger alerts (Slack, email, PagerDuty)
- Include context with errors (user ID, request URL, input values)
- Group repeated errors to prevent alert fatigue

## Logging

### Log Levels

| Level | Purpose |
|-------|---------|
| error | Errors impacting the service |
| warn | Potential issues (deprecated API calls, etc.) |
| info | Key business events (data collection complete, etc.) |
| debug | Development debugging (disabled in production) |

### Rules
- Never log sensitive information (passwords, tokens, PII)
- Use structured logs (JSON format) — enables search and filtering
- Use a logger instead of `console.log` in production code

## Data Backup

- Enable automated daily backups through your DB provider
- Take manual snapshots before significant data changes
- Document and test the restore procedure

## External API Rate Limit Handling

### Principles
- Always check and respect rate limits when calling external APIs
- Implement retry logic with exponential backoff on limit exceeded
- Split bulk operations into batches with delays between calls

### Patterns
```typescript
// ❌ Bad — blast all requests in parallel
await Promise.all(codes.map((code) => fetchData(code)))

// ✅ Good — sequential calls with delay
for (const code of codes) {
  await fetchData(code)
  await delay(300) // adjust to API limits
}
```

### Failure Handling
- HTTP 429 (Too Many Requests): wait and retry
- On partial failure, record progress — enable resumption from last successful point
- Log collection results (success/failure counts, elapsed time)

## Scalability Considerations (Post-MVP)

- Automated data collection: scheduled functions (cron jobs, serverless functions, CI-based schedules)
- CDN: static assets served from edge automatically by most platforms
- DB performance: index optimization, query analysis
- Rate limiting: protect public APIs via edge middleware or API gateway
