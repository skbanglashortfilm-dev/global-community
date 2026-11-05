# Global Community

Facebook-inspired full-stack social community starter for web + Android.

## Stack
- Web: Next.js App Router + TypeScript
- Mobile: Expo + React Native
- Backend: Supabase (Postgres, Auth, Storage, Realtime)
- Shared backend contract: `packages/shared`

## Quick start

1. Create a Supabase project at https://supabase.com.
2. In Supabase SQL Editor, run `supabase/schema.sql`.
3. Copy `.env.example` to `apps/web/.env.local` and fill in your project URL and anon key.
4. Web:
   ```bash
   cd apps/web
   npm install
   npm run dev
   ```
5. Android:
   ```bash
   cd apps/mobile
   npm install
   npx expo start
   ```
   Add the same Supabase URL and anon key to `apps/mobile/src/config.ts`.

## Important setup
- Enable Email auth in Supabase. Configure email confirmation and SMTP for production.
- Create a public Storage bucket named `post-media` (or adjust policies in schema).
- For production, configure a custom domain, HTTPS, SMTP, backups, rate limits, abuse reporting workflow, and app store signing.
- Never put a Supabase service-role key in a client app. Only the anon/publishable key belongs in client configuration.
- This is a working starter, not a deployed global service. Real public launch requires your Supabase project, domain/hosting, moderation operations, and security testing.

## Included
- Email sign-up/sign-in and sign-out
- Profile records
- Feed, text posts, likes, comments
- Friend requests and follows
- Direct message data model + realtime subscription example
- Notifications table
- Groups and membership tables
- Reports and admin role field
- Row Level Security policies
- Expo mobile starter connected to the same Supabase backend
