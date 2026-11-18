import 'dart:math' as math;
import '../../common/platform_detector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import '../../models/playback_model.dart';
import '../../ui/managers/playback_actions.dart';

class PlaybackTransportBar extends StatelessWidget {
  const PlaybackTransportBar({
    super.key,
    required this.state,
    required this.onCommand,
    required this.onSeek,
    required this.onSpeed,
    required this.onDirection,
    this.followCamera = false,
    this.onFollowCamera,
    this.compact = false,
  });
  final PlaybackState state;
  final bool compact;
  final ValueChanged<PlaybackCommand> onCommand;
  final ValueChanged<double> onSeek, onSpeed;
  final ValueChanged<PlaybackDirection> onDirection;
  final bool followCamera;
  final ValueChanged<bool>? onFollowCamera;
  void activate(PlaybackCommand command) {
    PlatformDetector.selectionFeedback();
    onCommand(command);
  }

  @override
  Widget build(BuildContext context) {
    final frames = state.timeline?.frames ?? const [];
    final ready = frames.isNotEmpty;
    final end = math.max(0, frames.length - 1).toDouble();
    final milestones = [
      for (var i = 0; i < frames.length; i++)
        if (frames[i].isKeyMilestone) i,
    ];
    final reason = switch (state.pauseReason) {
      PauseReason.breakpoint =>
        '命中断点 · ${state.hitBreakpoint!.language.name} 第 ${state.hitBreakpoint!.line} 行',
      PauseReason.error => '错误帧暂停 · 可回退检查',
      PauseReason.boundary => '已到时间轴边界',
      _ => state.isPlaying ? '播放中' : '已暂停',
    };
    Widget button(
      PlaybackCommand command,
      IconData icon,
      String tooltip, {
      bool enabled = true,
    }) => IconButton(
      key: ValueKey('transport-${command.name}'),
      tooltip: tooltip,
      onPressed: ready && enabled ? () => activate(command) : null,
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      icon: Icon(icon),
    );
    if (compact) {
      return LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth >= 800;
          final status = Text(
            ready
                ? '第 ${state.frameIndex + 1} / ${frames.length} 帧 · $reason'
                : '暂无播放轨迹',
            key: const ValueKey('playback-status'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall,
          );
          final controls = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (c.maxWidth >= 360)
                button(
                  PlaybackCommand.first,
                  Icons.first_page,
                  '复位 · Home',
                  enabled: state.position > 0,
                ),
              button(
                PlaybackCommand.stepBack,
                Icons.skip_previous,
                '上一步 · ←',
                enabled: state.position > 0,
              ),
              FilledButton(
                key: const ValueKey('play-toggle'),
                onPressed: ready && frames.length > 1
                    ? () => activate(PlaybackCommand.toggle)
                    : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(56, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      state.isPlaying ? 16 : 28,
                    ),
                  ),
                ),
                child: Tooltip(
                  message: state.isPlaying ? '暂停 · Space' : '播放 · Space',
                  child: AnimatedSwitcher(
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 160),
                    child: Icon(
                      state.isPlaying ? Icons.pause : Icons.play_arrow,
                      key: ValueKey(state.isPlaying),
                    ),
                  ),
                ),
              ),
              button(
                PlaybackCommand.stepInto,
                Icons.skip_next,
                '下一步 · →',
                enabled: state.position < end,
              ),
              button(
                PlaybackCommand.nextMilestone,
                Icons.fast_forward,
                '下一里程碑 · Shift+→',
                enabled: state.position < end,
              ),
            ],
          );
          final more = PopupMenuButton<String>(
            key: const ValueKey('transport-options'),
            tooltip: '播放选项',
            enabled: ready,
            constraints: const BoxConstraints(minWidth: 200),
            icon: const Icon(Icons.more_horiz),
            onSelected: (v) {
              if (v == 'first') activate(PlaybackCommand.first);
              if (v == 'last') activate(PlaybackCommand.last);
              if (v == 'forward') onDirection(PlaybackDirection.forward);
              if (v == 'reverse') onDirection(PlaybackDirection.reverse);
              if (v == 'follow') onFollowCamera?.call(!followCamera);
              if (v.startsWith('speed:')) onSpeed(double.parse(v.substring(6)));
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'first', child: Text('复位 · Home')),
              const PopupMenuItem(value: 'last', child: Text('末帧 · End')),
              const PopupMenuDivider(),
              CheckedPopupMenuItem(
                value: 'forward',
                checked: state.direction == PlaybackDirection.forward,
                child: const Text('正放'),
              ),
              CheckedPopupMenuItem(
                value: 'reverse',
                checked: state.direction == PlaybackDirection.reverse,
                child: const Text('倒放'),
              ),
              for (final speed in [.25, .5, 1.0, 2.0, 4.0])
                CheckedPopupMenuItem(
                  value: 'speed:$speed',
                  checked: state.speed == speed,
                  child: Text('$speed×'),
                ),
              if (onFollowCamera != null)
                CheckedPopupMenuItem(
                  value: 'follow',
                  checked: followCamera,
                  child: const Text('自动跟随镜头'),
                ),
            ],
          );
          final slider = SizedBox(
            height: 48,
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _MilestonePainter(
                        milestones: milestones,
                        end: end,
                        color: Theme.of(context).colorScheme.primary,
                        onSeek: onSeek,
                        inline: true,
                      ),
                    ),
                  ),
                ),
                Slider(
                  key: const ValueKey('trace-seek'),
                  value: state.position,
                  max: end,
                  label: '第 ${state.frameIndex + 1} 帧',
                  onChanged: ready && frames.length > 1 ? onSeek : null,
                  onChangeEnd: milestones.isEmpty
                      ? null
                      : (value) {
                          final nearest = milestones.reduce(
                            (a, b) =>
                                (a - value).abs() <= (b - value).abs() ? a : b,
                          );
                          if ((nearest - value).abs() <=
                              math.max(.15, end * .025)) {
                            onSeek(nearest.toDouble());
                          }
                        },
                ),
              ],
            ),
          );
          return Material(
            elevation: 6,
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(28),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: wide
                  ? Row(
                      children: [
                        controls,
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [status, slider],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '${state.direction == PlaybackDirection.forward ? '正放' : '倒放'} · ${state.speed}×',
                          ),
                        ),
                        more,
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [controls, more],
                          ),
                        ),
                        slider,
                        status,
                      ],
                    ),
            ),
          );
        },
      );
    }
    return Material(
      elevation: 3,
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 4,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                button(
                  PlaybackCommand.first,
                  Icons.first_page,
                  '复位 · Home',
                  enabled: state.position > 0,
                ),
                button(
                  PlaybackCommand.stepBack,
                  Icons.skip_previous,
                  '上一步 · ←',
                  enabled: state.position > 0,
                ),
                FilledButton.icon(
                  key: const ValueKey('play-toggle'),
                  onPressed: ready && frames.length > 1
                      ? () => activate(PlaybackCommand.toggle)
                      : null,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(96, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        state.isPlaying ? 16 : 28,
                      ),
                    ),
                  ),
                  icon: AnimatedSwitcher(
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 160),
                    child: Icon(
                      state.isPlaying ? Icons.pause : Icons.play_arrow,
                      key: ValueKey(state.isPlaying),
                    ),
                  ),
                  label: Text(state.isPlaying ? '暂停' : '播放'),
                ),
                button(
                  PlaybackCommand.stepInto,
                  Icons.skip_next,
                  '下一步 · →',
                  enabled: state.position < end,
                ),
                button(
                  PlaybackCommand.nextMilestone,
                  Icons.fast_forward,
                  '下一里程碑 · Shift+→',
                  enabled: state.position < end,
                ),
                button(
                  PlaybackCommand.last,
                  Icons.last_page,
                  '末帧 · End',
                  enabled: state.position < end,
                ),
                DropdownButton<PlaybackDirection>(
                  key: const ValueKey('play-direction'),
                  value: state.direction,
                  items: const [
                    DropdownMenuItem(
                      value: PlaybackDirection.forward,
                      child: Text('正放'),
                    ),
                    DropdownMenuItem(
                      value: PlaybackDirection.reverse,
                      child: Text('倒放'),
                    ),
                  ],
                  onChanged: ready
                      ? (v) {
                          if (v != null) onDirection(v);
                        }
                      : null,
                ),
                DropdownButton<double>(
                  key: const ValueKey('play-speed'),
                  value: state.speed,
                  items: [
                    for (final speed in [.25, .5, 1.0, 2.0, 4.0])
                      DropdownMenuItem(value: speed, child: Text('$speed×')),
                  ],
                  onChanged: ready
                      ? (v) {
                          if (v != null) onSpeed(v);
                        }
                      : null,
                ),
                if (onFollowCamera != null)
                  FilterChip(
                    key: const ValueKey('camera-follow'),
                    selected: followCamera,
                    onSelected: ready ? onFollowCamera : null,
                    avatar: const Icon(Icons.center_focus_strong, size: 18),
                    label: const Text('自动跟随镜头'),
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                  ),
              ],
            ),
            Slider(
              key: const ValueKey('trace-seek'),
              value: state.position,
              max: end,
              label: '第 ${state.frameIndex + 1} 帧',
              onChanged: ready && frames.length > 1 ? onSeek : null,
            ),
            if (milestones.isNotEmpty)
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  double x(int i) =>
                      24 + (math.max(1, width - 48)) * (end == 0 ? 0 : i / end);
                  return Tooltip(
                    message: '菱形标记：点击跳至最近里程碑',
                    child: GestureDetector(
                      key: const ValueKey('milestone-track'),
                      behavior: HitTestBehavior.opaque,
                      onTapUp: (d) {
                        final nearest = milestones.reduce(
                          (a, b) =>
                              (x(a) - d.localPosition.dx).abs() <=
                                  (x(b) - d.localPosition.dx).abs()
                              ? a
                              : b,
                        );
                        onSeek(nearest.toDouble());
                      },
                      child: CustomPaint(
                        size: Size(width, 48),
                        painter: _MilestonePainter(
                          milestones: milestones,
                          end: end,
                          color: Theme.of(context).colorScheme.primary,
                          onSeek: onSeek,
                        ),
                      ),
                    ),
                  );
                },
              ),
            Text(
              ready
                  ? '第 ${state.frameIndex + 1} / ${frames.length} 帧 · $reason'
                  : '暂无播放轨迹',
              key: const ValueKey('playback-status'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MilestonePainter extends CustomPainter {
  const _MilestonePainter({
    required this.milestones,
    required this.end,
    required this.color,
    required this.onSeek,
    this.inline = false,
  });
  final bool inline;
  final List<int> milestones;
  final double end;
  final Color color;
  final ValueChanged<double> onSeek;
  Offset point(Size size, int index) => Offset(
    24 + math.max(1, size.width - 48) * (end == 0 ? 0 : index / end),
    inline ? size.height - 8 : 24,
  );
  @override
  void paint(Canvas canvas, Size size) {
    final pen = Paint()..color = color;
    for (final index in milestones) {
      final p = point(size, index);
      canvas.drawPath(
        Path()
          ..moveTo(p.dx, p.dy - 5)
          ..lineTo(p.dx + 5, p.dy)
          ..lineTo(p.dx, p.dy + 5)
          ..lineTo(p.dx - 5, p.dy)
          ..close(),
        pen,
      );
    }
  }

  @override
  SemanticsBuilderCallback get semanticsBuilder =>
      (size) => [
        for (final i in milestones)
          CustomPainterSemantics(
            rect: Rect.fromCenter(
              center: point(size, i),
              width: 48,
              height: 48,
            ),
            properties: SemanticsProperties(
              button: true,
              textDirection: TextDirection.ltr,
              label: '跳至第 ${i + 1} 帧里程碑',
              onTap: () => onSeek(i.toDouble()),
            ),
          ),
      ];
  @override
  bool shouldRepaint(_MilestonePainter old) =>
      old.inline != inline ||
      old.end != end ||
      old.color != color ||
      !listEquals(old.milestones, milestones);
  @override
  bool shouldRebuildSemantics(_MilestonePainter old) =>
      shouldRepaint(old) || old.onSeek != onSeek;
}
