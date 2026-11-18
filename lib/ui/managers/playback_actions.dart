import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum PlaybackCommand { toggle, stepBack, stepInto, nextMilestone, first, last }

class PlaybackIntent extends Intent {
  const PlaybackIntent(this.command);
  final PlaybackCommand command;
}

const playbackShortcuts = <ShortcutActivator, Intent>{
  SingleActivator(LogicalKeyboardKey.space, includeRepeats: false):
      PlaybackIntent(PlaybackCommand.toggle),
  SingleActivator(LogicalKeyboardKey.arrowLeft): PlaybackIntent(
    PlaybackCommand.stepBack,
  ),
  SingleActivator(LogicalKeyboardKey.arrowRight): PlaybackIntent(
    PlaybackCommand.stepInto,
  ),
  SingleActivator(LogicalKeyboardKey.arrowRight, shift: true): PlaybackIntent(
    PlaybackCommand.nextMilestone,
  ),
  SingleActivator(LogicalKeyboardKey.home): PlaybackIntent(
    PlaybackCommand.first,
  ),
  SingleActivator(LogicalKeyboardKey.end): PlaybackIntent(PlaybackCommand.last),
};

/// The shell owns key bindings; the active laboratory owns their behavior.
/// Text fields and focused buttons retain their normal editing/activation keys.
class PlaybackActions extends StatelessWidget {
  const PlaybackActions({
    super.key,
    required this.onCommand,
    required this.child,
    this.enabled = true,
  });
  final ValueChanged<PlaybackCommand> onCommand;
  final Widget child;
  final bool enabled;
  @override
  Widget build(BuildContext context) => Actions(
    actions: {PlaybackIntent: _PlaybackAction(onCommand, enabled)},
    child: child,
  );
}

class _PlaybackAction extends Action<PlaybackIntent> {
  _PlaybackAction(this.callback, this.enabled);
  final ValueChanged<PlaybackCommand> callback;
  final bool enabled;
  @override
  bool isEnabled(PlaybackIntent intent) {
    final context = FocusManager.instance.primaryFocus?.context;
    return enabled &&
        context != null &&
        context.findAncestorStateOfType<EditableTextState>() == null &&
        context.findAncestorWidgetOfExactType<EditableText>() == null;
  }

  @override
  Object? invoke(PlaybackIntent intent) {
    callback(intent.command);
    return null;
  }
}
