import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/database_service.dart';
import '../../services/notification_service.dart';
import '../../models/todo_item.dart';
import 'add_todo_screen.dart';

class TodosScreen extends StatefulWidget {
  const TodosScreen({super.key});

  @override
  State<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends State<TodosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showCompleted = true;
  String _selectedPriority = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Manajemen Todos',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          indicatorColor: Colors.white,
          tabs: const [
            Tab(
              icon: Icon(Icons.sync),
              text: 'Realtime DB',
            ),
            Tab(
              icon: Icon(Icons.cloud),
              text: 'Firestore',
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'filter':
                  _showFilterDialog();
                  break;
                case 'clear_completed':
                  _clearCompletedTodos();
                  break;
                case 'test_notification':
                  NotificationService.sendTestNotification();
                  NotificationService.showSuccessNotification(
                    context,
                    'Test notification sent! 🔔',
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'filter',
                child: Row(
                  children: [
                    const Icon(Icons.filter_list),
                    const SizedBox(width: 8),
                    Text('Filter', style: GoogleFonts.poppins()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear_completed',
                child: Row(
                  children: [
                    const Icon(Icons.clear_all),
                    const SizedBox(width: 8),
                    Text('Hapus Selesai', style: GoogleFonts.poppins()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'test_notification',
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active),
                    const SizedBox(width: 8),
                    Text('Test Notifikasi', style: GoogleFonts.poppins()),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRealtimeDbTab(),
          _buildFirestoreTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewTodo,
        backgroundColor: const Color(0xFFFF6B35),
        label: Text(
          'Tambah Todo',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
          ),
        ),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRealtimeDbTab() {
    return Column(
      children: [
        // Info Card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFA726).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFFA726).withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.sync,
                color: const Color(0xFFFFA726),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Firebase Realtime Database',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      'Data tersinkronisasi secara real-time dalam format JSON',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: StreamBuilder<List<TodoItem>>(
            stream: DatabaseService.getRealtimeTodosStream(),
            builder: (context, snapshot) {
              return _buildTodosList(snapshot, isRealtime: true);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFirestoreTab() {
    return Column(
      children: [
        // Info Card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF4FC3F7).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF4FC3F7).withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.cloud,
                color: const Color(0xFF4FC3F7),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cloud Firestore',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      'NoSQL database dengan query yang powerful dan struktur dokumen/koleksi',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: StreamBuilder<List<TodoItem>>(
            stream: DatabaseService.getFirestoreTodosStream(),
            builder: (context, snapshot) {
              return _buildTodosList(snapshot, isRealtime: false);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTodosList(AsyncSnapshot<List<TodoItem>> snapshot, {required bool isRealtime}) {
    if (snapshot.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${snapshot.error}',
              style: GoogleFonts.poppins(
                color: Colors.red[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat todos...'),
          ],
        ),
      );
    }

    List<TodoItem> todos = snapshot.data ?? [];
    
    // Apply filters
    todos = _applyFilters(todos);

    if (todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Todos',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan todo pertama Anda dengan menekan tombol +',
              style: GoogleFonts.poppins(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return _buildTodoCard(todo, isRealtime: isRealtime);
      },
    );
  }

  Widget _buildTodoCard(TodoItem todo, {required bool isRealtime}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: Color(int.parse('0xFF${todo.getPriorityColor().substring(1)}')),
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _editTodo(todo, isRealtime: isRealtime),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Completion Checkbox
                    GestureDetector(
                      onTap: () => _toggleTodoCompletion(todo, isRealtime: isRealtime),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: todo.isCompleted ? Colors.green : Colors.transparent,
                          border: todo.isCompleted ? null : Border.all(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: todo.isCompleted
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Title
                    Expanded(
                      child: Text(
                        todo.title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: todo.isCompleted ? Colors.grey[500] : Colors.grey[800],
                          decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    // Priority Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(int.parse('0xFF${todo.getPriorityColor().substring(1)}')).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        todo.getPriorityText(),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(int.parse('0xFF${todo.getPriorityColor().substring(1)}')),
                        ),
                      ),
                    ),
                    
                    // More Options
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            _editTodo(todo, isRealtime: isRealtime);
                            break;
                          case 'delete':
                            _deleteTodo(todo, isRealtime: isRealtime);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(Icons.edit, size: 16),
                              const SizedBox(width: 8),
                              Text('Edit', style: GoogleFonts.poppins()),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete, size: 16, color: Colors.red),
                              const SizedBox(width: 8),
                              Text('Hapus', style: GoogleFonts.poppins(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      child: const Icon(
                        Icons.more_vert,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                
                if (todo.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    todo.description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: todo.isCompleted ? Colors.grey[400] : Colors.grey[600],
                      decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                const SizedBox(height: 12),
                
                // Footer
                Row(
                  children: [
                    Icon(
                      isRealtime ? Icons.sync : Icons.cloud,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isRealtime ? 'Realtime DB' : 'Firestore',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      todo.getFormattedCreatedDate(),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                
                if (todo.isCompleted && todo.getFormattedCompletedDate() != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Spacer(),
                      Text(
                        todo.getFormattedCompletedDate()!,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.green[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<TodoItem> _applyFilters(List<TodoItem> todos) {
    List<TodoItem> filtered = todos;

    // Filter by completion status
    if (!_showCompleted) {
      filtered = filtered.where((todo) => !todo.isCompleted).toList();
    }

    // Filter by priority
    if (_selectedPriority != 'all') {
      filtered = filtered.where((todo) => todo.priority == _selectedPriority).toList();
    }

    return filtered;
  }

  Future<void> _addNewTodo() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTodoScreen(),
      ),
    );

    if (result == true) {
      NotificationService.showSuccessNotification(
        context,
        'Todo berhasil ditambahkan! ✅',
      );
    }
  }

  Future<void> _editTodo(TodoItem todo, {required bool isRealtime}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTodoScreen(todoToEdit: todo, isRealtime: isRealtime),
      ),
    );

    if (result == true) {
      NotificationService.showSuccessNotification(
        context,
        'Todo berhasil diperbarui! ✏️',
      );
    }
  }

  Future<void> _toggleTodoCompletion(TodoItem todo, {required bool isRealtime}) async {
    try {
      final updatedTodo = todo.copyWith(
        isCompleted: !todo.isCompleted,
        completedAt: !todo.isCompleted ? DateTime.now() : null,
      );

      if (isRealtime) {
        await DatabaseService.updateTodoInRealtime(updatedTodo);
      } else {
        await DatabaseService.updateTodoInFirestore(updatedTodo);
      }

      if (updatedTodo.isCompleted) {
        await NotificationService.showTodoCompletedNotification(todo.title);
      }
    } catch (e) {
      if (mounted) {
        NotificationService.showErrorNotification(context, e.toString());
      }
    }
  }

  Future<void> _deleteTodo(TodoItem todo, {required bool isRealtime}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hapus Todo',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus todo "${todo.title}"?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Hapus',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        if (isRealtime) {
          await DatabaseService.deleteTodoFromRealtime(todo.id);
        } else {
          await DatabaseService.deleteTodoFromFirestore(todo.id);
        }

        if (mounted) {
          NotificationService.showSuccessNotification(
            context,
            'Todo berhasil dihapus! 🗑️',
          );
        }
      } catch (e) {
        if (mounted) {
          NotificationService.showErrorNotification(context, e.toString());
        }
      }
    }
  }

  Future<void> _clearCompletedTodos() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hapus Semua Todo Selesai',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus semua todo yang sudah selesai?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Hapus Semua',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DatabaseService.deleteAllCompletedTodos();
        if (mounted) {
          NotificationService.showSuccessNotification(
            context,
            'Semua todo selesai berhasil dihapus! 🧹',
          );
        }
      } catch (e) {
        if (mounted) {
          NotificationService.showErrorNotification(context, e.toString());
        }
      }
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Filter Todos',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              title: Text(
                'Tampilkan yang selesai',
                style: GoogleFonts.poppins(),
              ),
              value: _showCompleted,
              onChanged: (value) {
                setState(() {
                  _showCompleted = value ?? true;
                });
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Prioritas:',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            ...['all', 'high', 'medium', 'low'].map((priority) => RadioListTile<String>(
              title: Text(
                priority == 'all' ? 'Semua' : 
                priority == 'high' ? 'Tinggi' :
                priority == 'medium' ? 'Sedang' : 'Rendah',
                style: GoogleFonts.poppins(),
              ),
              value: priority,
              groupValue: _selectedPriority,
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value ?? 'all';
                });
                Navigator.pop(context);
              },
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tutup',
              style: GoogleFonts.poppins(
                color: const Color(0xFFFF6B35),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
