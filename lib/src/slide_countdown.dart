import 'package:flutter/material.dart';
import 'package:stream_duration/stream_duration.dart';

part 'duration_title.dart';
part 'enum.dart';
part 'notifiy_duration.dart';
part 'text_animation.dart';
part 'slide_countdown_separated.dart';

class SlideCountdown extends StatefulWidget {
  const SlideCountdown({
    Key? key,
    required this.duration,
    this.textStyle =
        const TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.bold),
    this.icon,
    this.sufixIcon,
    this.separator,
    this.onDone,
    this.durationTitle,
    this.separatorType = SeparatorType.symbol,
    this.slideDirection = SlideDirection.down,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    this.separatorPadding = const EdgeInsets.symmetric(horizontal: 3),
    this.showZeroValue = false,
    this.fade = false,
    this.decoration = const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      color: Color(0xFFF23333),
    ),
    this.curve = Curves.easeOut,
    this.countUp = false,
    this.infinityCountUp = false,
  }) : super(key: key);

  /// [Duration] is the duration of the countdown slide,
  /// if the duration has finished it will call [onDone]
  final Duration duration;

  /// [TextStyle] is a parameter for all existing text,
  /// if this is null [SlideCountdown] has a default
  /// text style which will be of all text
  final TextStyle textStyle;

  /// [icon] is a parameter that can be initialized by any widget e.g [Icon],
  /// this will be in the first order, default empty widget
  final Widget? icon;

  /// [icon] is a parameter that can be initialized by any widget e.g [Icon],
  /// this will be in the end order, default empty widget
  final Widget? sufixIcon;

  /// Separator is a parameter that will separate each [duration],
  /// e.g hours by minutes, and you can change the [SeparatorType] of the symbol or title
  final String? separator;

  /// function [onDone] will be called when countdown is complete
  final VoidCallback? onDone;

  /// if you want to change the separator type, change this value to
  /// [SeparatorType.title] or [SeparatorType.symbol].
  /// [SeparatorType.title] will display title between duration,
  /// e.g minutes or you can change to another language, by changing the value in [DurationTitle]
  final SeparatorType separatorType;

  /// change [Duration Title] if you want to change the default language,
  /// which is English, to another language, for example, into Indonesian
  /// pro tips: if you change to Indonesian, we have default values [DurationTitle.id()]
  final DurationTitle? durationTitle;

  /// The decoration to paint in front of the [child].
  final Decoration decoration;

  /// The amount of space by which to inset the child.
  final EdgeInsets padding;

  /// The amount of space by which to inset the [separator].
  final EdgeInsets separatorPadding;

  /// if you initialize it with false, the duration which is empty will not be displayed
  final bool showZeroValue;

  /// if you want [slideDirection] animation that is not rough set this value to true
  final bool fade;

  /// you can change the slide animation up or down by changing the enum value in this property
  final SlideDirection slideDirection;

  /// to customize curve in [TextAnimation] you can change the default value
  /// default [Curves.easeOut]
  final Curve curve;

  ///this property allows you to do a count up, give it a value of true to do it
  final bool countUp;

  /// if you set this property value to true, it will do the count up continuously or infinity
  /// and the [onDone] property will never be executed,
  /// before doing that you need to set true to the [countUp] property,
  final bool infinityCountUp;

  @override
  _SlideCountdownState createState() => _SlideCountdownState();
}

class _SlideCountdownState extends State<SlideCountdown> {
  final ValueNotifier<int> _daysFirstDigitNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> _daysSecondDigitNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> _hoursFirstDigitNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> _hoursSecondDigitNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> _minutesFirstDigitNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> _minutesSecondDigitNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> _secondsFirstDigitNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> _secondsSecondDigitNotifier = ValueNotifier<int>(0);

  late DurationTitle _durationTitle;
  late StreamDuration _streamDuration;
  late NotifiyDuration _notifiyDuration;
  late Color _textColor;
  late Color _fadeColor;

  @override
  void initState() {
    super.initState();
    _notifiyDuration = NotifiyDuration(widget.duration);
    _streamDurationListener();
    _durationTitle = widget.durationTitle ?? DurationTitle.en();
    _textColor = widget.textStyle.color ?? Colors.white;
    _fadeColor = (widget.textStyle.color ?? Colors.white)
        .withOpacity(widget.fade ? 0 : 1);
  }

