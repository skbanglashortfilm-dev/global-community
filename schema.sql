create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null check (char_length(username) between 3 and 30),
  full_name text not null default '',
  avatar_url text,
  bio text not null default '',
  country text,
  role text not null default 'user' check (role in ('user','admin')),
  created_at timestamptz not null default now()
);

create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references public.profiles(id) on delete cascade,
  body text not null default '',
  media_url text,
  visibility text not null default 'public' check (visibility in ('public','friends','private')),
  created_at timestamptz not null default now(),
  check (char_length(body) <= 5000)
);

create table if not exists public.likes (
  post_id uuid not null references public.posts(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (post_id,user_id)
);

create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  author_id uuid not null references public.profiles(id) on delete cascade,
  parent_id uuid references public.comments(id) on delete cascade,
  body text not null check (char_length(body) between 1 and 2000),
  created_at timestamptz not null default now()
);

create table if not exists public.friendships (
  id uuid primary key default gen_random_uuid(),
  requester_id uuid not null references public.profiles(id) on delete cascade,
  addressee_id uuid not null references public.profiles(id) on delete cascade,
  status text not null default 'pending' check (status in ('pending','accepted','declined')),
  created_at timestamptz not null default now(),
  unique(requester_id,addressee_id),
  check (requester_id <> addressee_id)
);

create table if not exists public.follows (
  follower_id uuid not null references public.profiles(id) on delete cascade,
  following_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key(follower_id,following_id),
  check(follower_id <> following_id)
);

create table if not exists public.conversations (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now()
);
create table if not exists public.conversation_members (
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  primary key(conversation_id,user_id)
);
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  sender_id uuid not null references public.profiles(id) on delete cascade,
  body text not null check(char_length(body) between 1 and 5000),
  created_at timestamptz not null default now()
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  actor_id uuid references public.profiles(id) on delete set null,
  kind text not null,
  entity_id uuid,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.groups (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text not null default '',
  creator_id uuid not null references public.profiles(id) on delete cascade,
  is_public boolean not null default true,
  created_at timestamptz not null default now()
);
create table if not exists public.group_members (
  group_id uuid not null references public.groups(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  role text not null default 'member' check(role in ('member','moderator','admin')),
  joined_at timestamptz not null default now(),
  primary key(group_id,user_id)
);

create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references public.profiles(id) on delete cascade,
  target_type text not null check(target_type in ('post','comment','profile','message','group')),
  target_id uuid not null,
  reason text not null,
  status text not null default 'open' check(status in ('open','reviewing','resolved','dismissed')),
  created_at timestamptz not null default now()
);

create index if not exists posts_created_at_idx on public.posts(created_at desc);
create index if not exists comments_post_idx on public.comments(post_id,created_at);
create index if not exists messages_conversation_idx on public.messages(conversation_id,created_at);
create index if not exists notifications_user_idx on public.notifications(user_id,created_at desc);

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public
as $$
declare uname text;
begin
  uname := coalesce(nullif(new.raw_user_meta_data->>'username',''), 'user_' || substr(new.id::text,1,8));
  insert into public.profiles(id,username,full_name)
  values(new.id, uname, coalesce(new.raw_user_meta_data->>'full_name',''));
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();

alter table public.profiles enable row level security;
alter table public.posts enable row level security;
alter table public.likes enable row level security;
alter table public.comments enable row level security;
alter table public.friendships enable row level security;
alter table public.follows enable row level security;
alter table public.conversations enable row level security;
alter table public.conversation_members enable row level security;
alter table public.messages enable row level security;
alter table public.notifications enable row level security;
alter table public.groups enable row level security;
alter table public.group_members enable row level security;
alter table public.reports enable row level security;

create policy "profiles readable by authenticated" on public.profiles for select to authenticated using (true);
create policy "users insert own profile" on public.profiles for insert to authenticated with check (auth.uid()=id);
create policy "users update own profile" on public.profiles for update to authenticated using (auth.uid()=id) with check (auth.uid()=id);

