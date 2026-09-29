import 'package:flutter/foundation.dart';

// Global notifier used to broadcast whether any audio is currently playing.
// Any audio player can set this to true when playback starts and false when it stops.
final ValueNotifier<bool> audioPlayingNotifier = ValueNotifier<bool>(false);

