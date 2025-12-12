import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/pages/scan.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';

class AddProfileView extends StatelessWidget {
  final BuildContext context;

  const AddProfileView({
    super.key,
    required this.context,
  });

  Future<void> _handleAddProfileFormFile() async {
    globalState.appController.addProfileFormFile();
  }

  Future<void> _handleAddProfileFormURL(String url) async {
    globalState.appController.addProfileFormURL(url);
  }

  Future<void> _toScan() async {
    if (system.isDesktop) {
      globalState.appController.addProfileFormQrCode();
      return;
    }
    final url = await BaseNavigator.push(
      context,
      const ScanPage(),
    );
    if (url != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleAddProfileFormURL(url);
      });
    }
  }

  Future<void> _toAdd() async {
    final url = await globalState.showCommonDialog<String>(
      child: InputDialog(
        autovalidateMode: AutovalidateMode.onUnfocus,
        title: appLocalizations.importFromURL,
        labelText: appLocalizations.url,
        value: '',
        validator: (value) {
          if (value == null || value.isEmpty) {
            return appLocalizations.emptyTip('').trim();
          }
          if (!value.isUrl) {
            return appLocalizations.urlTip('').trim();
          }
          return null;
        },
      ),
    );
    if (url != null) {
      _handleAddProfileFormURL(url);
    }
  }

  @override
  Widget build(context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.block,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '第三方不受支持的订阅配置',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '请通过登录账号自动导入配置文件',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class URLFormDialog extends StatefulWidget {
  const URLFormDialog({super.key});

  @override
  State<URLFormDialog> createState() => _URLFormDialogState();
}

class _URLFormDialogState extends State<URLFormDialog> {
  final urlController = TextEditingController();

  Future<void> _handleAddProfileFormURL() async {
    final url = urlController.value.text;
    if (url.isEmpty) return;
    Navigator.of(context).pop<String>(url);
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: appLocalizations.importFromURL,
      actions: [
        TextButton(
          onPressed: _handleAddProfileFormURL,
          child: Text(appLocalizations.submit),
        )
      ],
      child: SizedBox(
        width: 300,
        child: Wrap(
          runSpacing: 16,
          children: [
            TextField(
              keyboardType: TextInputType.url,
              minLines: 1,
              maxLines: 5,
              onSubmitted: (_) {
                _handleAddProfileFormURL();
              },
              onEditingComplete: _handleAddProfileFormURL,
              controller: urlController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: appLocalizations.url,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
