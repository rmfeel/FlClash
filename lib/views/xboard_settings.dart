import 'package:rmmy/providers/xboard_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class XboardSettings extends ConsumerStatefulWidget {
  const XboardSettings({super.key});

  @override
  ConsumerState<XboardSettings> createState() => _XboardSettingsState();
}

class _XboardSettingsState extends ConsumerState<XboardSettings> {
  final _urlController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final config = ref.read(xboardConfigProvider);
    _urlController.text = config.backendUrl ?? '';
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _saveUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入后端地址')),
      );
      return;
    }

    await ref.read(xboardConfigProvider.notifier).setBackendUrl(url);
    setState(() => _isEditing = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('后端地址已保�?)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(xboardConfigProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud),
                const SizedBox(width: 8),
                const Text(
                  'Xboard 配置',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (!_isEditing)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => setState(() => _isEditing = true),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isEditing) ...[
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: '后端地址',
                  hintText: 'https://your-xboard.com',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _urlController.text = config.backendUrl ?? '';
                      setState(() => _isEditing = false);
                    },
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _saveUrl,
                    child: const Text('保存'),
                  ),
                ],
              ),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('后端地址'),
                subtitle: Text(
                  config.backendUrl?.isNotEmpty == true
                      ? config.backendUrl!
                      : '未配�?,
                ),
              ),
              if (config.isLoggedIn)
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('登录账户'),
                  subtitle: Text(config.userEmail ?? '未知'),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
