# Class Peer Feedback

A small web app where students log in and give written feedback to their classmates. Admins can view all feedback and see who has not participated yet.

Built with **plain HTML, CSS and vanilla JavaScript** — no build step, no frameworks. The files can be hosted as-is on GitHub Pages.

## Files

- `index.html` — login page
- `app.html` — student page (give, edit, delete and view feedback; change password)
- `admin.html` — admin page (stats, all feedback table, students who haven't given feedback)
- `style.css` — shared grey theme
- `app.js` — shared helpers (session checks, logout, date formatting, safe text helpers)
- `config.js` — your Supabase project URL and anon key
- `README.md` — this file

## 1. Set up your Supabase keys

Open `config.js` and replace the two placeholder values with your own project's credentials:

```js
const SUPABASE_URL = 'PASTE_PROJECT_URL';
const SUPABASE_ANON_KEY = 'PASTE_ANON_KEY';
```

You find these in the Supabase dashboard:

1. Go to <https://supabase.com> and open your project.
2. In the left sidebar, click **Project Settings** (the gear icon).
3. Open the **API** section.
4. Copy the **Project URL** into `SUPABASE_URL`.
5. Copy the **anon public** key into `SUPABASE_ANON_KEY`. Do **not** use the `service_role` key — that key bypasses all security rules and must never be exposed in a browser app.

Save the file. The app reads these values at runtime, so you do not need to rebuild anything.

## 2. Backend (already set up)

This app expects an existing Supabase project with:

- A `profiles` table: `id`, `reg_no`, `name`, `role` (`'student'` or `'admin'`).
- A `feedback` table: `id`, `from_user`, `to_user`, `message`, `created_at`, `updated_at`, with one row allowed per `(from_user, to_user)`.
- Row Level Security policies that enforce who can read, insert, update and delete what.

Authentication uses Supabase email + password. The admin creates the accounts (there is no signup page).

## 3. Run locally

Because the app uses the Supabase JS client loaded from a CDN, you can open the files directly in a browser. For best results (so relative paths and cookies behave), serve the folder with any static server, for example:

```
python3 -m http.server
```

Then open the printed URL (usually `http://localhost:8000`).

## 4. Deploy on GitHub Pages

1. Create a new GitHub repository and upload all the files (`index.html`, `app.html`, `admin.html`, `style.css`, `app.js`, `config.js`, `README.md`) to the root of the `main` branch.
2. Open the repository on GitHub and go to **Settings > Pages**.
3. Under **Build and deployment**, set **Source** to **Deploy from a branch**.
4. Set **Branch** to `main` and the folder to `/ (root)`.
5. Click **Save**.

After a minute or two your site will be live at:

```
https://<your-username>.github.io/<your-repo-name>/
```

## Security notes

- **Never commit secret keys.** The `anon` key is safe to publish because it only works with your Row Level Security policies. The `service_role` key is secret — never put it in `config.js` or any client file, and never commit it to GitHub.
- **Never commit student data.** Do not export profiles, feedback or passwords into the repository. The database lives in Supabase, not in the repo.
- All user-generated text (names, registration numbers, feedback messages) is rendered with `textContent`, never `innerHTML`, to prevent cross-site scripting (XSS).
- Editing and deleting feedback are locked 30 days after posting. After that, students can only read what they wrote.
