// lib/presentation/screens/home/entries_home_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_client.dart';

class EntriesHomeScreen extends StatefulWidget {
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
  State<EntriesHomeScreen> createState() => _EntriesHomeScreenState();
}

class _EntriesHomeScreenState extends State<EntriesHomeScreen> {
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
      final filesRes = await supabase
          .from('entry_files')
          .select()
          .eq('company_id', widget.companyId)
          .eq('time_period_id', widget.timePeriodId)
          .order('created_at', ascending: false);
      final entriesRes = await supabase
          .from('entries')
          .select()
          .eq('company_id', widget.companyId)
          .eq('time_period_id', widget.timePeriodId)
          .order('created_at', ascending: false);

      setState(() {
        files = List<Map<String, dynamic>>.from(filesRes as List);
        entries = List<Map<String, dynamic>>.from(entriesRes as List);
        loading = false;
      });
    } catch (e) {
      // show error
      if (mounted) {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Load error: $e')));
      }
    }
  }

  Widget _buildFilesList() {
    if (files.isEmpty) return const Text('No folders yet');
    return Column(
      children: files.map((f) {
        return ListTile(
          leading: const Icon(Icons.folder),
          title: Text(f['name'] ?? 'Untitled'),
          subtitle: Text('Created: ${f['created_at'] ?? ''}'),
          onTap: () {
            // For now tapping just lists entries — filter client-side
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
    if (entries.isEmpty) return const Text('No entries yet');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.companyName.isEmpty ? 'Home' : widget.companyName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFilesAndEntries,
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Folders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildFilesList(),
                  const Divider(),
                  const Text('Entries', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildEntriesList(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: open create entry flow
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Create entry - TODO')));
        },
        child: const Icon(Icons.add),
      ),
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
