-- Peer Feedback schema. Run ONCE in Supabase -> SQL Editor -> New query -> Run.

-- 1) Tables ---------------------------------------------------------------
create table public.profiles (
  id      uuid primary key references auth.users (id) on delete cascade,
  reg_no  text unique,
  name    text not null,
  role    text not null default 'student' check (role in ('student', 'admin'))
);

create table public.feedback (
  id         uuid primary key default gen_random_uuid(),
  from_user  uuid not null references public.profiles (id) on delete cascade,
  to_user    uuid not null references public.profiles (id) on delete cascade,
  message    text not null check (char_length(btrim(message)) between 1 and 500),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint one_feedback_per_pair unique (from_user, to_user),   -- only one chance per classmate
  constraint no_self_feedback check (from_user <> to_user)
);

create index feedback_to_user_idx on public.feedback (to_user);

-- 2) Helper: role of the logged-in user (NULL if they have no profile) ------
create or replace function public.current_app_role()
returns text
language sql
stable
security definer
set search_path = ''
as $$
  select role from public.profiles where id = auth.uid()
$$;

-- 3) Keep updated_at honest on edits ---------------------------------------
create or replace function public.touch_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create trigger feedback_touch_updated_at
before update on public.feedback
for each row execute function public.touch_updated_at();

-- 4) Table privileges (column-level, so users can't forge created_at) -------
revoke all on public.profiles from anon, authenticated;
revoke all on public.feedback from anon, authenticated;

grant select on public.profiles to authenticated;
grant select, delete on public.feedback to authenticated;
grant insert (from_user, to_user, message) on public.feedback to authenticated;
grant update (message) on public.feedback to authenticated;

-- 5) Row Level Security (this is the AUTHORIZATION layer) -------------------
alter table public.profiles enable row level security;
alter table public.feedback enable row level security;

-- Any logged-in user who has a profile can see the class directory (name + reg no only).
create policy "directory visible to class members"
on public.profiles for select to authenticated
using (public.current_app_role() is not null);

-- Feedback is visible to: the sender, the receiver, and the admin.
create policy "read own sent/received feedback, admin reads all"
on public.feedback for select to authenticated
using (
  auth.uid() = from_user
  or auth.uid() = to_user
  or public.current_app_role() = 'admin'
);

-- Only students can send, only as themselves, only to another student.
create policy "students send feedback as themselves"
on public.feedback for insert to authenticated
with check (
  auth.uid() = from_user
  and public.current_app_role() = 'student'
  and exists (select 1 from public.profiles p where p.id = to_user and p.role = 'student')
);

-- Sender may edit or delete their own feedback only within 30 days of creating it.
create policy "sender edits within 30 days"
on public.feedback for update to authenticated
using (auth.uid() = from_user and created_at > now() - interval '30 days')
with check (auth.uid() = from_user);

create policy "sender deletes within 30 days"
on public.feedback for delete to authenticated
using (auth.uid() = from_user and created_at > now() - interval '30 days');
