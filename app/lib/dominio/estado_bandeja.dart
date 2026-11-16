import 'tipo_evento.dart';

/// Cómo se muestra una labor en "Tareas de hoy" (pantalla B de la
/// Figura 5), con palabras llanas: Por hacer / Empezada / Terminada ·
/// enviada / Terminada · se envía con señal.
enum EstadoBandeja {
  pendiente('Por hacer · tocá para empezar'),
  enCurso('Empezada'),
  completadaSincronizada('Terminada · enviada'),
  completadaPorEnviar('Terminada · se envía con señal'),
  noCompletadaSincronizada('No terminada · enviada'),
  noCompletadaPorEnviar('No terminada · se envía con señal'),
  verificada('Revisada por el encargado');

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
