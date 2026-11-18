import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/bento_card.dart';

enum PreviewDevice {
  phone('手机', Size(390, 844)),
  tablet('平板', Size(800, 1000)),
  desktop('桌面', Size(1360, 860));

  const PreviewDevice(this.label, this.size);
  final String label;
  final Size size;
  String get description =>
      '$label · ${size.width.toInt()} × ${size.height.toInt()}';
}

class PreviewSelection extends Notifier<PreviewDevice?> {
  @override
  PreviewDevice? build() => null;
  void select(PreviewDevice? device) => state = device;
}

final previewDeviceProvider =
    NotifierProvider<PreviewSelection, PreviewDevice?>(PreviewSelection.new);

class PreviewSettings extends ConsumerWidget {
  const PreviewSettings({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(previewDeviceProvider);
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('布局预览', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final device in PreviewDevice.values)
                ChoiceChip(
                  key: ValueKey('preview-${device.name}'),
                  label: Text(device.description),
                  selected: current == device,
                  onSelected: (selected) => ref
                      .read(previewDeviceProvider.notifier)
                      .select(selected ? device : null),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class LayoutPreview extends ConsumerWidget {
  const LayoutPreview({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = ref.watch(previewDeviceProvider);
    if (device == null) return child;
    final media = MediaQuery.of(context);
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 12),
                Expanded(child: Text(device.description)),
                TextButton.icon(
                  onPressed: () =>
                      ref.read(previewDeviceProvider.notifier).select(null),
                  icon: const Icon(Icons.close),
                  label: const Text('退出预览'),
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox.fromSize(
                    size: device.size,
                    child: MediaQuery(
                      data: media.copyWith(
                        size: device.size,
                        padding: EdgeInsets.zero,
                        viewPadding: EdgeInsets.zero,
                      ),
                      child: ClipRect(child: child),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
