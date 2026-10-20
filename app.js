// Shared helpers used by every page.
// Loaded after config.js (which creates the global `sb` client).

// Format an ISO timestamp as e.g. "12 Oct 2026".
function formatDate(iso) {
  if (!iso) return '';
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return '';
  return d.toLocaleDateString(undefined, {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  });
}

// True when the ISO timestamp is within the last 30 days (editing/deleting window).
function within30Days(iso) {
  if (!iso) return false;
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return false;
  return (Date.now() - d.getTime()) <= 30 * 24 * 60 * 60 * 1000;
}

// Require an active session AND a profile with the given role.
// Redirects to index.html if not. Returns { session, profile } or null.
async function requireRole(role) {
  const { data: { session }, error } = await sb.auth.getSession();
  if (error || !session) {
    window.location.href = 'index.html';
    return null;
  }
  const { data: profile, error: perr } = await sb
    .from('profiles')
    .select('*')
    .eq('id', session.user.id)
    .single();
  if (perr || !profile || profile.role !== role) {
    window.location.href = 'index.html';
    return null;
  }
  return { session, profile };
}

// Sign out and send the user back to the login page.
async function logout() {
  try {
    await sb.auth.signOut();
  } catch (_) {
    // ignore — go to login regardless
  }
  window.location.href = 'index.html';
}

// Safely set text on an element (uses textContent to avoid XSS).
function setText(el, text) {
  if (el) el.textContent = text == null ? '' : String(text);
}

// Show an inline message inside an element using a status class.
function showStatus(el, message, kind) {
  if (!el) return;
  el.textContent = message == null ? '' : String(message);
  el.className = 'status' + (kind ? ' status-' + kind : '');
  el.style.display = message ? '' : 'none';
}

// Disable a button while a request runs, then re-enable it.
async function withBusy(btn, fn) {
  if (!btn) return fn();
  const prev = btn.disabled;
  btn.disabled = true;
  try {
    return await fn();
  } finally {
    btn.disabled = prev;
  }
}

// Decode a user-facing error message from a Supabase response.
function errorMessage(err, fallback) {
  if (!err) return fallback || '';
  if (typeof err === 'string') return err;
  if (err.message) return err.message;
  return fallback || 'Something went wrong. Please try again.';
}