create policy "public posts readable" on public.posts for select to authenticated using (visibility='public' or author_id=auth.uid());
create policy "create own posts" on public.posts for insert to authenticated with check (author_id=auth.uid());
create policy "edit own posts" on public.posts for update to authenticated using (author_id=auth.uid()) with check (author_id=auth.uid());
create policy "delete own posts" on public.posts for delete to authenticated using (author_id=auth.uid());

create policy "likes readable" on public.likes for select to authenticated using (true);
create policy "like as self" on public.likes for insert to authenticated with check (user_id=auth.uid());
create policy "unlike as self" on public.likes for delete to authenticated using (user_id=auth.uid());

create policy "comments readable" on public.comments for select to authenticated using (true);
create policy "comment as self" on public.comments for insert to authenticated with check (author_id=auth.uid());
create policy "edit own comment" on public.comments for update to authenticated using (author_id=auth.uid()) with check (author_id=auth.uid());
create policy "delete own comment" on public.comments for delete to authenticated using (author_id=auth.uid());

create policy "friendship participants read" on public.friendships for select to authenticated using (requester_id=auth.uid() or addressee_id=auth.uid());
create policy "send friend request" on public.friendships for insert to authenticated with check (requester_id=auth.uid());
create policy "respond friend request" on public.friendships for update to authenticated using (addressee_id=auth.uid()) with check (addressee_id=auth.uid());
create policy "cancel own request" on public.friendships for delete to authenticated using (requester_id=auth.uid() or addressee_id=auth.uid());

create policy "follows readable" on public.follows for select to authenticated using (true);
create policy "follow as self" on public.follows for insert to authenticated with check (follower_id=auth.uid());
create policy "unfollow as self" on public.follows for delete to authenticated using (follower_id=auth.uid());

create policy "groups public readable" on public.groups for select to authenticated using (is_public or creator_id=auth.uid());
create policy "create group" on public.groups for insert to authenticated with check (creator_id=auth.uid());
create policy "group members readable" on public.group_members for select to authenticated using (true);
create policy "join as self" on public.group_members for insert to authenticated with check (user_id=auth.uid());
create policy "leave own group" on public.group_members for delete to authenticated using (user_id=auth.uid());

create policy "members read conversations" on public.conversations for select to authenticated using (
 exists(select 1 from public.conversation_members cm where cm.conversation_id=id and cm.user_id=auth.uid()));
create policy "users see own memberships" on public.conversation_members for select to authenticated using (user_id=auth.uid());
create policy "add self membership" on public.conversation_members for insert to authenticated with check (user_id=auth.uid());
create policy "members read messages" on public.messages for select to authenticated using (
 exists(select 1 from public.conversation_members cm where cm.conversation_id=messages.conversation_id and cm.user_id=auth.uid()));
create policy "send message as member" on public.messages for insert to authenticated with check (
 sender_id=auth.uid() and exists(select 1 from public.conversation_members cm where cm.conversation_id=messages.conversation_id and cm.user_id=auth.uid()));

create policy "own notifications" on public.notifications for select to authenticated using (user_id=auth.uid());
create policy "mark own notifications" on public.notifications for update to authenticated using (user_id=auth.uid()) with check (user_id=auth.uid());
create policy "report as self" on public.reports for insert to authenticated with check (reporter_id=auth.uid());
create policy "read own reports" on public.reports for select to authenticated using (reporter_id=auth.uid());

-- Storage: create a public bucket named post-media in the Supabase dashboard.
insert into storage.buckets (id,name,public) values ('post-media','post-media',true)
on conflict (id) do nothing;
create policy "post media public read" on storage.objects for select using (bucket_id='post-media');
create policy "upload own post media" on storage.objects for insert to authenticated
with check (bucket_id='post-media' and (storage.foldername(name))[1]=auth.uid()::text);
create policy "delete own post media" on storage.objects for delete to authenticated
using (bucket_id='post-media' and (storage.foldername(name))[1]=auth.uid()::text);

-- Enable realtime for messaging (run once; ignore if already included).
do $$ begin
  alter publication supabase_realtime add table public.messages;
exception when duplicate_object then null;
when others then null;
end $$;
