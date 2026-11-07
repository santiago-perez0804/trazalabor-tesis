import 'tipo_evento.dart';

/// Cómo se muestra una labor en "Mis tareas de hoy" (pantalla B de la
/// Figura 5): Pendiente / En curso / Completada · sincronizada /
/// Completada · por enviar.
enum EstadoBandeja {
  pendiente('Pendiente'),
  enCurso('En curso'),
  completadaSincronizada('Completada · sincronizada'),
  completadaPorEnviar('Completada · por enviar'),
  noCompletadaSincronizada('No completada · sincronizada'),
  noCompletadaPorEnviar('No completada · por enviar'),
  verificada('Verificada');

  const EstadoBandeja(this.etiqueta);
  final String etiqueta;

  bool get cerrada => this != pendiente && this != enCurso;
  bool get porEnviar =>
      this == completadaPorEnviar || this == noCompletadaPorEnviar;
}

/// [porEnviar]: quedan operaciones de la labor sin confirmar por el servidor.
EstadoBandeja estadoBandeja(EstadoTarea estado, {required bool porEnviar}) =>
    switch (estado) {
      EstadoTarea.creada || EstadoTarea.asignada => EstadoBandeja.pendiente,
      EstadoTarea.iniciada => EstadoBandeja.enCurso,
      EstadoTarea.completada =>
        porEnviar
            ? EstadoBandeja.completadaPorEnviar
            : EstadoBandeja.completadaSincronizada,
      EstadoTarea.noCompletada =>
        porEnviar
            ? EstadoBandeja.noCompletadaPorEnviar
            : EstadoBandeja.noCompletadaSincronizada,
      EstadoTarea.verificada => EstadoBandeja.verificada,
    };

/// Solo una labor asignada o en curso admite eventos de ejecución.
bool admiteEjecucion(EstadoTarea estado) =>
    estado == EstadoTarea.asignada || estado == EstadoTarea.iniciada;
