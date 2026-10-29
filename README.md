# Caja de Herramientas (Flutter)

**Brian Amaury Guzman Mañon — Matrícula 2024-1286**
Introducción al Desarrollo de Aplicaciones Móviles — ITLA

App en Flutter que reúne varias herramientas que consumen APIs públicas.

## Vistas

| Vista | Qué hace | API |
|---|---|---|
| Inicio | Foto de una caja de herramientas y menú de herramientas | — |
| Predecir género | Recibe un nombre; azul si es masculino, rosa si es femenino | https://api.genderize.io/?name=irma |
| Persona aleatoria | Nombre, apellido, foto, fecha de nacimiento y edad | https://randomuser.me/api/?results=1 |
| Universidades | Universidades de un país (en inglés): nombre, dominio y link | https://adamix.net/proxy.php?country=Dominican+Republic |
| Clima en RD | Clima del día en Santo Domingo | https://api.open-meteo.com/v1/forecast |
| Pokémon | Foto, experiencia base, habilidades y sonido (`cries.latest`) | https://pokeapi.co/api/v2/pokemon/pikachu |
| Noticias WordPress | Logo de TechCrunch y sus 3 últimas noticias con link "Visitar" | https://techcrunch.com/wp-json/wp/v2/posts?per_page=3 |
| Acerca de | Mi foto y datos de contacto | — |

El ícono de la app es mi foto (generado con `flutter_launcher_icons`).

## Ejecutar

```bash
flutter pub get
flutter run
flutter build apk --release
```

## Créditos

Foto de la caja de herramientas: [Toolbox (49985663631)](https://commons.wikimedia.org/wiki/File:Toolbox_(49985663631).jpg), Wikimedia Commons, CC0.
