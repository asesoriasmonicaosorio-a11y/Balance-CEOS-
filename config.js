/* ============================================================
   CUADRA EL BALANCE  ·  config.js
   ------------------------------------------------------------
   Unico archivo que debes editar para conectar el juego.
   Los valores salen de: Supabase > Project Settings > API
   La ANON KEY es publica por diseno (solo permite lo que
   autoricen las politicas RLS creadas en ranking.sql).
   ============================================================ */

window.CONFIG = {

  // 1) URL del proyecto. Ej: "https://abcdefghijklm.supabase.co"
  SUPABASE_URL: "PEGA_AQUI_TU_PROJECT_URL",

  // 2) Clave publica anonima (anon / public).
  SUPABASE_ANON_KEY: "PEGA_AQUI_TU_ANON_KEY",

  // 3) Nombre de la tabla creada con ranking.sql. No cambiar
  //    salvo que tambien lo cambies en el .sql
  TABLA_RANKING: "ranking",

  // 4) Cuantos puestos se muestran en el tablero de ranking
  TOP_RANKING: 10,

  // 5) Largo maximo del nombre del jugador (debe coincidir con
  //    el CHECK de la tabla en ranking.sql)
  MAX_LARGO_NOMBRE: 20
};
