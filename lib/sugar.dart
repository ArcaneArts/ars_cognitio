import 'package:ars_cognitio/model/data.dart';
import 'package:ars_cognitio/services/ai_service.dart';
import 'package:ars_cognitio/services/audio_service.dart';
import 'package:ars_cognitio/services/chat_service.dart';
import 'package:ars_cognitio/services/data_service.dart';
import 'package:ars_cognitio/services/diffusion_service.dart';
import 'package:ars_cognitio/services/gcp_service.dart';
import 'package:ars_cognitio/services/openai_service.dart';
import 'package:ars_cognitio/services/playht_service.dart';
import 'package:fast_log/fast_log.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:precision_stopwatch/precision_stopwatch.dart';
import 'package:synchronized/synchronized.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget animatedSwitch(Widget w, [int ms = 3000]) => AnimatedSwitcher(
      duration: Duration(milliseconds: ms),
      switchOutCurve: Curves.easeOutExpo,
      switchInCurve: Curves.easeOutCirc,
      child: Stack(
        key: UniqueKey(),
        fit: StackFit.passthrough,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: w,
          )
        ],
      ),
    );

Widget animatedSwitchLinear(Widget w, [int ms = 3000]) => AnimatedSwitcher(
      duration: Duration(milliseconds: ms),
      switchOutCurve: Curves.linear,
      switchInCurve: Curves.linear,
      child: Stack(
        key: UniqueKey(),
        fit: StackFit.passthrough,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: w,
          )
        ],
      ),
    );

Widget animatedSwitchText(Widget w, [int ms = 3000]) => AnimatedSwitcher(
      duration: Duration(milliseconds: ms),
      switchOutCurve: Curves.easeOutExpo,
      switchInCurve: Curves.easeOutCirc,
      child: Stack(
        key: UniqueKey(),
        fit: StackFit.passthrough,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: w,
          )
        ],
      ),
    );

Widget animatedSwitchSymetrical(Widget w, [int ms = 750]) => AnimatedSwitcher(
      duration: Duration(milliseconds: ms),
      switchOutCurve: Curves.easeInOutCirc,
      switchInCurve: Curves.easeInOutCirc,
      child: Stack(
        key: UniqueKey(),
        fit: StackFit.passthrough,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: w,
          )
        ],
      ),
    );

class FadeOut extends StatefulWidget {
  final Widget? child;
  final Duration? duration;
  final Duration? delay;
  final Curve? curve;

  const FadeOut({Key? key, this.child, this.delay, this.duration, this.curve})
      : super(key: key);

  @override
  _FadeOutState createState() => _FadeOutState();
}

class _FadeOutState extends State<FadeOut> {
  bool go = false;
  bool disposed = false;

  @override
  void initState() {
    Future.delayed(widget.delay ?? const Duration(seconds: 1), () {
      if (disposed) {
        return;
      }

      setState(() => go = true);
    });
    super.initState();
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
        opacity: go ? 0 : 1,
        duration: widget.duration ?? const Duration(seconds: 1),
        curve: widget.curve ?? Curves.easeInOut,
        child: widget.child ?? Container(),
      );
}

Box hiveNow(String box) => Hive.box("ac$box");

Lock _lock = Lock();

void saveData(Function(Data d) f) {
  Data data = dataService().data();
  f(data);
  dataService().save();
}

Data data() => dataService().data();

Future<Box> hive(String box) async {
  if (Hive.isBoxOpen("ac$box")) {
    return Hive.box("ac$box");
  }

  return Hive.openBox("ac$box").then((value) {
    success(
        "Initialized Hive Box ${value.name} with ${value.keys.length} keys");
    return value;
  });
}

Future<LazyBox> hiveLazy(String box) => _lock.synchronized(() async {
      if (Hive.isBoxOpen("ac$box")) {
        return Hive.lazyBox("ac$box");
      }

      return Hive.openLazyBox("ac$box").then((value) {
        success(
            "Initialized Lazy Hive Box ${value.name} with ${value.keys.length} keys");
        return value;
      });
    });

AudioService audioService() => services().get();

PlayhtService playhtService() => services().get();

ChatService chatService() => services().get();

AIService aiService() => services().get();

GoogleCloudService gcpService() => services().get();

OpenAIService openaiService() => services().get();

DiffusionService stableDiffusionService() => services().get();

DataService dataService() => services().get();

abstract class AsyncStartupTasked {
  Future<void> onStartupTask();
}

