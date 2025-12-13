import 'dart:math';

import 'package:defer_pointer/defer_pointer.dart';
import 'package:rmmy/common/common.dart';
import 'package:rmmy/enum/enum.dart';
import 'package:rmmy/providers/providers.dart';
import 'package:rmmy/providers/xboard_api.dart';
import 'package:rmmy/providers/xboard_config.dart';
import 'package:rmmy/state.dart';
import 'package:rmmy/widgets/widgets.dart';
import 'package:rmmy/views/dashboard/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets/start_button.dart';

typedef _IsEditWidgetBuilder = Widget Function(bool isEdit);

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  final key = GlobalKey<SuperGridState>();
  final _isEditNotifier = ValueNotifier<bool>(false);
  final _addedWidgetsNotifier = ValueNotifier<List<GridItem>>([]);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  Future<void> _init() async {
    final appController = ref.read(appControllerProvider);
    final isInit = await appController.getIsInit();
    if (!isInit) {
      if (mounted) {
        final shouldStart = await showDialog<bool>(
          context: context,
          builder: (context) {
            return CommonDialog(
              title: Text(appLocalizations.clashCoreNotInit),
              content: Text(appLocalizations.clashCoreNotInitDesc),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(appLocalizations.cancel),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text(appLocalizations.ok),
                ),
              ],
            );
          },
        );
        if (shouldStart == true) {
          await appController.initClash();
        }
      }
    }
  }

  List<Widget> _buildActions(bool isEdit) {
    if (!system.isSlash)
      return [
        if (isEdit)
          ValueListenableBuilder(
            valueListenable: _addedWidgetsNotifier,
            builder: (_, addedChildren, child) {
              if (addedChildren.isEmpty) {
                return Container();
              }
              return child!;
            },
            child: IconButton(
              onPressed: () {
                _showAddWidgetsModal();
              },
              icon: Icon(Icons.add_circle),
            ),
          ),
        FadeRotationScaleBox(
          child: isEdit
              ? IconButton(
                  key: ValueKey(true),
                  icon: Icon(Icons.save, key: ValueKey('save-icon')),
                  onPressed: _handleUpdateIsEdit,
                )
              : IconButton(
                  key: ValueKey(false),
                  icon: Icon(Icons.edit, key: ValueKey('edit-icon')),
                  onPressed: _handleUpdateIsEdit,
                ),
        )
      ];
    final coreStatus = ref.watch(coreStatusProvider);
    return [
      if (!isEdit)
        ValueListenableBuilder(
          valueListenable: coreStatus,
          builder: (_, coreStatus, child) {
            return Tooltip(
              message: appLocalizations.coreStatus,
              child: TextButton.icon(
                onPressed: () {
                  final renderProps =
                      context.findRenderObject() as RenderBox;
                  final offset = renderProps.localToGlobal(Offset.zero);
                  final size = renderProps.size;
                  final position = RelativeRect.fromLTRB(
                    offset.dx + size.width,
                    offset.dy + kToolbarHeight,
                    offset.dx + size.width,
                    offset.dy + size.height,
                  );
                  showMenu(
                    context: context,
                    position: position,
                    items: [
                      PopupMenuItem(
                        child: Text(appLocalizations.restartCore),
                        onTap: () {
                          ref.read(appControllerProvider).initClash();
                        },
                      ),
                      PopupMenuItem(
                        child: Text(appLocalizations.forceGc),
                        onTap: () {
                          ref.read(appControllerProvider).forceGc();
                        },
                      ),
                    ],
                  );
                },
                icon: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: switch (coreStatus) {
                    CoreStatus.connecting => SizedBox(
                      width: 16,
                      height: 16,
                      child: Padding(
                        padding: EdgeInsets.all(2),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: context.colorScheme.onPrimary,
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ),
                    CoreStatus.connected => Icon(
                      Icons.check_sharp,
                      fontWeight: FontWeight.w900,
                    ),
                    CoreStatus.disconnected => Icon(
                      Icons.restart_alt_sharp,
                      fontWeight: FontWeight.w900,
                    ),
                  },
                ),
                label: Text(switch (coreStatus) {
                  CoreStatus.connecting => appLocalizations.connecting,
                  CoreStatus.connected => appLocalizations.connected,
                  CoreStatus.disconnected =>
                    appLocalizations.disconnected,
                }),
              ),
            );
          },
        ),
      if (isEdit)
        ValueListenableBuilder(
          valueListenable: _addedWidgetsNotifier,
          builder: (_, addedChildren, child) {
            if (addedChildren.isEmpty) {
              return Container();
            }
            return child!;
          },
          child: IconButton(
            onPressed: () {
              _showAddWidgetsModal();
            },
            icon: Icon(Icons.add_circle),
          ),
        ),
      FadeRotationScaleBox(
        child: isEdit
            ? IconButton(
                key: ValueKey(true),
                icon: Icon(Icons.save, key: ValueKey('save-icon')),
                onPressed: _handleUpdateIsEdit,
              )
            : IconButton(
                key: ValueKey(false),
                icon: Icon(Icons.edit, key: ValueKey('edit-icon')),
                onPressed: _handleUpdateIsEdit,
              ),
      ),
    ];
  }

  void _showAddWidgetsModal() {
    showSheet(
      builder: (_, type) {
        return ValueListenableBuilder(
          valueListenable: _addedWidgetsNotifier,
          builder: (_, value, _) {
            return AdaptiveSheetScaffold(
              type: type,
              body: _AddDashboardWidgetModal(
                items: value,
                onAdd: (gridItem) {
                  key.currentState?.handleAdd(gridItem);
                },
              ),
              title: appLocalizations.add,
            );
          },
        );
      },
      context: context,
    );
  }

  Future<void> _handleUpdateIsEdit() async {
    if (_isEditNotifier.value == true) {
      await _handleSave();
    }
    _isEditNotifier.value = !_isEditNotifier.value;
  }

  Future<void> _handleSave() async {
    final currentState = key.currentState;
    if (currentState == null) {
      return;
    }
    if (mounted) {
      await currentState.isTransformCompleter;
      final dashboardWidgets = currentState.children
          .map((item) => (item.key as ValueKey<DashboardWidget>).value)
          .toList();
      ref
          .read(appSettingProvider.notifier)
          .updateState(
            (state) => state.copyWith(dashboardWidgets: dashboardWidgets),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardStateProvider);
    final columns = max(4 * ((dashboardState.contentWidth / 280).ceil()), 8);
    final spacing = 14.ap;
    final children = [
      ...dashboardState.dashboardWidgets
          .where(
            (item) => item.platforms.contains(SupportPlatform.currentPlatform),
          )
          .map((item) => item.gridItem),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addedWidgetsNotifier.value = DashboardWidget.values
          .where(
            (item) =>
                !dashboardState.dashboardWidgets.contains(item) &&
                item.platforms.contains(SupportPlatform.currentPlatform),
          )
          .map((item) => item.gridItem)
          .toList();
    });
    return _buildIsEdit(
      (isEdit) => CommonScaffold(
        title: appLocalizations.dashboard,
        actions: _buildActions(isEdit),
        floatingActionButton: const StartButton(),
        body: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16).copyWith(bottom: 88),
            child: isEdit
                ? SystemBackBlock(
                    child: CommonPopScope(
                      child: SuperGrid(
                        key: key,
                        crossAxisCount: columns,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                        children: [
                          ...dashboardState.dashboardWidgets
                              .where(
                                (item) => item.platforms.contains(
                                  SupportPlatform.currentPlatform,
                                ),
                              )
                              .map((item) => item.gridItem),
                        ],
                        onUpdate: () {
                          _handleSave();
                        },
                      ),
                      onPop: (context) {
                        _handleUpdateIsEdit();
                        return false;
                      },
                    ),
                  )
                : Grid(
                    crossAxisCount: columns,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                    children: children,
                  ),
          ),
        ),
      ),
    );
  }
}

