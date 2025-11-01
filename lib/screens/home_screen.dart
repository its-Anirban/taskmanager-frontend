import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/providers/auth_provider.dart';
import 'package:task_manager_app/providers/task_provider.dart';
import 'package:task_manager_app/providers/theme_provider.dart';
import 'package:task_manager_app/screens/login_screen.dart';
import 'package:task_manager_app/widgets/add_task_dialog.dart';
import 'package:task_manager_app/widgets/task_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TaskProvider _taskProvider;

  @override
  void initState() {
    super.initState();
    _taskProvider = Provider.of<TaskProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _taskProvider.loadTasks();
    });
  }

  void _openAdd() {
    showDialog(
      context: context,
      builder: (_) => AddTaskDialog(
        onDone: (title, desc) async {
          try {
            await _taskProvider.addTask(title, desc);
            Fluttertoast.showToast(msg: 'Task added');
          } catch (e) {
            Fluttertoast.showToast(msg: 'Add failed: $e');
          }
        },
      ),
    );
  }

  Future<void> _deleteTask(int id) async {
    try {
      await _taskProvider.deleteTask(id);
      Fluttertoast.showToast(msg: 'Deleted');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Delete failed: $e');
    }
  }

  Future<void> _logout() async {
    await Provider.of<AuthProvider>(context, listen: false).logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer2<TaskProvider, ThemeProvider>(
      builder: (context, tp, themeProvider, _) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text(
              'My Tasks',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            elevation: 2,
            actions: [
              IconButton(
                tooltip:
                    themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
                icon: Icon(
                  themeProvider.isDarkMode
                      ? Icons.wb_sunny_outlined
                      : Icons.nightlight_round,
                ),
                onPressed: themeProvider.toggleTheme,
              ),
              IconButton(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
              ),
            ],
          ),
          body: tp.loading
              ? const Center(child: CircularProgressIndicator())
              : tp.tasks.isEmpty
                  ? Center(
                      child: Text(
                        'No tasks yet.\nTap “Add Task” to create one.',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async => tp.loadTasks(),
                      child: MasonryGridView.count(
                        padding: const EdgeInsets.all(16),
                        crossAxisCount:
                            MediaQuery.of(context).size.width < 600 ? 2 : 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        itemCount: tp.tasks.length,
                        itemBuilder: (context, i) {
                          final t = tp.tasks[i];
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: TaskCard(
                              key: ValueKey(t.id ?? t.title),
                              task: t,
                              onDelete: () {
                                if (t.id != null) _deleteTask(t.id!);
                              },
                            ),
                          );
                        },
                      ),
                    ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openAdd,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            elevation: 6,
            icon: const Icon(Icons.add),
            label: const Text(
              'Add Task',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        );
      },
    );
  }
}
