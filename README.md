 # realSteel – Aplicación para planificación y gestión de rutinas de entrenamiento
🏋️‍♂️ Descripción del proyecto

realSteel es una aplicación multiplataforma desarrollada como Proyecto Final de Ciclo (DAM).
Su objetivo es permitir a los usuarios crear, organizar y registrar sus rutinas de entrenamiento, facilitando el seguimiento del progreso y promoviendo hábitos de ejercicio saludables.

La aplicación está orientada exclusivamente al usuario individual, sin integrar funciones de gestión de gimnasios.

📱 Tecnologías utilizadas
Aplicación móvil (Android)

Lenguaje: Java

Entorno: Android Studio

Base de datos local: SQLite

Librerías adicionales: Pending API (vídeos/GIFs de ejercicios)

Aplicación de escritorio

Lenguaje: Java

Framework de interfaz: JavaFX (o Swing según implementación final)

Base de datos: SQLite local / sincronización futura

APIs externas

API de ejercicios con GIFs/vídeos (por ejemplo: ExerciseDB, Wger, o similar)

🧠 Objetivos del proyecto

Permitir al usuario crear rutinas y gestionar su entrenamiento semanal o mensual.

Registrar pesos, repeticiones y ejercicios realizados.

Mostrar GIFs o vídeos de cada ejercicio para ayudar a usuarios novatos.

Guardar el progreso y mostrar estadísticas básicas.

Ofrecer una experiencia intuitiva y rápida sin necesidad de conocimientos previos.

🎯 Características principales

📅 Calendario interactivo para planificar rutinas.

📝 Registro de ejercicios por grupo muscular.

📊 Historial de pesos y progreso del usuario.

🖼️ Videos/GIFs explicativos mediante API externa.

🔔 Notificaciones recordatorias (Android).

🗂️ Persistencia local con SQLite.

☁️ Plan futuro: sincronización en la nube (Firebase / backend propio).

📂 Estructura del repositorio
/docs
    ├── arquitectura_C1C2.pdf
    ├── memoria_TFG.pdf
/src
    ├── android_app/        # Código fuente de Android
    ├── desktop_app/        # Código de JavaFX/Swing
/diagrams
    ├── C1_Context.mmd
    ├── C2_Containers.mmd
README.md

🧪 Historias de usuario (resumen)

HU-001: Crear rutina semanal

HU-002: Registrar peso por ejercicio

HU-003: Seleccionar gimnasio local

HU-004: Recibir notificaciones

HU-005: Visualizar progreso en gráficas

👥 Autores

Proyecto realizado por:

Fernando Romero Gil

Carlos de Tena Muñoz

Ciclo Formativo: Desarrollo de Aplicaciones Multiplataforma (DAM)
Año académico: 2024–2025

📘 Licencia

Este proyecto se distribuye bajo licencia MIT.
Puedes usarlo, modificarlo y compartirlo libremente citando a los autores.