  @override
  void didUpdateWidget(covariant SlideCountdown oldWidget) {
    if (widget.durationTitle != null) {
      _durationTitle = widget.durationTitle ?? DurationTitle.en();
    }
    if (widget.textStyle != oldWidget.textStyle ||
        widget.fade != oldWidget.fade) {
      _textColor = widget.textStyle.color ?? Colors.white;
      _fadeColor = (widget.textStyle.color ?? Colors.white)
          .withOpacity(widget.fade ? 0 : 1);
    }
    if (widget.countUp != oldWidget.countUp ||
        widget.infinityCountUp != oldWidget.infinityCountUp ||
        widget.duration != oldWidget.duration) {
      _streamDurationListener();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _streamDurationListener() {
    _streamDuration = StreamDuration(
      widget.duration,
      onDone: () {
        if (widget.onDone != null) {
          widget.onDone!();
        }
      },
      countUp: widget.countUp,
      infinity: widget.infinityCountUp,
    );

    _streamDuration.durationLeft.listen((event) {
      _notifiyDuration.streamDuration(event);
      _daysFirstDigit(event);
      _daysSecondDigit(event);

      _hoursFirstDigit(event);
      _hoursSecondDigit(event);

      _minutesFirstDigit(event);
      _minutesSecondDigit(event);

      _secondsFirstDigit(event);
      _secondsSecondDigit(event);
    });
  }

  void _daysFirstDigit(Duration duration) {
    int calculate = (duration.inDays) ~/ 10;
    if (calculate != _daysFirstDigitNotifier.value) {
      _daysFirstDigitNotifier.value = calculate;
    }
  }

  void _daysSecondDigit(Duration duration) {
    int calculate = (duration.inDays) % 10;
    if (calculate != _daysSecondDigitNotifier.value) {
      _daysSecondDigitNotifier.value = calculate;
    }
  }

  void _hoursFirstDigit(Duration duration) {
    int calculate = (duration.inHours % 24) ~/ 10;
    if (calculate != _hoursFirstDigitNotifier.value) {
      _hoursFirstDigitNotifier.value = calculate;
    }
  }

  void _hoursSecondDigit(Duration duration) {
    int calculate = (duration.inHours % 24) % 10;
    if (calculate != _hoursSecondDigitNotifier.value) {
      _hoursSecondDigitNotifier.value = calculate;
    }
  }

  void _minutesFirstDigit(Duration duration) {
    int calculate = (duration.inMinutes % 60) ~/ 10;
    if (calculate != _minutesFirstDigitNotifier.value) {
      _minutesFirstDigitNotifier.value = calculate;
    }
  }

  void _minutesSecondDigit(Duration duration) {
    int calculate = (duration.inMinutes % 60) % 10;
    if (calculate != _minutesSecondDigitNotifier.value) {
      _minutesSecondDigitNotifier.value = calculate;
    }
  }

  void _secondsFirstDigit(Duration duration) {
    int calculate = (duration.inSeconds % 60) ~/ 10;
    if (calculate != _secondsFirstDigitNotifier.value) {
      _secondsFirstDigitNotifier.value = calculate;
    }
  }

  void _secondsSecondDigit(Duration duration) {
    int calculate = (duration.inSeconds % 60) % 10;
    if (calculate != _secondsSecondDigitNotifier.value) {
      _secondsSecondDigitNotifier.value = calculate;
    }
  }

  void _disposeDaysNotifier() {
    _daysFirstDigitNotifier.dispose();
    _daysSecondDigitNotifier.dispose();
  }

  void _disposeHoursNotifier() {
    _hoursFirstDigitNotifier.dispose();
    _hoursSecondDigitNotifier.dispose();
  }

  void _disposeMinutesNotifier() {
    _minutesFirstDigitNotifier.dispose();
    _minutesSecondDigitNotifier.dispose();
  }

  void _disposeSecondsNotifier() {
    _secondsFirstDigitNotifier.dispose();
    _secondsSecondDigitNotifier.dispose();
  }

  @override
  void dispose() {
    _disposeHoursNotifier();
    _disposeMinutesNotifier();
    _disposeSecondsNotifier();
    _disposeDaysNotifier();
    _streamDuration.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _notifiyDuration,
      builder: (BuildContext context, Duration duration, Widget? child) {
        return DecoratedBox(
          decoration: widget.decoration,
          child: ClipRect(
            child: ShaderMask(
              shaderCallback: (Rect rect) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _fadeColor,
                    _textColor,
                    _textColor,
                    _fadeColor,
                  ],
                  stops: const [0.05, 0.3, 0.7, 0.95],
                ).createShader(rect);
              },
              child: Padding(
                padding: widget.padding,
                child: Visibility(
                  visible: widget.fade,
                  child: countdown(duration),
                  replacement: ClipRect(
                    child: countdown(duration),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget countdown(Duration duration) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Visibility(
          visible: widget.icon != null,
          child: widget.icon ?? const SizedBox.shrink(),
        ),
        Builder(builder: (context) {
          if (duration.inDays < 1 && !widget.showZeroValue) {
            return const SizedBox.shrink();
          } else {
            return Row(
              children: [
                TextAnimation(
                  value: _daysFirstDigitNotifier,
                  textStyle: widget.textStyle,
                  slideDirection: widget.slideDirection,
                  curve: widget.curve,
                  countUp: widget.countUp,
                ),
                TextAnimation(
                  value: _daysSecondDigitNotifier,
                  textStyle: widget.textStyle,
                  slideDirection: widget.slideDirection,
                  curve: widget.curve,
                  countUp: widget.countUp,
                  showZeroValue: !(duration.inHours < 1 &&
                      widget.separatorType == SeparatorType.title),
                ),
                Padding(
                  padding: widget.separatorPadding,
                  child: Visibility(
                    visible: widget.separatorType == SeparatorType.symbol,
                    child:
                        Text(widget.separator ?? ':', style: widget.textStyle),
                    replacement:
                        Text(_durationTitle.days, style: widget.textStyle),
                  ),
                ),
              ],
            );
          }
        }),
        Builder(builder: (context) {
          if (duration.inHours < 1 && !widget.showZeroValue) {
            return const SizedBox.shrink();
          } else {
            return Row(
              children: [
                TextAnimation(
                  value: _hoursFirstDigitNotifier,
                  textStyle: widget.textStyle,
                  slideDirection: widget.slideDirection,
                  curve: widget.curve,
                  countUp: widget.countUp,
                ),
                TextAnimation(
                  value: _hoursSecondDigitNotifier,
                  textStyle: widget.textStyle,
                  slideDirection: widget.slideDirection,
                  curve: widget.curve,
                  countUp: widget.countUp,
                  showZeroValue: !(duration.inHours < 1 &&
                      widget.separatorType == SeparatorType.title),
                ),
                Padding(
                  padding: widget.separatorPadding,
                  child: Visibility(
                    visible: widget.separatorType == SeparatorType.symbol,
                    child:
                        Text(widget.separator ?? ':', style: widget.textStyle),
                    replacement:
                        Text(_durationTitle.hours, style: widget.textStyle),
                  ),
                ),
              ],
            );
          }
        }),
        Builder(builder: (context) {
          if (duration.inMinutes < 1 &&
              widget.separatorType == SeparatorType.title) {
            return const SizedBox.shrink();
          } else {
            return Row(
              children: [
                TextAnimation(
                  value: _minutesFirstDigitNotifier,
                  textStyle: widget.textStyle,
                  slideDirection: widget.slideDirection,
                  curve: widget.curve,
                  countUp: widget.countUp,
                  showZeroValue: !(duration.inMinutes < 1 &&
                      widget.separatorType == SeparatorType.title),
                ),
                TextAnimation(
                  value: _minutesSecondDigitNotifier,
                  textStyle: widget.textStyle,
                  slideDirection: widget.slideDirection,
                  curve: widget.curve,
                  countUp: widget.countUp,
                  showZeroValue: !(duration.inMinutes < 1 &&
                      widget.separatorType == SeparatorType.title),
                ),
                Padding(
                  padding: widget.separatorPadding,
                  child: Visibility(
                    visible: widget.separatorType == SeparatorType.symbol,
                    child:
                        Text(widget.separator ?? ':', style: widget.textStyle),
                    replacement:
                        Text(_durationTitle.minutes, style: widget.textStyle),
                  ),
                ),
              ],
            );
          }
        }),
        TextAnimation(
          value: _secondsFirstDigitNotifier,
          textStyle: widget.textStyle,
          slideDirection: widget.slideDirection,
          curve: widget.curve,
          countUp: widget.countUp,
        ),
        TextAnimation(
          value: _secondsSecondDigitNotifier,
          textStyle: widget.textStyle,
          slideDirection: widget.slideDirection,
          curve: widget.curve,
          countUp: widget.countUp,
        ),
        Visibility(
          visible: widget.separatorType == SeparatorType.title,
          child: Padding(
            padding: widget.separatorPadding,
            child: Text(_durationTitle.seconds, style: widget.textStyle),
          ),
        ),
        Visibility(
          visible: widget.sufixIcon != null,
          child: widget.sufixIcon ?? const SizedBox.shrink(),
        ),
      ],
    );
  }
}
