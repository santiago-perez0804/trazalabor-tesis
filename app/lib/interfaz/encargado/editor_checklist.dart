import 'package:flutter/material.dart';

import '../../dominio/catalogos.dart';
import '../../dominio/plantillas_labor.dart';
import '../tema.dart';

/// Ítem de la lista mientras se edita en pantalla.
class ItemEditable {
  ItemEditable.desde(ItemBorrador item)
    : texto = TextEditingController(text: item.descripcion),
      tipo = item.tipoRespuesta,
      obligatorio = item.obligatorio,
      fijo = item.fijo;

  final TextEditingController texto;
  TipoRespuesta tipo;
  bool obligatorio;
  final bool fijo;

  ItemBorrador aBorrador() => ItemBorrador(
    descripcion: texto.text,
    tipoRespuesta: tipo,
    obligatorio: obligatorio,
    fijo: fijo,
  );

  void dispose() => texto.dispose();
}

/// Editor de la lista de verificación (T-14): agregar, quitar y configurar
/// ítems. Los ítems fijos de la plantilla se muestran con candado.
class EditorChecklist extends StatelessWidget {
  const EditorChecklist({
    super.key,
    required this.items,
    required this.onCambio,
    required this.onAgregar,
    required this.onQuitar,
  });

  final List<ItemEditable> items;
  final VoidCallback onCambio;
  final VoidCallback onAgregar;
  final void Function(int indice) onQuitar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, item) in items.indexed)
          Card(
            key: ObjectKey(item),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 4, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          key: ValueKey('item-$i'),
                          controller: item.texto,
                          readOnly: item.fijo,
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                          style: const TextStyle(fontSize: 17),
                          decoration: InputDecoration(
                            labelText: 'Ítem ${i + 1}',
                            prefixIcon: item.fijo
                                ? const Tooltip(
                                    message:
                                        'Obligatorio para este tipo de labor',
                                    child: Icon(Icons.lock_outline),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      if (!item.fijo)
                        IconButton(
                          tooltip: 'Quitar ítem',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => onQuitar(i),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Ítem fijo: se informa cómo se responde, sin controles grises.
                  if (item.fijo)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 8, 10),
                      child: Text(
                        'Respuesta: ${item.tipo.etiqueta} · Obligatorio',
                        style: const TextStyle(
                          fontSize: 16,
                          color: ColoresTrazaLabor.textoSecundario,
                        ),
                      ),
                    )
                  else ...[
                    Wrap(
                      spacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        for (final t in TipoRespuesta.values)
                          ChoiceChip(
                            label: Text(t.etiqueta),
                            selected: item.tipo == t,
                            onSelected: item.fijo
                                ? null
                                : (_) {
                                    item.tipo = t;
                                    onCambio();
                                  },
                          ),
                      ],
                    ),
                    SwitchListTile(
                      contentPadding: const EdgeInsets.only(right: 8),
                      title: const Text('Obligatorio'),
                      value: item.obligatorio,
                      onChanged: (v) {
                        item.obligatorio = v;
                        onCambio();
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          key: const ValueKey('agregar-item'),
          onPressed: onAgregar,
          icon: const Icon(Icons.add),
          label: const Text('Agregar ítem'),
        ),
        if (items.any((i) => i.fijo))
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Los ítems con candado son obligatorios para este tipo de labor.',
              style: TextStyle(
                fontSize: 15,
                color: ColoresTrazaLabor.textoSecundario,
              ),
            ),
          ),
      ],
    );
  }
}
