import 'dart:ui' show Color;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Aviso de nueva asignación (HU-010, decisión D29). Lo dispara la
/// sincronización cuando trae una labor nueva para el trabajador de la
/// sesión; tocarlo abre el detalle de la labor (c2). El `payload` de la
/// notificación es el id de la tarea.
class Avisos {
  Avisos._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _inicializado = false;

  static const _canal = AndroidNotificationDetails(
    'asignaciones',
    'Nuevas labores',
    channelDescription: 'Aviso cuando el encargado te asigna una labor',
    importance: Importance.high,
    priority: Priority.high,
    icon: 'ic_notificacion',
    color: Color(0xFF2D5F4F),
  );

  /// [alTocar] recibe el id de la tarea cuando el trabajador toca el aviso
  /// con la app abierta o en segundo plano.
  static Future<void> inicializar({
    void Function(String tareaId)? alTocar,
  }) async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notificacion'),
      ),
      onDidReceiveNotificationResponse: (r) {
        final id = r.payload;
        if (id != null && alTocar != null) alTocar(id);
      },
    );
    _inicializado = true;
  }

  /// Si la app se abrió tocando un aviso, el id de la tarea.
  static Future<String?> tareaQueAbrioLaApp() async {
    final d = await _plugin.getNotificationAppLaunchDetails();
    if (d == null || !d.didNotificationLaunchApp) return null;
    return d.notificationResponse?.payload;
  }

  /// Android 13 o superior pide permiso para mostrar notificaciones.
  static Future<void> pedirPermiso() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  static Future<void> nuevaLabor({
    required String tareaId,
    required String titulo,
    required String detalle,
  }) async {
    if (!_inicializado) await inicializar();
    await _plugin.show(
      id: tareaId.hashCode & 0x7fffffff,
      title: titulo,
      body: detalle,
      notificationDetails: const NotificationDetails(android: _canal),
      payload: tareaId,
    );
  }
}
