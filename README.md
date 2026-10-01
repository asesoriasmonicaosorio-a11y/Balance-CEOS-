# Cuadra el Balance

Juego arcade contable, estilo terminal de los 80. Caen cuentas del PUC como
piezas de Tetris y hay que soltarlas en la columna correcta — **Activo**,
**Pasivo** o **Patrimonio** — hasta que se cumpla la ecuacion patrimonial:

```
ACTIVO = PASIVO + PATRIMONIO
```

Cada nivel es un cliente que llega a la ventanilla con su juego de cuentas.
Las cifras de cada nivel estan calculadas para que, si todo queda bien
clasificado, el balance cuadre exacto.

---

## 1. Archivos del proyecto

| Archivo | Que hace |
|---|---|
| `index.html` | El juego completo: tablero, motor, marcador y panel de ranking. No necesita compilar nada. |
| `config.js` | Lo unico que se edita: URL y llave publica de Supabase. |
| `ranking.sql` | Script que crea la tabla `ranking` con seguridad y tiempo real. |
| `README.md` | Este documento. |

---

## 2. Como jugar

| Tecla | Accion |
|---|---|
| `←` `→` | Mover la cuenta entre columnas |
| `1` `2` `3` | Soltar directo en Activo / Pasivo / Patrimonio |
| `↓` | Acelerar la caida |
| `Espacio` | Soltar de una vez |
| `P` | Pausa |

En celular aparecen tres botones debajo del tablero.

### Puntaje

| Evento | Efecto |
|---|---|
| Cuenta bien clasificada | +100 x racha (la racha sube hasta x5) |
| Cuenta mal clasificada | −25 y se pierde una vida (hay 3) |
| Nivel con la ecuacion cuadrada | +500 x numero de nivel |
| Vidas que quedan al cerrar el nivel | +100 cada una |

La partida termina cuando se acaban las vidas o cuando se atienden los
5 clientes. Ahi se pide el nombre y el puntaje entra al ranking.

### Niveles

| # | Cliente | Cuentas | Lo que entrena |
|---|---|---|---|
| 1 | Tienda La Esquina | 7 | Estructura basica del balance |
| 2 | Agro del Oriente S.A.S. | 9 | Propiedad planta y equipo, obligaciones financieras |
| 3 | Constructora Altavila | 12 | Impuestos a favor vs. impuestos por pagar |
| 4 | Manufacturas Esferica | 14 | Cuentas de naturaleza contraria: depreciacion acumulada, perdida del ejercicio |
| 5 | Inversiones Noval | 18 | Cuentas por cobrar a socios, dividendos, recaudos de terceros |

> Las cuentas de naturaleza contraria son la trampa del juego:
> la **depreciacion acumulada** es credito pero pertenece al **Activo**
> (lo disminuye), y la **perdida del ejercicio** es debito pero pertenece
> al **Patrimonio** (lo disminuye). En el juego se muestran entre
> parentesis, como en un balance real.

---

## 3. Base de datos (Supabase)

Una sola tabla, `public.ranking`:

| Columna | Tipo | Para que |
|---|---|---|
| `id` | `bigint` identity | Llave primaria |
| `nombre` | `text` (1 a 20 caracteres) | Quien jugo |
| `puntuacion` | `integer` (0 a 1.000.000) | Puntaje final |
| `creado_en` | `timestamptz` (`now()`) | Trazabilidad de cada registro |

### Pasos

1. Crear el proyecto en [supabase.com](https://supabase.com).
2. **SQL Editor → New query**, pegar todo el contenido de `ranking.sql` y
   ejecutar. El script se puede volver a correr sin danar nada.
3. **Project Settings → API**, copiar `Project URL` y la llave `anon public`.
4. Pegarlas en `config.js`.

### Seguridad

La tabla queda con RLS (Row Level Security) activo y solo dos permisos
para el publico: **leer** el ranking e **insertar** su propio puntaje, con
las mismas validaciones de la tabla. No hay politica de `update` ni de
`delete`, asi que desde el navegador nadie puede editar ni borrar puntajes.
Para corregir algo se entra al panel de Supabase.

La llave `anon` es publica por diseno: va en el codigo del navegador y solo
puede hacer lo que permita RLS. La llave `service_role` **nunca** se pone
en estos archivos.

### Ranking en vivo

`index.html` se suscribe a los `INSERT` de la tabla por Realtime, asi que
el tablero se actualiza solo cuando alguien mas registra un puntaje. Como
respaldo recarga cada 30 segundos.

Si `config.js` todavia no esta diligenciado, el juego funciona igual y
guarda el ranking en el navegador (`localStorage`), marcado como
*modo local*.

---

## 4. Publicacion

### GitHub

```bash
cd "ruta/de/la/carpeta"
git init
git add .
git commit -m "Cuadra el Balance: juego inicial"
git branch -M main
git remote add origin https://github.com/USUARIO/cuadra-el-balance.git
git push -u origin main
```

### Vercel

1. [vercel.com](https://vercel.com) → **Add New → Project** → importar el
   repositorio.
2. Framework preset: **Other**. No hay build command ni output directory:
   es un sitio estatico.
3. **Deploy**.

Como `config.js` se sube al repositorio, el despliegue queda configurado
sin variables de entorno. Si el repositorio es publico, recuerde que la
URL y la llave `anon` quedan visibles — eso es normal y seguro mientras
RLS este activo, que es lo que hace `ranking.sql`.

### Dominio del juego en Supabase

Despues del despliegue conviene limitar el origen permitido en
**Supabase → Authentication → URL Configuration**, agregando la URL de
Vercel.

---

## 5. Prueba local

Basta abrir `index.html` con doble clic. Para que Realtime funcione sin
advertencias del navegador, mejor servirlo:

```bash
python -m http.server 8000
# luego abrir http://localhost:8000
```

---

## 6. Como agregar o cambiar cuentas

Dentro de `index.html`, en el bloque `var NIVELES = [...]`. Cada cuenta es:

```js
{n:"Nombre de la cuenta", v:30, g:0}   // g: 0 Activo · 1 Pasivo · 2 Patrimonio
```

Regla unica: dentro de cada nivel, la suma de las cuentas con `g:0` debe
ser igual a la suma de `g:1` mas `g:2`. Si no, el nivel nunca cuadra.

---

Cifras expresadas en millones de pesos. Clasificacion segun el Plan Unico
de Cuentas colombiano (Decreto 2650 de 1993): grupo 1 Activo, grupo 2
Pasivo, grupo 3 Patrimonio.
