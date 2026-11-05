// Restablecer el PIN de un trabajador (sección Seguridad de la tesis).
//
// El encargado no elige ni conoce el PIN nuevo: la función borra la cuenta de
// Auth del trabajador; por la FK `usuario.auth_id ... on delete set null` el
// usuario vuelve a quedar PREREGISTRADO y en su próximo ingreso elige un PIN
// nuevo. Cambiar o borrar cuentas de otros requiere la clave de servicio, que
// por eso vive acá y nunca en la app (decisión D10 en docs/trazabilidad.md).
//
// POST /functions/v1/restablecer-pin   { "usuario_id": "<uuid>" }
// Authorization: Bearer <token de acceso del encargado>
import { createClient } from "npm:@supabase/supabase-js@2";

const url = Deno.env.get("SUPABASE_URL")!;
const claveServicio = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ??
  JSON.parse(Deno.env.get("SUPABASE_SECRET_KEYS") ?? "{}").default;

const admin = createClient(url, claveServicio, {
  auth: { persistSession: false, autoRefreshToken: false },
});

const respuesta = (cuerpo: unknown, status = 200) =>
  new Response(JSON.stringify(cuerpo), {
    status,
    headers: { "Content-Type": "application/json" },
  });

Deno.serve(async (req) => {
  if (req.method !== "POST") return respuesta({ error: "Usar POST" }, 405);

  // 1. Quién llama: se valida el token contra Auth.
  const token = req.headers.get("Authorization")?.replace(/^Bearer\s+/i, "");
  if (!token) return respuesta({ error: "Falta iniciar sesión" }, 401);
  const { data: sesion, error: errSesion } = await admin.auth.getUser(token);
  if (errSesion || !sesion.user) return respuesta({ error: "Sesión inválida" }, 401);

  const { data: llamante } = await admin
    .from("usuario")
    .select("id")
    .eq("auth_id", sesion.user.id)
    .eq("activo", true)
    .eq("rol", "ENCARGADO")
    .maybeSingle();
  if (!llamante) {
    return respuesta({ error: "Solo un encargado puede restablecer un PIN" }, 403);
  }

  // 2. A quién: solo trabajadores.
  let usuarioId: string | undefined;
  try {
    usuarioId = (await req.json()).usuario_id;
  } catch {
    // cuerpo vacío o inválido
  }
  if (!usuarioId) return respuesta({ error: "Falta usuario_id" }, 400);

  const { data: trabajador } = await admin
    .from("usuario")
    .select("id, rol, auth_id")
    .eq("id", usuarioId)
    .maybeSingle();
  if (!trabajador) return respuesta({ error: "No existe ese usuario" }, 404);
  if (trabajador.rol !== "TRABAJADOR") {
    return respuesta({ error: "Solo se restablece el PIN de trabajadores" }, 400);
  }
  if (!trabajador.auth_id) return respuesta({ estado: "PREREGISTRADO" });

  // 3. Se borra la cuenta de Auth; el usuario vuelve a PREREGISTRADO.
  const { error } = await admin.auth.admin.deleteUser(trabajador.auth_id);
  if (error) return respuesta({ error: "No se pudo restablecer el PIN" }, 500);

  return respuesta({ estado: "PREREGISTRADO" });
});
