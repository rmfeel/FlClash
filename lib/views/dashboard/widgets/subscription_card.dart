import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/services/xboard_api_service.dart';
import 'package:fl_clash/providers/xboard_config.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 订阅信息Provider
final xboardSubscriptionProvider = FutureProvider<XboardSubscriptionInfo?>((ref) async {
  final apiService = ref.watch(xboardApiProvider);
  if (apiService == null) {
    return null;
  }
  
  try {
    return await apiService.getSubscribe();
  } catch (e) {
    // 获取失败，返回null
    return null;
  }
});

class SubscriptionCard extends ConsumerWidget {
  const SubscriptionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(xboardSubscriptionProvider);

    return SizedBox(
      height: getWidgetHeight(2),
      child: CommonCard(
        info: Info(
          label: '订阅信息',
          iconData: Icons.subscriptions,
        ),
        onPressed: () {},
        child: subscriptionAsync.when(
          data: (subscription) {
            if (subscription == null) {
              return _buildEmptyState(context);
            }
            return _buildSubscriptionContent(context, subscription);
          },
          loading: () => _buildLoadingState(context),
          error: (error, stack) => _buildErrorState(context, error),
        ),
      ),
    );
  }

  Widget _buildSubscriptionContent(BuildContext context, XboardSubscriptionInfo subscription) {
    final planName = subscription.plan?.name ?? '未订阅';
    final expireTime = subscription.expiredAt != null && subscription.expiredAt! > 0
        ? DateTime.fromMillisecondsSinceEpoch(subscription.expiredAt! * 1000)
        : null;
    final expireText = expireTime != null 
        ? '到期: ${expireTime.year}-${expireTime.month.toString().padLeft(2, '0')}-${expireTime.day.toString().padLeft(2, '0')}'
        : '长期有效';
    
    final usedTraffic = subscription.usedTraffic;
    final totalTraffic = subscription.transferEnable;
    final remainingTraffic = subscription.remainingTraffic;
    final progress = totalTraffic > 0 ? usedTraffic / totalTraffic : 0.0;

    final usedShow = usedTraffic.traffic.show;
    final totalShow = totalTraffic.traffic.show;
    final remainingShow = remainingTraffic.traffic.show;

    return Container(
      padding: baseInfoEdgeInsets.copyWith(top: 0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 订阅名称
          Row(
            children: [
              Expanded(
                child: Text(
                  planName,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // 到期时间
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: context.colorScheme.onSurfaceVariant.opacity80,
              ),
              const SizedBox(width: 4),
              Text(
                expireText,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant.opacity80,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // 流量进度条
          LinearProgressIndicator(
            minHeight: 6,
            value: progress.clamp(0.0, 1.0),
            backgroundColor: context.colorScheme.primary.opacity15,
          ),
          const SizedBox(height: 8),
          
          // 流量信息
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '已用',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant.opacity60,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      usedShow,
                      style: context.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '总计',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant.opacity60,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      totalShow,
                      style: context.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '剩余',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant.opacity60,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      remainingShow,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: remainingTraffic < totalTraffic * 0.1
                            ? context.colorScheme.error
                            : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: baseInfoEdgeInsets.copyWith(top: 0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              size: 48,
              color: context.colorScheme.onSurfaceVariant.opacity40,
            ),
            const SizedBox(height: 8),
            Text(
              '未配置订阅',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant.opacity60,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Container(
      padding: baseInfoEdgeInsets.copyWith(top: 0),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Container(
      padding: baseInfoEdgeInsets.copyWith(top: 0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: context.colorScheme.error.opacity60,
            ),
            const SizedBox(height: 8),
            Text(
              '加载失败',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
