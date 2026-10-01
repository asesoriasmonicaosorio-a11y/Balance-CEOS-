-- =====================================================================
-- CUADRA EL BALANCE  ·  ranking.sql
-- Base de datos del juego  ·  Supabase / PostgreSQL
-- ---------------------------------------------------------------------
-- Como ejecutarlo:
--   Supabase > SQL Editor > New query > pegar todo > RUN
-- El script es idempotente: se puede volver a correr sin romper nada.
--
-- Una sola tabla: public.ranking
--   nombre      -> quien jugo
--   puntuacion  -> puntaje final de la partida
--   id          -> llave tecnica
--   creado_en   -> sello de tiempo (trazabilidad de cada registro)
-- =====================================================================


-- 1. TABLA -------------------------------------------------------------
create table if not exists public.ranking (
  id          bigint generated always as identity primary key,
  nombre      text        not null,
  puntuacion  integer     not null default 0,
  creado_en   timestamptz not null default now(),

  constraint ranking_nombre_valido
    check (char_length(btrim(nombre)) between 1 and 20),

  constraint ranking_puntuacion_valida
    check (puntuacion >= 0 and puntuacion <= 1000000)
);

comment on table  public.ranking             is 'Puntajes de Cuadra el Balance';
comment on column public.ranking.nombre     is 'Nombre o alias del jugador (1 a 20 caracteres)';
comment on column public.ranking.puntuacion is 'Puntaje final de la partida';
comment on column public.ranking.creado_en  is 'Fecha y hora UTC en que se registro el puntaje';


-- 2. INDICE para ordenar el ranking rapido -----------------------------
create index if not exists ranking_puntuacion_idx
  on public.ranking (puntuacion desc, creado_en asc);


-- 3. SEGURIDAD (RLS) ---------------------------------------------------
-- Con RLS activo, el cliente solo puede hacer lo que digan las politicas.
alter table public.ranking enable row level security;

-- Cualquiera puede LEER el ranking
drop policy if exists ranking_lectura_publica on public.ranking;
create policy ranking_lectura_publica
  on public.ranking
  for select
  to anon, authenticated
  using (true);

-- Cualquiera puede INSERTAR su puntaje, validado otra vez aqui
drop policy if exists ranking_insercion_publica on public.ranking;
create policy ranking_insercion_publica
  on public.ranking
  for insert
  to anon, authenticated
  with check (
    char_length(btrim(nombre)) between 1 and 20
    and puntuacion >= 0
    and puntuacion <= 1000000
  );

-- OJO: no se crean politicas de UPDATE ni DELETE.
-- Sin politica, la operacion queda bloqueada: nadie puede
-- editar ni borrar puntajes desde el navegador. Solo tu,
-- desde el panel de Supabase, con la service_role key.


-- 4. TIEMPO REAL -------------------------------------------------------
-- Agrega la tabla a la publicacion de Realtime para que el
-- ranking se actualice en vivo sin recargar la pagina.
do $$
begin
  alter publication supabase_realtime add table public.ranking;
exception
  when duplicate_object then null;  -- ya estaba agregada
end $$;


-- 5. VERIFICACION (opcional) -------------------------------------------
-- select nombre, puntuacion, creado_en
--   from public.ranking
--  order by puntuacion desc, creado_en asc
--  limit 10;
