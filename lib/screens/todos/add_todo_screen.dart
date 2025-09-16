import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/database_service.dart';
import '../../services/notification_service.dart';
import '../../models/todo_item.dart';

class AddTodoScreen extends StatefulWidget {
  final TodoItem? todoToEdit;
  final bool? isRealtime;

  const AddTodoScreen({
    super.key,
    this.todoToEdit,
    this.isRealtime,
  });

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedPriority = 'medium';
  String? _selectedCategory;
  bool _saveToRealtime = true;
  bool _saveToFirestore = true;
  bool _isLoading = false;

  final List<String> _priorities = ['high', 'medium', 'low'];
  final List<String> _categories = [
    'Pekerjaan',
    'Personal',
    'Belanja',
    'Kesehatan',
    'Belajar',
    'Hobi',
  ];

  @override
  void initState() {
    super.initState();
    
    if (widget.todoToEdit != null) {
      _titleController.text = widget.todoToEdit!.title;
      _descriptionController.text = widget.todoToEdit!.description;
      _selectedPriority = widget.todoToEdit!.priority;
      _selectedCategory = widget.todoToEdit!.category;
      
      // If editing, only save to the same database type
      if (widget.isRealtime != null) {
        _saveToRealtime = widget.isRealtime!;
        _saveToFirestore = !widget.isRealtime!;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.todoToEdit != null;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Todo' : 'Tambah Todo Baru',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          if (!isEditing)
            IconButton(
              onPressed: _clearForm,
              icon: const Icon(Icons.clear_all),
              tooltip: 'Bersihkan Form',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Card
              if (!isEditing) _buildInfoCard(),
              
              const SizedBox(height: 24),
              
              // Title Field
              _buildTitleField(),
              
              const SizedBox(height: 20),
              
              // Description Field
              _buildDescriptionField(),
              
              const SizedBox(height: 20),
              
              // Priority Section
              _buildPrioritySection(),
              
              const SizedBox(height: 20),
              
              // Category Section
              _buildCategorySection(),
              
              const SizedBox(height: 24),
              
              // Database Selection (only for new todos)
              if (!isEditing) _buildDatabaseSelection(),
              
              const SizedBox(height: 30),
              
              // Save Button
              _buildSaveButton(isEditing),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4ECDC4).withOpacity(0.1),
            const Color(0xFF44A08D).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4ECDC4).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4ECDC4).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.info_outline,
              color: Color(0xFF4ECDC4),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Database Demo',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  'Pilih database mana yang ingin Anda gunakan untuk menyimpan todo ini',
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
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: 'Judul Todo *',
        hintText: 'Masukkan judul todo',
        prefixIcon: const Icon(Icons.title),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF6B35)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Judul todo tidak boleh kosong';
        }
        if (value.trim().length < 3) {
          return 'Judul todo minimal 3 karakter';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      textCapitalization: TextCapitalization.sentences,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Deskripsi (Opsional)',
        hintText: 'Tambahkan deskripsi atau catatan untuk todo ini',
        prefixIcon: const Padding(
          padding: EdgeInsets.only(bottom: 60),
          child: Icon(Icons.description),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF6B35)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildPrioritySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag, color: Color(0xFFFF6B35), size: 20),
              const SizedBox(width: 8),
              Text(
                'Prioritas',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: _priorities.map((priority) {
              final isSelected = _selectedPriority == priority;
              final color = priority == 'high'
                  ? Colors.red
                  : priority == 'medium'
                      ? Colors.orange
                      : Colors.blue;
              
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPriority = priority;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withOpacity(0.1) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? color : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          priority == 'high'
                              ? Icons.keyboard_double_arrow_up
                              : priority == 'medium'
                                  ? Icons.remove
                                  : Icons.keyboard_double_arrow_down,
                          color: isSelected ? color : Colors.grey[600],
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          priority == 'high'
                              ? 'Tinggi'
                              : priority == 'medium'
                                  ? 'Sedang'
                                  : 'Rendah',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? color : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.category, color: Color(0xFFFF6B35), size: 20),
              const SizedBox(width: 8),
              Text(
                'Kategori (Opsional)',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // No Category Option
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _selectedCategory == null
                        ? const Color(0xFFFF6B35).withOpacity(0.1)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedCategory == null
                          ? const Color(0xFFFF6B35)
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    'Tidak ada',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: _selectedCategory == null ? FontWeight.w600 : FontWeight.w400,
                      color: _selectedCategory == null
                          ? const Color(0xFFFF6B35)
                          : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              // Category Options
              ..._categories.map((category) {
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFF6B35).withOpacity(0.1)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFFF6B35)
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: Text(
                      category,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? const Color(0xFFFF6B35)
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatabaseSelection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storage, color: Color(0xFFFF6B35), size: 20),
              const SizedBox(width: 8),
              Text(
                'Pilih Database',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Anda dapat menyimpan todo ke salah satu atau kedua database Firebase',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            title: Row(
              children: [
                const Icon(Icons.sync, color: Color(0xFFFFA726), size: 20),
                const SizedBox(width: 8),
                Text(
                  'Realtime Database',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            subtitle: Text(
              'Sinkronisasi data secara real-time',
              style: GoogleFonts.poppins(fontSize: 11),
            ),
            value: _saveToRealtime,
            onChanged: (value) {
              setState(() {
                _saveToRealtime = value ?? false;
              });
            },
            activeColor: const Color(0xFFFFA726),
            contentPadding: EdgeInsets.zero,
          ),
          CheckboxListTile(
            title: Row(
              children: [
                const Icon(Icons.cloud, color: Color(0xFF4FC3F7), size: 20),
                const SizedBox(width: 8),
                Text(
                  'Cloud Firestore',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            subtitle: Text(
              'Database dengan query yang powerful',
              style: GoogleFonts.poppins(fontSize: 11),
            ),
            value: _saveToFirestore,
            onChanged: (value) {
              setState(() {
                _saveToFirestore = value ?? false;
              });
            },
            activeColor: const Color(0xFF4FC3F7),
            contentPadding: EdgeInsets.zero,
          ),
          if (!_saveToRealtime && !_saveToFirestore)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Pilih minimal satu database',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.red[600],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(bool isEditing) {
    return SizedBox(
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _saveTodo,
        icon: _isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(isEditing ? Icons.save : Icons.add),
        label: Text(
          _isLoading
              ? 'Menyimpan...'
              : isEditing
                  ? 'Simpan Perubahan'
                  : 'Tambah Todo',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedPriority = 'medium';
      _selectedCategory = null;
      _saveToRealtime = true;
      _saveToFirestore = true;
    });
  }

  Future<void> _saveTodo() async {
    if (!_formKey.currentState!.validate()) return;

    final isEditing = widget.todoToEdit != null;
    
    // Validate database selection for new todos
    if (!isEditing && !_saveToRealtime && !_saveToFirestore) {
      NotificationService.showErrorNotification(
        context,
        'Pilih minimal satu database untuk menyimpan todo',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final todo = isEditing
          ? widget.todoToEdit!.copyWith(
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              priority: _selectedPriority,
              category: _selectedCategory,
            )
          : TodoItem(
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              priority: _selectedPriority,
              category: _selectedCategory,
            );

      if (isEditing) {
        // Update existing todo
        if (widget.isRealtime!) {
          await DatabaseService.updateTodoInRealtime(todo);
        } else {
          await DatabaseService.updateTodoInFirestore(todo);
        }
      } else {
        // Add new todo
        if (_saveToRealtime) {
          await DatabaseService.addTodoToRealtime(todo);
        }
        if (_saveToFirestore) {
          await DatabaseService.addTodoToFirestore(todo);
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        NotificationService.showErrorNotification(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
