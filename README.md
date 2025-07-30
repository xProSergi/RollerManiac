# 🎢 RollerManiac

**RollerManiac** es una app móvil multiplataforma que transforma la experiencia de los amantes de los parques de atracciones. Desarrollada con Flutter, permite consultar tiempos de espera de las atracciones en tiempo real, competir con amigos, registrar visitas y mucho más, todo en un solo lugar. El propósito de RollerManiac es centralizar en una única aplicación toda la información relevante. La aplicación nace por la necesidad en los visitantes de parques ya que, actualmente, la información sobre tiempos de espera, atracciones se encuentra dispersa en distintas apps. RollerManiac soluciona esto al integrar todas estas funcionalidades bajo una interfaz clara, visual e intuitiva.

---

## 🚀 Características principales

- ✅ **Consulta de tiempos de espera en tiempo real. Mediante la integración de la API de Queue-Times es posible consultar estos datos**
- ✅ **Historial de visitas con fecha y duración**
- ✅ **Sistema social para agregar, aceptar y gestionar amigos**
- ✅ **Ranking entre amigos por visitas**
- ✅ **Clima en tiempo real de tus parques favoritos**
- ✅ **Inicio de sesión con email y Google**  
- ✅ **Fichaje de entrada y salida de parques**  
- ✅ **Pantalla de perfil con edición y cierre de sesión**



---

## 🧠 ¿Por qué este proyecto?

**RollerManiac** nace con el propósito de unir mi pasión por los parques de atracciones con mi formación como desarrollador. Mi objetivo fue crear una aplicación funcional, realista y escalable, aplicando estándares propios de entornos profesionales.Este proyecto me permitió trabajar desde cero en un producto completo, cubriendo tanto el diseño técnico como la experiencia de usuario, y me enfrentó a retos reales de desarrollo. Los principales objetivos fueron:

- Diseñar una app con valor real para el usuario final, mejorando su experiencia en parques de atracciones y facilitando la interacción social entre gente con la misma afición.
- Integrar servicios reales: trabajar con Firebase (Auth, Firestore) y otras APIs, gestionando datos en tiempo real.
- Crear una comunidad de fans de parques de atracciones y montañas rusas.
- Aplicar buenas prácticas de arquitectura de software, utilizando MVVM y Clean Architecture con separación clara de capas, código modular, mantenible y preparado para testeo e inyección de dependencias.
- Desarrollar competencias profesionales: desde la planificación, la implementación modular, la validación de formularios y flujos, hasta el testing y la preparación del proyecto para producción.

Este proyecto ha sido una experiencia **realista y transversal** que demuestra mi capacidad para desarrollar, escalar y mantener una aplicación profesional de principio a fin, trabajando con tecnologías actuales y aplicando prácticas alineadas con las exigencias del sector IT.

---

## 🖼️ Capturas de pantalla

<!-- Añade tus imágenes aquí cuando las tengas -->
<p align="center">
  <img src="screenshots/login_screen.png" width="250" />
  <img src="screenshots/fichaje_screen.png" width="250" />
  <img src="screenshots/social_screen.png" width="250" />
</p>

---

## 🛠️ Tecnologías y herramientas

- **Flutter + Dart**
- **Firebase Auth & Firestore**
- **Clean Architecture + MVVM**
- **Provider para gestión de estado**
- **SharedPreferences**
- **OpenWeatherMap API (clima en tiempo real)**
- **Queue-Times API (tiempos de espera en atracciones)**

---

## 🧱 Arquitectura y buenas prácticas

El proyecto está estructurado siguiendo Clean Architecture y el patrón MVVM:

Cada **feature** se divide en:

- data/ → data sources, modelos DTO  
- domain/ → entidades, repositorios  
- presentation/ → widgets, pantallas, ViewModels  

✅ Separación clara de responsabilidades  
✅ Fácil de testear y escalar  
✅ Preparado para inyección de dependencias (si se desea)  

## 🧪 Fase de pruebas y validación real
 -Pruebas en 10 dispositivos físicos reales mediante testers
 -Simulación de escenarios offline
 -Feedback continuo de usuarios reales 
 -Modificaciones sobre interfaz y usabilidad según feedback


## 📌 Retos técnicos superados
 -Configuración avanzada de inicio de sesión con Google y claves SHA-1/SHA-256
 -Tratamiento de JSONs inconsistentes en Queue-Times con lógica adaptativa
 -Implementación modular y desacoplada con arquitectura robusta
 -Gestión eficiente del estado con Provider y reconstrucciones controladas



## 🔭 Futuras mejoras
RollerManiac está en una fase avanzada, pero diseñada para escalar. Algunas líneas de evolución previstas:

-Sistema de logros y medallas por visitas
-Ranking global entre todos los usuarios registrados
-Estadísticas visuales y panel de usuario con gráficos sobre visitas mensuales/anuales
-Integración de mapas interactivos con ubicaciones de atracciones
-Datos técnicos de montañas rusas (altura, velocidad, fuerzas Gs...)





---
