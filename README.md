# Class Peer Feedback

A lightweight web app where students sign in and give written feedback to their classmates. Each student can give feedback to a classmate only once, edit or delete it within 30 days of posting, and view feedback they have sent and received. An admin can monitor all activity and remove inappropriate entries.

## Features

**Student**

- Email and password login.
- Search classmates by name or registration number.
- Give written feedback (max 500 characters) to a classmate, one per person.
- Edit or delete your feedback within 30 days of posting; after that it is locked.
- Change your account password.
- View feedback you have received and feedback you have given.

**Admin**

- Dashboard stats: total feedback, students who gave at least one, students who received at least one.
- Read-only table of all feedback, searchable by sender, receiver or message.
- Delete feedback that violates rules (any entry, any time).
- List of students who have not given any feedback yet.

## Tech stack

- HTML, CSS and vanilla JavaScript (no frameworks, no build step).
- Supabase for Postgres storage and email/password authentication.
- Hosted on GitHub Pages as static files.

## How it works

Authentication uses Supabase email/password login (`signInWithPassword`). After login the app reads the user's profile and redirects students to the student page and admins to the admin page. Authorization is enforced by Supabase Row Level Security policies, not the UI: students can read only feedback they sent or received, edit or delete only their own rows and only within 30 days of posting, while the admin can read all feedback and delete any row. The interface only calls the API and shows a clear message when the database refuses an action.

## Database

- `profiles(id, reg_no, name, role)` — one row per user. `role` is either `student` or `admin`.
- `feedback(id, from_user, to_user, message, created_at, updated_at)` — one row per feedback message.
- `from_user` and `to_user` reference `profiles(id)`. A unique constraint on `(from_user, to_user)` enforces one feedback per pair.

## Security notes

- All user-generated text is rendered with `textContent`, never `innerHTML`, to prevent XSS.
- No secret keys are committed to the repository. The `service_role` key is never used in the browser.
- The public `anon` key in `config.js` is safe to expose because Row Level Security restricts what it can do.

## Setup and deployment

1. Open `config.js` and paste your Supabase project URL and anon public key (Supabase dashboard > Project Settings > API).
2. Ensure the `profiles` and `feedback` tables and RLS policies exist in your Supabase project.
3. Create accounts from the Supabase dashboard (there is no signup page).
4. Push the files to a GitHub repository's `main` branch, root folder.
5. In GitHub, go to Settings > Pages > Deploy from a branch, select `main` and `/ (root)`.
6. Open the published URL and log in.

## Project structure

- `index.html` — login page.
- `app.html` — student page (give, edit, delete, view feedback; change password).
- `admin.html` — admin page (stats, all feedback table, delete, non-participants list).
- `style.css` — shared grey theme.
- `app.js` — shared helpers (session checks, logout, date formatting, safe rendering).
- `config.js` — Supabase URL and anon key, creates the client.
- `README.md` — this file.
