// Poikile Theme — Dart / Flutter Test File
//
// Scopes to verify:
//   keyword.control.dart          → #c2788e  (if, else, for, while, switch, return, yield)
//   keyword.declaration.dart      → #c2788e  (class, enum, extension, mixin, abstract, implements, extends, with)
//   storage.type.dart             → #c2788e  (var, final, const, late, dynamic, void)
//   entity.name.function.dart     → #d4a55c  (function names)
//   entity.name.type.class.dart   → #7db89e  (class names)
//   support.class.dart            → #7db89e  (Widget, State, BuildContext, etc.)
//   support.type.dart             → #7db89e  (int, double, String, bool, List, Map, Set, Future, Stream)
//   variable.language.dart        → #c2788e  italic (this, super)
//   string.interpolated.dart      → #a3b87c  (string interpolation)
//   constant.language.dart        → #c9905a  (true, false, null)
//   punctuation.definition.annotation.dart → #b09cc5 italic (@override, @required)
//   keyword.operator.dart         → #9b9baa  (operators)
//   keyword.operator.cascade.dart → #9b9baa  (..)
//   comment                       → #8a8784  italic

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Represents the loading state of an async operation.
enum LoadingState {
  idle,
  loading,
  success,
  error,
}

/// A result type that holds either a value or an error.
class Result<T> {
  final T? _value;
  final Exception? _error;
  final bool isSuccess;

  const Result.success(T value)
      : _value = value,
        _error = null,
        isSuccess = true;

  const Result.failure(Exception error)
      : _value = null,
        _error = error,
        isSuccess = false;

  T get value {
    if (!isSuccess) throw StateError('Cannot access value of a failed result');
    return _value as T;
  }

  Exception get error {
    if (isSuccess) throw StateError('Cannot access error of a successful result');
    return _error!;
  }

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Exception error) onFailure,
  }) {
    if (isSuccess) {
      return onSuccess(_value as T);
    } else {
      return onFailure(_error!);
    }
  }
}

/// Mixin for providing a unique identifier.
mixin Identifiable {
  String get id;
}

/// Extension on List to add convenience methods.
extension ListExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  List<T> sortedBy<K extends Comparable<K>>(K Function(T) keyOf) {
    return [...this]..sort((a, b) => keyOf(a).compareTo(keyOf(b)));
  }
}

/// Abstract repository interface.
abstract class Repository<T extends Identifiable> {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<void> save(T item);
  Future<void> delete(String id);
}

/// Represents a task in a to-do application.
class Task with Identifiable {
  @override
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime createdAt;
  final List<String> tags;

  const Task({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    required this.createdAt,
    this.tags = const [],
  });

  Task copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    List<String>? tags,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'is_completed': isCompleted,
        'created_at': createdAt.toIso8601String(),
        'tags': tags,
      };

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  @override
  String toString() => 'Task($id, "$title", completed: $isCompleted)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Task && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

/// In-memory repository implementation.
class InMemoryTaskRepository implements Repository<Task> {
  final Map<String, Task> _store = {};

  @override
  Future<List<Task>> getAll() async => _store.values.toList();

  @override
  Future<Task?> getById(String id) async => _store[id];

  @override
  Future<void> save(Task item) async {
    _store[item.id] = item;
  }

  @override
  Future<void> delete(String id) async {
    _store.remove(id);
  }
}

/// A ChangeNotifier-based view model for task management.
class TaskViewModel extends ChangeNotifier {
  final Repository<Task> _repository;
  List<Task> _tasks = [];
  LoadingState _state = LoadingState.idle;
  String? _errorMessage;

  TaskViewModel(this._repository);

  List<Task> get tasks => List.unmodifiable(_tasks);
  List<Task> get completedTasks => _tasks.where((t) => t.isCompleted).toList();
  List<Task> get pendingTasks => _tasks.where((t) => !t.isCompleted).toList();
  LoadingState get state => _state;
  String? get errorMessage => _errorMessage;
  int get completionPercentage {
    if (_tasks.isEmpty) return 0;
    return (completedTasks.length / _tasks.length * 100).round();
  }

  Future<void> loadTasks() async {
    _state = LoadingState.loading;
    notifyListeners();

    try {
      _tasks = await _repository.getAll();
      _state = LoadingState.success;
    } on Exception catch (e) {
      _errorMessage = 'Failed to load tasks: $e';
      _state = LoadingState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> toggleTask(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;

    final task = _tasks[index];
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    await _repository.save(updated);
    _tasks[index] = updated;
    notifyListeners();
  }

  Future<void> addTask(String title, {String? description, List<String>? tags}) async {
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      tags: tags ?? [],
    );
    await _repository.save(task);
    _tasks.add(task);
    notifyListeners();
  }
}

/// Flutter widget tree for the task list screen.
class TaskListScreen extends StatefulWidget {
  final TaskViewModel viewModel;

  const TaskListScreen({super.key, required this.viewModel});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    widget.viewModel.loadTasks();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => widget.viewModel.loadTasks(),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.viewModel,
        builder: (context, child) {
          final vm = widget.viewModel;

          switch (vm.state) {
            case LoadingState.idle:
            case LoadingState.loading:
              return const Center(child: CircularProgressIndicator());
            case LoadingState.error:
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
                    const SizedBox(height: 16),
                    Text(vm.errorMessage ?? 'Unknown error'),
                  ],
                ),
              );
            case LoadingState.success:
              return _buildTaskList(vm);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList(TaskViewModel vm) {
    if (vm.tasks.isEmpty) {
      return const Center(child: Text('No tasks yet. Add one!'));
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: vm.tasks.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final task = vm.tasks[index];
          return ListTile(
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (_) => vm.toggleTask(task.id),
            ),
            title: Text(
              task.title,
              style: TextStyle(
                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                fontSize: 16.0,
              ),
            ),
            subtitle: task.description != null ? Text(task.description!) : null,
            trailing: task.tags.isNotEmpty
                ? Wrap(
                    spacing: 4,
                    children: task.tags
                        .map((t) => Chip(label: Text(t, style: const TextStyle(fontSize: 10))))
                        .toList(),
                  )
                : null,
          );
        },
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Task'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Task title'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await widget.viewModel.addTask(result);
    }
  }
}

// Async generators, cascade notation, and numeric literals
Future<void> processStream() async {
  final random = math.Random();
  final items = List.generate(100, (i) => i * 2);
  final buffer = StringBuffer()
    ..write('Start: ')
    ..writeAll(items.take(5), ', ')
    ..writeln(' ...');

  print(buffer.toString());

  await for (final value in Stream.periodic(
    const Duration(milliseconds: 100),
    (i) => i,
  ).take(10)) {
    final noise = random.nextDouble() * 0.5;
    final result = value + noise;
    print('Stream value: ${result.toStringAsFixed(2)}');
  }

  // Numeric edge cases
  const bigInt = 9007199254740992;
  const hex = 0xDEADBEEF;
  const sci = 1.5e10;
  const negative = -42;
  assert(bigInt > hex);
  assert(sci > negative.toDouble());
}

void main() async {
  final repo = InMemoryTaskRepository();
  final vm = TaskViewModel(repo);
  await vm.addTask('Buy groceries', tags: ['personal', 'urgent']);
  await vm.addTask('Write tests', description: 'Cover all edge cases');
  await vm.loadTasks();
  print('Tasks: ${vm.tasks.length}, completed: ${vm.completionPercentage}%');
  await processStream();
}