abstract class ArsCognitioStatelessService extends ArsCognitioService {
  @override
  void onStart() {}

  @override
  void onStop() {}
}

enum ArsCognitioServiceState {
  offline,
  online,
  starting,
  stopping,
  failed,
}

typedef ArsCognitioServiceConstructor<T extends ArsCognitioService> = T
    Function();

ArsCognitioServiceProvider? _serviceProvider;

Box? serviceBox;

ArsCognitioServiceProvider services() {
  _serviceProvider ??= ArsCognitioServiceProvider._createStandard();
  return _serviceProvider!;
}

class ArsCognitioServiceProvider {
  List<Future<void>> tasks = [];
  Map<Type, ArsCognitioService> services = {};
  Map<Type, ArsCognitioServiceConstructor<dynamic>> constructors = {};

  ArsCognitioServiceProvider._();

  Future<void> waitForStartup() =>
      Future.wait(tasks).then((value) => tasks = []);

  factory ArsCognitioServiceProvider._createStandard() {
    ArsCognitioServiceProvider provider = ArsCognitioServiceProvider._();
    return provider;
  }

  void register<T extends ArsCognitioService>(
      ArsCognitioServiceConstructor<T> constructor,
      {bool lazy = true}) {
    constructors.putIfAbsent(T, () => constructor);
    verbose("Registered Service $T");
    if (!lazy) {
      verbose("Auto-starting Service $T");
      get<T>();
    }
  }

  T get<T extends ArsCognitioService>() {
    T t = getQuiet();

    if (t.state == ArsCognitioServiceState.offline ||
        t.state == ArsCognitioServiceState.failed) {
      t.startService();
    }

    return t;
  }

  T getQuiet<T extends ArsCognitioService>() {
    if (!services.containsKey(T)) {
      if (!constructors.containsKey(T)) {
        throw Exception("No service registered for type $T");
      }

      services.putIfAbsent(T, () => constructors[T]!());
    }

    return services[T] as T;
  }
}

abstract class ArsCognitioService {
  ArsCognitioServiceState _state = ArsCognitioServiceState.offline;
  ArsCognitioServiceState get state => _state;
  String get name => runtimeType.toString().replaceAll("Service", "");

  void restartService() {
    PrecisionStopwatch p = PrecisionStopwatch.start();
    verbose("Restarting $name Service");
    stopService();
    startService();
    verbose("Restarted $name Service in ${p.getMilliseconds()}ms");
  }

  void startService() {
    if (!(_state == ArsCognitioServiceState.offline ||
        _state == ArsCognitioServiceState.failed)) {
      throw Exception("$name Service cannot be started while $state");
    }

    PrecisionStopwatch p = PrecisionStopwatch.start();
    _state = ArsCognitioServiceState.starting;
    verbose("Starting $name Service");

    try {
      if (this is AsyncStartupTasked) {
        PrecisionStopwatch px = PrecisionStopwatch.start();
        verbose("Queued Startup Task: $name");
        services()
            .tasks
            .add((this as AsyncStartupTasked).onStartupTask().then((value) {
              success(
                  "Completed $name Startup Task in ${px.getMilliseconds()}ms");
            }));
      }

      onStart();
      _state = ArsCognitioServiceState.online;
    } catch (e, es) {
      _state = ArsCognitioServiceState.failed;
      error("Failed to start $name Service: $e");
      error(es);
    }

    if (_state == ArsCognitioServiceState.starting) {
      _state = ArsCognitioServiceState.failed;
    }

    if (_state == ArsCognitioServiceState.failed) {
      warn(
          "Failed to start $name Service! It will be offline until you restart the app or the service is re-requested.");
    } else {
      success("Started $name Service in ${p.getMilliseconds()}ms");
    }
  }

  void stopService() {
    if (!(_state == ArsCognitioServiceState.online)) {
      throw Exception("$name Service cannot be stopped while $state");
    }

    PrecisionStopwatch p = PrecisionStopwatch.start();
    _state = ArsCognitioServiceState.stopping;
    verbose("Stopping $name Service");

    try {
      onStop();
      _state = ArsCognitioServiceState.offline;
    } catch (e, es) {
      _state = ArsCognitioServiceState.offline;
      error("Failed while stopping $name Service: $e");
      error(es);
    }

    if (_state == ArsCognitioServiceState.failed) {
      warn("Failed to stop $name Service! It is still marked as offline.");
    } else {
      success("Stopped $name Service in ${p.getMilliseconds()}ms");
    }
  }

  void onStart();

  void onStop();
}
