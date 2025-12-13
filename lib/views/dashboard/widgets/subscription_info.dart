import 'package:rmmy/common/common.dart';
import 'package:rmmy/providers/xboard_api.dart';
import 'package:rmmy/providers/xboard_config.dart';
import 'package:rmmy/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionInfo extends ConsumerStatefulWidget {
  const SubscriptionInfo({super.key});

  @override
  ConsumerState<SubscriptionInfo> createState() => _SubscriptionInfoState();
}

class _SubscriptionInfoState extends ConsumerState<SubscriptionInfo> {
  Map<String, dynamic>? _subscriptionData;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSubscriptionInfo();
  }

  Future<void> _loadSubscriptionInfo() async {
    final api = ref.read(xboardApiProvider);
    final config = ref.read(xboardConfigProvider);
    
    if (api == null || config.authToken == null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await api.getSubscriptionInfo(config.authToken!);
      if (mounted) {
        print('订阅信息�?{result['data']}');
        setState(() {
          _subscriptionData = result['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('加载订阅信息失败: $e');
      if (mounted) {
        setState(() {
          _error = '加载失败�?{e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  String _formatBytes(int? bytes) {
    if (bytes == null) return '0 B';
    if (bytes == 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    int unitIndex = 0;
    double size = bytes.toDouble();
    
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    
    return '${size.toStringAsFixed(2)} ${units[unitIndex]}';
  }

  String _formatDate(int? timestamp) {
    if (timestamp == null) return '未知';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(xboardConfigProvider);
    
    if (!config.isLoggedIn) {
      return SizedBox(
        height: getWidgetHeight(2),
        child: CommonCard(
          info: Info(
            label: '订阅信息',
            iconData: Icons.subscriptions,
          ),
          onPressed: () {},
          child: Container(
            padding: baseInfoEdgeInsets,
            child: const Center(
              child: Text('未登�?, style: TextStyle(color: Colors.grey)),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: getWidgetHeight(2),
      child: CommonCard(
        info: Info(
          label: '订阅信息',
          iconData: Icons.subscriptions,
        ),
        onPressed: _loadSubscriptionInfo,
        child: Container(
          padding: baseInfoEdgeInsets.copyWith(top: 0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : _subscriptionData != null
                      ? Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _subscriptionData!['plan']?['name'] ?? 
                                    _subscriptionData!['plan_name'] ?? 
                                    '未知套餐',
                                    style: context.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '到期: ${_formatDate(_subscriptionData!['expired_at'])}',
                                  style: context.textTheme.bodySmall?.toLighter,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '已用流量',
                                  style: context.textTheme.bodySmall,
                                ),
                                Text(
                                  _formatBytes(
                                    (_subscriptionData!['u'] ?? 0) +
                                        (_subscriptionData!['d'] ?? 0),
                                  ),
                                  style: context.textTheme.bodySmall?.toLighter,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '剩余流量',
                                  style: context.textTheme.bodySmall,
                                ),
                                Text(
                                  _formatBytes(
                                    (_subscriptionData!['transfer_enable'] ?? 0) -
                                        (_subscriptionData!['u'] ?? 0) -
                                        (_subscriptionData!['d'] ?? 0),
                                  ),
                                  style: context.textTheme.bodySmall?.toLighter,
                                ),
                              ],
                            ),
                          ],
                        )
                      : const Center(
                          child: Text(
                            '点击刷新',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
        ),
      ),
    );
  }
}
