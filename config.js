// Paste your Supabase project URL and anon (public) key below.
// You find these in your Supabase dashboard: Project Settings > API.
const SUPABASE_URL = 'https://ibwcultmbrvdrqxmheco.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_fFwsBEpvjffEYHE2pytmNA_t6WlrrbH';

// Create the shared Supabase client used by every page.
// The CDN exposes the library as window.supabase; our client is named sb
// to avoid redeclaring the global "supabase" identifier.
const sb = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
