part of 'slide_countdown.dart';

class SlideCountdownSeparated extends StatefulWidget {
  const SlideCountdownSeparated({
    Key? key,
    required this.duration,
    this.height = 30,
    this.width = 30,
    this.textStyle =
        const TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.bold),
    this.separatorStyle =
        const TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.bold),
    this.icon,
    this.sufixIcon,
    this.separator,
    this.onDone,
    this.durationTitle,
    this.separatorType = SeparatorType.symbol,
    this.slideDirection = SlideDirection.down,
    this.padding = const EdgeInsets.all(5),
    this.separatorPadding = const EdgeInsets.symmetric(horizontal: 3),
    this.withDays = false,
    this.showZeroValue = false,
    this.fade = false,
    this.decoration = const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(4)),
      color: Color(0xFFF23333),
    ),
    this.curve = Curves.easeOut,
    this.countUp = false,
    this.infinityCountUp = false,
  }) : super(key: key);

  /// [Duration] is the duration of the countdown slide,
  /// if the duration has finished it will call [onDone]
  final Duration duration;

  /// height to set the size of height each [Container]
  /// [Container] will be the background of each a duration
  /// to decorate the [Container] on the [decoration] property
  final double height;

  /// width to set the size of width each [Container]
  /// [Container] will be the background of each a duration
  /// to decorate the [Container] on the [decoration] property
  final double width;

  /// [TextStyle] is a parameter for all existing text,
  /// if this is null [SlideCountdownSeparated] has a default
  /// text style which will be of all text
  final TextStyle textStyle;

  /// [TextStyle] is a parameter for all existing text,
  /// if this is null [SlideCountdownSeparated] has a default
  /// text style which will be of all text
  final TextStyle separatorStyle;

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

  /// if you give or the remaining [duration] is less than one hour
  /// and the property is set to true, the countdown hours will not show
  final bool withDays;

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
  _SlideCountdownSeparatedState createState() =>
      _SlideCountdownSeparatedState();
}

