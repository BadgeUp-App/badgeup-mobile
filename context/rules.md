# Rules

## Git
- Never push directly — always through PR or explicit request
- Commits: title only, no description, no body
- Format: `tipo(scope): mensaje corto`
- After the colon: shortest possible message in spanish

## Code
- Comments: almost none, only when truly necessary
- Less words = better
- Simple > everything
- No emojis, no decorations
- Spanish for all user-facing strings (accents optional in code)
- All buttons must do something — if not implemented, show AlertDialog

## Tech
- Flutter targeting iOS (iPhone primary)
- Backend: Django + DRF + PostgreSQL (Docker)
- Auth: JWT (SimpleJWT) + Google OAuth
- State: Provider + ChangeNotifier
- Font: Poppins/Inter via google_fonts
- Design: pastel theme, border-radius 14-20px, subtle shadows

## Process — New US
1. Create file in `context/epics/` named `US-XXX.md`
2. Follow `context/epics/_TEMPLATE.md`
3. Keep it short

## Process — MR Feedback
1. Create file in `context/mrs/` named `MR-XXX.md`
2. Follow `context/mrs/_TEMPLATE.md`

## Process — Review
1. Get diff
2. Pick level: chill / normal / estricto
3. Comments in spanish, casual, short
4. Save in `context/reviews/`
