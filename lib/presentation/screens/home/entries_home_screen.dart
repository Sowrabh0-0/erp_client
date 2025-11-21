// lib/presentation/screens/home/entries_home_screen.dart
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/providers/auth_provider.dart';

class EntriesHomeScreen extends ConsumerStatefulWidget {
  final String companyId;
  final String companyName;
  final String timePeriodId;

  const EntriesHomeScreen({
    super.key,
    required this.companyId,
    required this.companyName,
    required this.timePeriodId,
  });

  @override
  ConsumerState<EntriesHomeScreen> createState() => _EntriesHomeScreenState();
}

class _EntriesHomeScreenState extends ConsumerState<EntriesHomeScreen> {
  final supabase = SupabaseConfig.client;
  List<Map<String, dynamic>> files = [];
  List<Map<String, dynamic>> entries = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadFilesAndEntries();
  }

  Future<void> _loadFilesAndEntries() async {
    setState(() => loading = true);
    try {
      // With RLS using current_setting('app.active_company'), these selects
      // will already be scoped to the active company for this session.
      // It's safe (and fine) to also include eq('company_id', widget.companyId)
      // as an extra filter if you want.
      final filesRes = await supabase
          .from('entry_files')
          .select()
          .eq('time_period_id', widget.timePeriodId)
          .order('created_at', ascending: false);

      final entriesRes = await supabase
          .from('entries')
          .select()
          .eq('time_period_id', widget.timePeriodId)
          .order('created_at', ascending: false);

      setState(() {
        files = List<Map<String, dynamic>>.from(filesRes as List);
        entries = List<Map<String, dynamic>>.from(entriesRes as List);
        loading = false;
      });

      debugPrint('Loaded ${files.length} files and ${entries.length} entries');
    } catch (e, st) {
      debugPrint('Load error: $e\n$st');
      if (mounted) {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Load error: $e')));
      }
    }
  }

  // Optional: allow user to change active company (go back to selection)
  void _changeCompany() {
    // Navigate back to company selector. User will re-select company and set active company via RPC.
    context.go('/'); // assumes router '/' = company selection for logged in users
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.companyName.isEmpty ? 'Home' : widget.companyName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFilesAndEntries,
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Change company',
            onPressed: _changeCompany,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadFilesAndEntries,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Folders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    files.isEmpty ? const Text('No folders yet') : _buildFilesList(),
                    const Divider(),
                    const Text('Entries', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    entries.isEmpty ? const Text('No entries yet') : _buildEntriesList(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: open create entry flow (ensure server-side inserts use active company/time_period_id)
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Create entry - TODO')));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilesList() {
    return Column(
      children: files.map((f) {
        return ListTile(
          leading: const Icon(Icons.folder),
          title: Text(f['name'] ?? 'Untitled'),
          subtitle: Text('Created: ${f['created_at'] ?? ''}'),
          onTap: () {
            final fileEntries = entries.where((e) => e['file_id'] == f['id']).toList();
            showModalBottomSheet(
              context: context,
              builder: (_) => _EntriesListSheet(title: f['name'] ?? 'Folder', items: fileEntries),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildEntriesList() {
    return Column(
      children: entries.map((e) {
        return ListTile(
          leading: const Icon(Icons.description),
          title: Text(e['title'] ?? 'Untitled'),
          subtitle: Text('Created: ${e['created_at'] ?? ''}'),
          onTap: () {
            // TODO: open entry detail / edit
          },
        );
      }).toList(),
    );
  }
}

class _EntriesListSheet extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  const _EntriesListSheet({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: 400,
        child: Column(
          children: [
            Padding(padding: const EdgeInsets.all(12), child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const Divider(),
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('No entries in this folder'))
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final e = items[i];
                        return ListTile(
                          title: Text(e['title'] ?? 'Untitled'),
                          subtitle: Text(e['created_at'] ?? ''),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
