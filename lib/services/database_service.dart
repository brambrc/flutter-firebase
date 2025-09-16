import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/todo_item.dart';

class DatabaseService {
  static final FirebaseDatabase _realtimeDatabase = FirebaseDatabase.instance;
  static final firestore.FirebaseFirestore _firestore = firestore.FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  static String? get _userId => _auth.currentUser?.uid;

  // ========== REALTIME DATABASE OPERATIONS ==========
  
  // Get reference to user's todos in Realtime Database
  static DatabaseReference get _realtimeTodosRef {
    return _realtimeDatabase.ref().child('todos').child(_userId!);
  }

  // Add todo to Realtime Database
  static Future<void> addTodoToRealtime(TodoItem todo) async {
    if (_userId == null) throw 'User not authenticated';
    
    try {
      await _realtimeTodosRef.child(todo.id).set(todo.toMap());
    } catch (e) {
      throw 'Gagal menambahkan todo ke Realtime Database: $e';
    }
  }

  // Update todo in Realtime Database
  static Future<void> updateTodoInRealtime(TodoItem todo) async {
    if (_userId == null) throw 'User not authenticated';
    
    try {
      await _realtimeTodosRef.child(todo.id).update(todo.toMap());
    } catch (e) {
      throw 'Gagal memperbarui todo di Realtime Database: $e';
    }
  }

  // Delete todo from Realtime Database
  static Future<void> deleteTodoFromRealtime(String todoId) async {
    if (_userId == null) throw 'User not authenticated';
    
    try {
      await _realtimeTodosRef.child(todoId).remove();
    } catch (e) {
      throw 'Gagal menghapus todo dari Realtime Database: $e';
    }
  }

  // Get todos stream from Realtime Database
  static Stream<List<TodoItem>> getRealtimeTodosStream() {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _realtimeTodosRef.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return <TodoItem>[];
      
      try {
        final Map<dynamic, dynamic> todosMap = data as Map<dynamic, dynamic>;
        return todosMap.values
            .map((todoData) => TodoItem.fromMap(Map<String, dynamic>.from(todoData)))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } catch (e) {
        print('Error parsing realtime todos: $e');
        return <TodoItem>[];
      }
    });
  }

  // ========== FIRESTORE OPERATIONS ==========
  
  // Get reference to user's todos collection in Firestore
  static firestore.CollectionReference get _firestoreTodosRef {
    return _firestore.collection('users').doc(_userId!).collection('todos');
  }

  // Add todo to Firestore
  static Future<void> addTodoToFirestore(TodoItem todo) async {
    if (_userId == null) throw 'User not authenticated';
    
    try {
      await _firestoreTodosRef.doc(todo.id).set(todo.toMap());
    } catch (e) {
      throw 'Gagal menambahkan todo ke Firestore: $e';
    }
  }

  // Update todo in Firestore
  static Future<void> updateTodoInFirestore(TodoItem todo) async {
    if (_userId == null) throw 'User not authenticated';
    
    try {
      await _firestoreTodosRef.doc(todo.id).update(todo.toMap());
    } catch (e) {
      throw 'Gagal memperbarui todo di Firestore: $e';
    }
  }

  // Delete todo from Firestore
  static Future<void> deleteTodoFromFirestore(String todoId) async {
    if (_userId == null) throw 'User not authenticated';
    
    try {
      await _firestoreTodosRef.doc(todoId).delete();
    } catch (e) {
      throw 'Gagal menghapus todo dari Firestore: $e';
    }
  }

  // Get todos stream from Firestore
  static Stream<List<TodoItem>> getFirestoreTodosStream() {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _firestoreTodosRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TodoItem.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Get todos with pagination from Firestore
  static Future<List<TodoItem>> getFirestoreTodosPaginated({
    int limit = 10,
    firestore.DocumentSnapshot? lastDocument,
  }) async {
    if (_userId == null) throw 'User not authenticated';
    
    try {
      firestore.Query query = _firestoreTodosRef
          .orderBy('createdAt', descending: true)
          .limit(limit);
      
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }
      
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => TodoItem.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw 'Gagal mendapatkan todos dengan paginasi: $e';
    }
  }

  // ========== USER PROFILE OPERATIONS ==========
  
  // Save user profile to Firestore
  static Future<void> saveUserProfile({
    required String name,
    required String email,
    String? photoUrl,
  }) async {
    if (_userId == null) throw 'User not authenticated';
    
    try {
      await _firestore.collection('users').doc(_userId!).set({
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'createdAt': firestore.FieldValue.serverTimestamp(),
        'lastUpdated': firestore.FieldValue.serverTimestamp(),
      }, firestore.SetOptions(merge: true));
    } catch (e) {
      throw 'Gagal menyimpan profil pengguna: $e';
    }
  }

  // Get user profile from Firestore
  static Future<Map<String, dynamic>?> getUserProfile() async {
    if (_userId == null) throw 'User not authenticated';
    
    try {
      final doc = await _firestore.collection('users').doc(_userId!).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      throw 'Gagal mendapatkan profil pengguna: $e';
    }
  }

  // ========== STATISTICS ==========
  
  // Get todo statistics
  static Future<Map<String, int>> getTodoStats() async {
    if (_userId == null) throw 'User not authenticated';
    
    try {
      final snapshot = await _firestoreTodosRef.get();
      int total = snapshot.docs.length;
      int completed = 0;
      int pending = 0;
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['isCompleted'] == true) {
          completed++;
        } else {
          pending++;
        }
      }
      
      return {
        'total': total,
        'completed': completed,
        'pending': pending,
      };
    } catch (e) {
      throw 'Gagal mendapatkan statistik todo: $e';
    }
  }

  // ========== BATCH OPERATIONS ==========
  
  // Delete all completed todos
  static Future<void> deleteAllCompletedTodos() async {
    if (_userId == null) throw 'User not authenticated';
    
    try {
      final batch = _firestore.batch();
      final snapshot = await _firestoreTodosRef
          .where('isCompleted', isEqualTo: true)
          .get();
      
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      
      // Also delete from Realtime Database
      final realtimeSnapshot = await _realtimeTodosRef.get();
      if (realtimeSnapshot.exists) {
        final data = realtimeSnapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          final updates = <String, dynamic>{};
          data.forEach((key, value) {
            if (value['isCompleted'] == true) {
              updates['$key'] = null;
            }
          });
          if (updates.isNotEmpty) {
            await _realtimeTodosRef.update(updates);
          }
        }
      }
    } catch (e) {
      throw 'Gagal menghapus semua todo yang selesai: $e';
    }
  }
}
