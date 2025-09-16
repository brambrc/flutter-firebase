import 'package:uuid/uuid.dart';

class TodoItem {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String priority; // 'low', 'medium', 'high'
  final String? category;

  TodoItem({
    String? id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    DateTime? createdAt,
    this.completedAt,
    this.priority = 'medium',
    this.category,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now();

  // Copy with method
  TodoItem copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    String? priority,
    String? category,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      priority: priority ?? this.priority,
      category: category ?? this.category,
    );
  }

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'priority': priority,
      'category': category,
    };
  }

  // Create from Map from Firebase
  factory TodoItem.fromMap(Map<String, dynamic> map) {
    return TodoItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      completedAt: map['completedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'])
          : null,
      priority: map['priority'] ?? 'medium',
      category: map['category'],
    );
  }

  // Get priority color
  String getPriorityColor() {
    switch (priority) {
      case 'high':
        return '#FF6B35'; // Orange-red
      case 'medium':
        return '#4ECDC4'; // Teal
      case 'low':
        return '#45B7D1'; // Blue
      default:
        return '#95A5A6'; // Gray
    }
  }

  // Get priority text
  String getPriorityText() {
    switch (priority) {
      case 'high':
        return 'Tinggi';
      case 'medium':
        return 'Sedang';
      case 'low':
        return 'Rendah';
      default:
        return 'Sedang';
    }
  }

  // Get formatted created date
  String getFormattedCreatedDate() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} menit yang lalu';
      } else {
        return '${difference.inHours} jam yang lalu';
      }
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  // Get formatted completed date
  String? getFormattedCompletedDate() {
    if (completedAt == null) return null;
    
    final now = DateTime.now();
    final difference = now.difference(completedAt!);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Diselesaikan ${difference.inMinutes} menit yang lalu';
      } else {
        return 'Diselesaikan ${difference.inHours} jam yang lalu';
      }
    } else if (difference.inDays == 1) {
      return 'Diselesaikan kemarin';
    } else {
      return 'Diselesaikan ${completedAt!.day}/${completedAt!.month}/${completedAt!.year}';
    }
  }

  @override
  String toString() {
    return 'TodoItem(id: $id, title: $title, description: $description, isCompleted: $isCompleted, createdAt: $createdAt, completedAt: $completedAt, priority: $priority, category: $category)';
  }

  @override
  bool operator ==(covariant TodoItem other) {
    if (identical(this, other)) return true;
  
    return other.id == id &&
        other.title == title &&
        other.description == description &&
        other.isCompleted == isCompleted &&
        other.createdAt == createdAt &&
        other.completedAt == completedAt &&
        other.priority == priority &&
        other.category == category;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        isCompleted.hashCode ^
        createdAt.hashCode ^
        completedAt.hashCode ^
        priority.hashCode ^
        category.hashCode;
  }
}
