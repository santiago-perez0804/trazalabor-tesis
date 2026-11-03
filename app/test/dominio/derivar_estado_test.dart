import 'package:flutter_test/flutter_test.dart';
import 'package:trazalabor/dominio/derivar_estado.dart';
import 'package:trazalabor/dominio/tipo_evento.dart';

void main() {
  final base = DateTime.utc(2026, 10, 20, 10);
  EventoDominio ev(TipoEvento tipo, int minuto,
          [Map<String, dynamic> payload = const {}]) =>
      EventoDominio(
        tipo: tipo,
        creadoEnDispositivo: base.add(Duration(minutes: minuto)),
        payload: payload,
      );

  group('derivarEstado', () {
    test('sin eventos la tarea figura como CREADA', () {
      expect(derivarEstado(const []), EstadoTarea.creada);
    });

    test('recorre el ciclo completo hasta VERIFICADA', () {
      final eventos = [
        ev(TipoEvento.creada, 0),
        ev(TipoEvento.asignada, 0),
      ];
      expect(derivarEstado(eventos), EstadoTarea.asignada);

      eventos.add(ev(TipoEvento.iniciada, 5));
      expect(derivarEstado(eventos), EstadoTarea.iniciada);

      eventos.add(ev(TipoEvento.completada, 40));
      expect(derivarEstado(eventos), EstadoTarea.completada);

      eventos.add(ev(TipoEvento.verificada, 90));
      expect(derivarEstado(eventos), EstadoTarea.verificada);
    });

    test('los eventos de ejecución no cambian el estado', () {
      final eventos = [
        ev(TipoEvento.creada, 0),
        ev(TipoEvento.asignada, 0),
        ev(TipoEvento.iniciada, 5),
        ev(TipoEvento.qrVerificado, 7),
        ev(TipoEvento.itemCompletado, 10),
        ev(TipoEvento.evidenciaAdjunta, 12),
      ];
      expect(derivarEstado(eventos), EstadoTarea.iniciada);
    });

    test('NO_COMPLETADA seguida de REASIGNADA vuelve a ASIGNADA', () {
      final eventos = [
        ev(TipoEvento.creada, 0),
        ev(TipoEvento.asignada, 0),
        ev(TipoEvento.iniciada, 5),
        ev(TipoEvento.noCompletada, 30),
      ];
      expect(derivarEstado(eventos), EstadoTarea.noCompletada);

      eventos.add(ev(TipoEvento.reasignada, 60));
      expect(derivarEstado(eventos), EstadoTarea.asignada);
    });

    test('a igual hora desempata por etapa: ASIGNADA gana a CREADA', () {
      final eventos = [
        ev(TipoEvento.asignada, 0),
        ev(TipoEvento.creada, 0),
      ];
      expect(derivarEstado(eventos), EstadoTarea.asignada);
    });

    test('ordena por la hora del dispositivo aunque lleguen desordenados', () {
      final eventos = [
        ev(TipoEvento.completada, 40),
        ev(TipoEvento.creada, 0),
        ev(TipoEvento.iniciada, 5),
        ev(TipoEvento.asignada, 1),
      ];
      expect(derivarEstado(eventos), EstadoTarea.completada);
    });
  });

  group('eventosDelCicloVigente', () {
    test('sin reasignación devuelve todos los eventos', () {
      final eventos = [
        ev(TipoEvento.creada, 0),
        ev(TipoEvento.itemCompletado, 10),
      ];
      expect(eventosDelCicloVigente(eventos), hasLength(2));
    });

    test('descarta lo anterior al último REASIGNADA', () {
      final eventos = [
        ev(TipoEvento.creada, 0),
        ev(TipoEvento.itemCompletado, 10, {'item_id': 'a', 'valor': '1'}),
        ev(TipoEvento.reasignada, 20),
        ev(TipoEvento.itemCompletado, 30, {'item_id': 'b', 'valor': '2'}),
      ];
      final vigentes = eventosDelCicloVigente(eventos);
      expect(vigentes, hasLength(1));
      expect(vigentes.single.payload['item_id'], 'b');
    });
  });
}