class _SlideCountdownSeparatedState extends State<SlideCountdownSeparated> {
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
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _setDigits(widget.duration);
    _notifiyDuration = NotifiyDuration(widget.duration);
    _streamDurationListener();
    _durationTitle = widget.durationTitle ?? DurationTitle.en();
    _textColor = widget.textStyle.color ?? Colors.white;
    _fadeColor = (widget.textStyle.color ?? Colors.white)
        .withOpacity(widget.fade ? 0 : 1);
  }

  @override
  void didUpdateWidget(covariant SlideCountdownSeparated oldWidget) {
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
      if (_disposed) return;
      if (event.inSeconds <= 0 && !widget.infinityCountUp) return;
      _notifiyDuration.streamDuration(event);
      _setDigits(event);
    });
  }

  void _setDigits(Duration duration) {
    _daysFirstDigit(duration);
    _daysSecondDigit(duration);

    _hoursFirstDigit(duration);
    _hoursSecondDigit(duration);

    _minutesFirstDigit(duration);
    _minutesSecondDigit(duration);

    _secondsFirstDigit(duration);
    _secondsSecondDigit(duration);
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
    _disposed = true;
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
        return countdown(duration);
      },
    );
  }

  Widget countdown(Duration duration) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) widget.icon! else const SizedBox.shrink(),
        daysWidget(duration),
        separator(
          title: _durationTitle.days,
          visible: !(duration.inDays < 1 &&
              !widget.showZeroValue &&
              !widget.withDays),
        ),
        hoursWidget(duration),
        separator(
          title: _durationTitle.hours,
          visible: !(duration.inHours < 1 && !widget.showZeroValue),
        ),
        minutesWidget(duration),
        separator(
          title: _durationTitle.minutes,
          visible: !(duration.inMinutes < 1 && !widget.showZeroValue),
        ),
        secondsWidget(duration),
        separatorSeconds(),
        if (widget.sufixIcon != null)
          widget.sufixIcon!
        else
          const SizedBox.shrink()
      ],
    );
  }

  Widget boxDecoration({required Widget child}) {
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: widget.decoration,
      clipBehavior: Clip.hardEdge,
      alignment: Alignment.center,
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
        child: Visibility(
          visible: widget.fade,
          child: SizedBox.expand(child: child),
          replacement: ClipRect(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  Widget daysWidget(Duration duration) {
    return Builder(builder: (context) {
      if (duration.inDays < 1 && !widget.showZeroValue && !widget.withDays) {
        return const SizedBox.shrink();
      } else {
        return boxDecoration(
          child: Row(
            children: [
              Expanded(
                child: TextAnimation(
                  value: _daysFirstDigitNotifier,
                  textStyle: widget.textStyle,
                  slideDirection: widget.slideDirection,
                  curve: widget.curve,
                  countUp: widget.countUp,
                ),
              ),
              Expanded(
                child: TextAnimation(
                  value: _daysSecondDigitNotifier,
                  textStyle: widget.textStyle,
                  slideDirection: widget.slideDirection,
                  curve: widget.curve,
                  countUp: widget.countUp,
                  showZeroValue: !(duration.inHours < 1 &&
                      widget.separatorType == SeparatorType.title),
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  Widget hoursWidget(Duration duration) {
    return Builder(builder: (context) {
      if (duration.inHours < 1 && !widget.showZeroValue) {
        return const SizedBox.shrink();
      } else {
        return boxDecoration(
          child: Row(
            children: [
              Expanded(
                child: TextAnimation(
                  value: _hoursFirstDigitNotifier,
                  textStyle: widget.textStyle,
                  slideDirection: widget.slideDirection,
                  curve: widget.curve,
                  countUp: widget.countUp,
                ),
              ),
              Expanded(
                child: TextAnimation(
                  value: _hoursSecondDigitNotifier,
                  textStyle: widget.textStyle,
                  slideDirection: widget.slideDirection,
                  curve: widget.curve,
                  countUp: widget.countUp,
                  showZeroValue: !(duration.inHours < 1 &&
                      widget.separatorType == SeparatorType.title),
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  Widget minutesWidget(Duration duration) {
    return Builder(builder: (context) {
      if (duration.inMinutes < 1 &&
          widget.separatorType == SeparatorType.title) {
        return const SizedBox.shrink();
      } else {
        return boxDecoration(
          child: Row(
            children: [
              Expanded(
                child: TextAnimation(
                  value: _minutesFirstDigitNotifier,
                  textStyle: widget.textStyle,
                  slideDirection: widget.slideDirection,
                  curve: widget.curve,
                  countUp: widget.countUp,
                  showZeroValue: !(duration.inMinutes < 1 &&
                      widget.separatorType == SeparatorType.title),
                ),
              ),
              Expanded(
                child: TextAnimation(
                  value: _minutesSecondDigitNotifier,
                  textStyle: widget.textStyle,
                  slideDirection: widget.slideDirection,
                  curve: widget.curve,
                  countUp: widget.countUp,
                  showZeroValue: !(duration.inMinutes < 1 &&
                      widget.separatorType == SeparatorType.title),
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  Widget secondsWidget(Duration duration) {
    return boxDecoration(
      child: Row(
        children: [
          Expanded(
            child: TextAnimation(
              value: _secondsFirstDigitNotifier,
              textStyle: widget.textStyle,
              slideDirection: widget.slideDirection,
              curve: widget.curve,
              countUp: widget.countUp,
            ),
          ),
          Expanded(
            child: TextAnimation(
              value: _secondsSecondDigitNotifier,
              textStyle: widget.textStyle,
              slideDirection: widget.slideDirection,
              curve: widget.curve,
              countUp: widget.countUp,
            ),
          ),
        ],
      ),
    );
  }

  Widget separator({required String title, bool visible = true}) {
    return Visibility(
      visible: visible,
      child: Padding(
        padding: widget.separatorPadding,
        child: Visibility(
          visible: widget.separatorType == SeparatorType.symbol,
          child: Text(widget.separator ?? ':', style: widget.separatorStyle),
          replacement: Text(title, style: widget.separatorStyle),
        ),
      ),
    );
  }

  Widget separatorSeconds() {
    return Visibility(
      visible: widget.separatorType == SeparatorType.title,
      child: Padding(
        padding: widget.separatorPadding,
        child: Text(_durationTitle.seconds, style: widget.separatorStyle),
      ),
    );
  }
}