class _AddDashboardWidgetModal extends StatelessWidget {
  final List<GridItem> items;
  final Function(GridItem item) onAdd;

  const _AddDashboardWidgetModal({required this.items, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return DeferredPointerHandler(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Grid(
          crossAxisCount: 8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: items
              .map(
                (item) => item.wrap(
                  builder: (child) {
                    return _AddedContainer(
                      onAdd: () {
                        onAdd(item);
                      },
                      child: child,
                    );
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _AddedContainer extends StatefulWidget {
  final Widget child;
  final VoidCallback onAdd;

  const _AddedContainer({required this.child, required this.onAdd});

  @override
  State<_AddedContainer> createState() => _AddedContainerState();
}

class _AddedContainerState extends State<_AddedContainer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(_AddedContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child) {}
  }

  Future<void> _handleAdd() async {
    widget.onAdd();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ActivateBox(child: widget.child),
        Positioned(
          top: -8,
          right: -8,
          child: DeferPointer(
            child: SizedBox(
              width: 24,
              height: 24,
              child: IconButton.filled(
                iconSize: 20,
                padding: EdgeInsets.all(2),
                onPressed: _handleAdd,
                icon: Icon(Icons.add),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

extension DashboardWidgetUI on DashboardWidget {
  GridItem get gridItem {
    return switch (this) {
      DashboardWidget.subscriptionInfo => GridItem(
          key: ValueKey(DashboardWidget.subscriptionInfo),
          crossAxisCellCount: defaultCrossAxisCellCount,
          child: const SubscriptionInfo(),
        ),
      DashboardWidget.networkSpeed => GridItem(
          key: ValueKey(DashboardWidget.networkSpeed),
          crossAxisCellCount: defaultCrossAxisCellCount,
          child: const NetworkSpeed(),
        ),
      DashboardWidget.outboundModeV2 => GridItem(
          key: ValueKey(DashboardWidget.outboundModeV2),
          crossAxisCellCount: defaultCrossAxisCellCount,
          child: const OutboundModeV2(),
        ),
      DashboardWidget.outboundMode => GridItem(
          key: ValueKey(DashboardWidget.outboundMode),
          crossAxisCellCount: defaultCrossAxisCellCount,
          child: const OutboundMode(),
        ),
      DashboardWidget.trafficUsage => GridItem(
          key: ValueKey(DashboardWidget.trafficUsage),
          crossAxisCellCount: defaultCrossAxisCellCount,
          child: const TrafficUsage(),
        ),
      DashboardWidget.networkDetection => GridItem(
          key: ValueKey(DashboardWidget.networkDetection),
          crossAxisCellCount: defaultCrossAxisCellCount,
          child: const NetworkDetection(),
        ),
      DashboardWidget.tunButton => GridItem(
          key: ValueKey(DashboardWidget.tunButton),
          crossAxisCellCount: defaultCrossAxisCellCount,
          child: const TUNButton(),
        ),
      DashboardWidget.vpnButton => GridItem(
          key: ValueKey(DashboardWidget.vpnButton),
          crossAxisCellCount: defaultCrossAxisCellCount,
          child: const VpnButton(),
        ),
      DashboardWidget.systemProxyButton => GridItem(
          key: ValueKey(DashboardWidget.systemProxyButton),
          crossAxisCellCount: defaultCrossAxisCellCount,
          child: const SystemProxyButton(),
        ),
      DashboardWidget.intranetIp => GridItem(
          key: ValueKey(DashboardWidget.intranetIp),
          crossAxisCellCount: defaultCrossAxisCellCount,
          child: const IntranetIP(),
        ),
      DashboardWidget.memoryInfo => GridItem(
          key: ValueKey(DashboardWidget.memoryInfo),
          crossAxisCellCount: defaultCrossAxisCellCount,
          child: const MemoryInfo(),
        ),
    };
  }
}
