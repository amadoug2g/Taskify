import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskify/services/cloud/cloud_note.dart';
import 'package:taskify/services/cloud/cloud_storage_constants.dart';
import 'package:taskify/services/cloud/cloud_storage_exception.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      await notes.doc(documentId).update({
        textFieldName: text,
      });
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Future<void> deleteNote({
    required String documentId,
  }) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
      notes.snapshots().map((event) => event.docs
          .map((doc) => CloudNote.fromSnapshot(doc))
          .where((note) => note.ownerUserId == ownerUserId));

  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try {
      return await notes
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          .then(
            (value) => value.docs.map(
              (doc) => CloudNote.fromSnapshot(doc),
            ),
          );
    } catch (e) {
      throw CouldNotGetAllNoteException();
    }
  }

  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    final result = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
    final snapshot = await result.get();
    return CloudNote(
      documentId: snapshot.id,
      ownerUserId: ownerUserId,
      text: '',
    );
  }

//#region Singleton Structure

  //1. creating Private Constructor
  FirebaseCloudStorage._sharedInstance();

  //2. creating Factory Constructor (default Constructor for the class) talking to static final field
  factory FirebaseCloudStorage() => _shared;

  //3. calls Private Initializer talking with the Private Constructor from 1.
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
//#endregion
}
