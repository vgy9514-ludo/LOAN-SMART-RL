# LOAN SMART · RL — Single HTML + Supabase

## Architecture
- `index.html`: single-file frontend (HTML/CSS/JS).
- `supabase-schema.sql`: cloud database tables and Row Level Security.
- `supabase/functions/ai-chat/index.ts`: secure AI proxy. The AI behavior is unchanged: user asks -> AI bot replies.

## Supabase setup
1. Create a Supabase project.
2. Run `supabase-schema.sql` in SQL Editor.
3. Enable Email/Password Auth. Use verified email for password recovery; no OTP is required for normal login/forgot-password.
4. Create a private Storage bucket for loan documents and apply owner-only Storage policies.
5. Put only the Supabase project URL + publishable/anon key in `index.html`.
6. Never put the service-role key in browser code.
7. Deploy the Edge Function:
   `supabase functions deploy ai-chat`
8. Add AI provider secrets to Supabase:
   `supabase secrets set AI_API_URL=... AI_API_KEY=...`
   Do not expose these secrets in HTML.
9. Connect the frontend's Supabase calls to the authenticated user's rows using RLS.

## Public deployment
Host `index.html` on Vercel, Netlify, or another static host. The database/auth/storage remain in Supabase.

## Important
This package contains the complete frontend and backend integration files, but your own Supabase project credentials and AI provider secret must be configured in your accounts. Never send passwords or secret keys in chat.
