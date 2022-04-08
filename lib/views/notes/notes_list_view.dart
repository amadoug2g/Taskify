import 'package:flutter/material.dart';
import 'package:taskify/constants/routes.dart';
import 'package:taskify/services/crud/notes_service.dart';

import '../../utilities/dialogs/delete_dialog.dart';

typedef NoteCallback = void Function(DatabaseNote note);
// typedef UpdateNoteCallback = void Function(DatabaseNote note);

class NotesListView extends StatelessWidget {
  final List<DatabaseNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onUpdateNote;

  const NotesListView({
    Key? key,
    required this.notes,
    required this.onDeleteNote,
    required this.onUpdateNote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final currentNote = notes[index];
          return ListTile(
            title: Text(
              currentNote.text,
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(currentNote.id.toString()),
            trailing: IconButton(
              onPressed: () async {
                final shouldDelete = await showDeleteDialog(context);
                if (shouldDelete) {
                  onDeleteNote(currentNote);
                }
              },
              icon: const Icon(Icons.delete),
            ),
            onTap: () {
              onUpdateNote(currentNote);
            },
          );
        });
  }
}
