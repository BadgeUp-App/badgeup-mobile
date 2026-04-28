# BadgeUp — Mobile

App de albumes coleccionables digitales. Tomas una foto con la camara, la IA reconoce que hay en la imagen y desbloquea automaticamente todos los stickers que correspondan, valida ubicacion GPS y va construyendo tu coleccion.

Cliente oficial de la API en <https://github.com/BadgeUp-App/badgeup-backend>.

## Concepto

BadgeUp convierte el viaje, la calle o la naturaleza en un album fisico-digital. Cada album es una coleccion tematica (autos, aves de Mexico, flora, fauna del safari, mascotas, lugares historicos). El usuario captura el contenido del album con la camara del telefono y la IA decide si la foto cuenta. Una sola foto puede desbloquear varios stickers cuando contiene mas de un elemento detectable.

## Highlights

- **Multi-unlock por foto:** una imagen con varias aves desbloquea todos los stickers que correspondan en una sola toma.
- **Validacion con IA:** OpenAI gpt-4.1-mini analiza cada captura contra el catalogo del album.
- **Mapa personal:** cada captura aprobada queda georreferenciada en un mapa interactivo que solo ve el dueno.
- **Reconocimiento facial opcional:** disponible para albumes de personas, comparando contra fotos de referencia.
- **Ranking global:** leaderboard de puntos por raridad de sticker desbloqueado.
- **Modo claro y oscuro** sincronizados al sistema, con toggle manual.
- **Sesion persistente** y soporte completo de login con Google.

## Stack

- Flutter SDK ^3.7
- Provider para state management (`ThemeProvider`, `UserSession`)
- google_fonts (Poppins), cached_network_image
- flutter_map + latlong2 para el mapa
- geolocator para GPS, image_picker para camara y galeria
- firebase_core + firebase_auth + google_sign_in
- shared_preferences, http
- Backend Django + DRF en Render (repo aparte)

## Estructura

```
lib/
├── main.dart              entry, MultiProvider, AuthGate
├── services/              api_config, content_api, auth_service, user_session
├── screens/               23 pantallas (login, main_shell, captura, mapa, ranking, etc.)
├── widgets/               componentes reutilizables
├── theme/                 ThemeProvider y AppTheme
└── models/                modelos de Album, Sticker, UserSticker
```

Navegacion principal: `Login` → `MainShell` con cinco tabs (Inicio, Albumes, Captura, Ranking, Perfil). Desde Perfil se accede a Amigos, Mapa, Calendario, Chat y Ajustes.

## Sistema de raridad

Cada sticker tiene una raridad y otorga puntos al desbloquearse:

| Raridad | Puntos |
| --- | --- |
| Comun | 50 |
| Raro | 100 |
| Epico | 200 |
| Legendario | 500 |

## Diseno

Tipografia Poppins. Gradiente principal azul `#3B82F6` a violeta `#6366F1`. Border radius entre 14 y 20px. Cards con sombra suave. Cero emojis en UI.

## Estado

App funcionando sobre iPhone fisico en build release. En proceso de submission al App Store bajo el bundle id `com.ferreirafc1133.badgeup`.

## Repos relacionados

- API: <https://github.com/BadgeUp-App/badgeup-backend>
- Org: <https://github.com/BadgeUp-App>
