import 'dart:async';
import 'dart:io';

import 'package:rmmy/common/common.dart';
import 'package:rmmy/core/controller.dart';
import 'package:rmmy/state.dart';
import 'package:rmmy/widgets/widgets.dart';
import 'package:flutter/material.dart';

class MemoryInfo extends StatefulWidget {
  const MemoryInfo({super.key});

  @override
  State<MemoryInfo> createState() => _MemoryInfoState();
}

class _MemoryInfoState extends State<MemoryInfo> {
  late final ValueNotifier<num> _memoryStateNotifier;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _memoryStateNotifier = ValueNotifier<num>(0);
    _updateMemory();
  }

  @override
  void dispose() {
    timer?.cancel();
    _memoryStateNotifier.dispose();
    super.dispose();
  }

  Future<void> _updateMemory() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final rss = ProcessInfo.currentRss;
      if (coreController.isCompleted) {
        _memoryStateNotifier.value = await coreController.getMemory() + rss;
      } else {
        _memoryStateNotifier.value = rss;
      }
      timer = Timer(Duration(seconds: 2), () async {
        _updateMemory();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getWidgetHeight(1),
      child: CommonCard(
        info: Info(iconData: Icons.memory, label: appLocalizations.memoryInfo),
        onPressed: () {
          coreController.requestGc();
        },
        child: Container(
          padding: baseInfoEdgeInsets.copyWith(top: 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: globalState.measure.bodyMediumHeight + 2,
                child: ValueListenableBuilder(
                  valueListenable: _memoryStateNotifier,
                  builder: (_, memory, _) {
                    final traffic = memory.traffic;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          traffic.value,
                          style: context.textTheme.bodyMedium?.toLight
                              .adjustSize(1),
                        ),
                        SizedBox(width: 8),
                        Text(
                          traffic.unit,
                          style: context.textTheme.bodyMedium?.toLight
                              .adjustSize(1),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
