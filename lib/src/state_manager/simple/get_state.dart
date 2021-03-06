import 'dart:collection';
import 'package:flutter/widgets.dart';
import 'package:get/src/instance/get_instance.dart';
import 'package:get/src/navigation/root/smart_management.dart';
import 'package:get/src/state_manager/rx/rx_interface.dart';

typedef Disposer = void Function();

class GetxController extends DisposableInterface {
  final HashSet<StateSetter> _updaters = HashSet<StateSetter>();

  final HashMap<String, StateSetter> _updatersIds =
      HashMap<String, StateSetter>();

  /// Update GetBuilder with update();
  void update([List<String> ids, bool condition = true]) {
    if (!condition) return;
    (ids == null)
        ? _updaters.forEach((rs) => rs(() {}))
        : ids.forEach((element) {
            _updatersIds[element]?.call(() {});
          });
  }

  Disposer addListener(StateSetter listener) {
    _updaters.add(listener);
    return () => _updaters.remove(listener);
  }

  // void removeListener(StateSetter listener) {
  //   _updaters.remove(listener);
  // }

  Disposer addListenerId(String key, StateSetter listener) {
    _updatersIds[key] = listener;
    return () => _updatersIds.remove(key);
  }

  void disposeKey(String key) => _updatersIds.remove(key);

  @override
  void onInit() async {}

  @override
  void onReady() async {}

  @override
  void onClose() async {}
}

// class GetBuilder<T extends GetxController> extends StatefulWidget {
//   final Widget Function(T) builder;
//   final bool global;
//   final String id;
//   final String tag;
//   final bool autoRemove;
//   final bool assignId;
//   final void Function(State state) initState, dispose, didChangeDependencies;
//   final void Function(GetBuilder oldWidget, State state) didUpdateWidget;
//   final T init;
//   const GetBuilder({
//     Key key,
//     this.init,
//     this.global = true,
//     @required this.builder,
//     this.autoRemove = true,
//     this.assignId = false,
//     this.initState,
//     this.tag,
//     this.dispose,
//     this.id,
//     this.didChangeDependencies,
//     this.didUpdateWidget,
//   })  : assert(builder != null),
//         super(key: key);
//   @override
//   _GetBuilderState<T> createState() => _GetBuilderState<T>();
// }

// class _GetBuilderState<T extends GetxController> extends State<GetBuilder<T>> {
//   GetxController controller;
//   bool isCreator = false;
//   @override
//   void initState() {
//     super.initState();

//     if (widget.initState != null) widget.initState(this);
//     if (widget.global) {
//       final isPrepared = GetInstance().isPrepared<T>(tag: widget.tag);
//       final isRegistred = GetInstance().isRegistred<T>(tag: widget.tag);

//       if (isPrepared) {
//         if (GetConfig.smartManagement != SmartManagement.keepFactory) {
//           isCreator = true;
//         }
//         controller = GetInstance().find<T>(tag: widget.tag);
//       } else if (isRegistred) {
//         controller = GetInstance().find<T>(tag: widget.tag);
//         isCreator = false;
//       } else {
//         controller = widget.init;
//         isCreator = true;
//         GetInstance().put<T>(controller, tag: widget.tag);
//       }
//     } else {
//       controller = widget.init;
//       isCreator = true;
//       controller?.onStart();
//     }

//     if (widget.global &&
//         GetConfig.smartManagement == SmartManagement.onlyBuilder) {
//       controller?.onStart();
//     }
//     (widget.id == null)
//         ? controller.addListener(setState)
//         : controller.addListenerId(widget.id, setState);
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     if (widget.dispose != null) widget.dispose(this);
//     if (isCreator || widget.assignId) {
//       if (widget.autoRemove && GetInstance().isRegistred<T>(tag: widget.tag)) {
//         (widget.id == null)
//             ? controller.removeListener(setState)
//             : controller.removeListenerId(widget.id);
//         GetInstance().delete<T>(tag: widget.tag);
//       }
//     } else {
//       (widget.id == null)
//           ? controller.removeListener(setState)
//           : controller.removeListenerId(widget.id);
//     }
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     if (widget.didChangeDependencies != null) {
//       widget.didChangeDependencies(this);
//     }
//   }

//   @override
//   void didUpdateWidget(GetBuilder oldWidget) {
//     super.didUpdateWidget(oldWidget as GetBuilder<T>);
//     if (widget.didUpdateWidget != null) widget.didUpdateWidget(oldWidget, this);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return widget.builder(controller);
//   }
// }

// class Updater {
//   final StateSetter updater;
//   final String id;
//   const Updater({this.updater, this.id});
// }

// typedef UpdaterBuilder = Updater Function();

class GetBuilder<T extends GetxController> extends StatefulWidget {
  final Widget Function(T) builder;
  final bool global;
  final String id;
  final String tag;
  final bool autoRemove;
  final bool assignId;
  final void Function(State state) initState, dispose, didChangeDependencies;
  final void Function(GetBuilder oldWidget, State state) didUpdateWidget;
  final T init;
  const GetBuilder({
    Key key,
    this.init,
    this.global = true,
    @required this.builder,
    this.autoRemove = true,
    this.assignId = false,
    this.initState,
    this.tag,
    this.dispose,
    this.id,
    this.didChangeDependencies,
    this.didUpdateWidget,
  })  : assert(builder != null),
        super(key: key);
  @override
  _GetBuilderState<T> createState() => _GetBuilderState<T>();
}

class _GetBuilderState<T extends GetxController> extends State<GetBuilder<T>> {
  GetxController controller;
  bool isCreator = false;
  final HashSet<Disposer> disposers = HashSet<Disposer>();
  Disposer remove;

  @override
  void initState() {
    super.initState();

    if (widget.initState != null) widget.initState(this);
    if (widget.global) {
      final isPrepared = GetInstance().isPrepared<T>(tag: widget.tag);
      final isRegistered = GetInstance().isRegistered<T>(tag: widget.tag);

      if (isPrepared) {
        if (GetConfig.smartManagement != SmartManagement.keepFactory) {
          isCreator = true;
        }
        controller = GetInstance().find<T>(tag: widget.tag);
      } else if (isRegistered) {
        controller = GetInstance().find<T>(tag: widget.tag);
        isCreator = false;
      } else {
        controller = widget.init;
        isCreator = true;
        GetInstance().put<T>(controller, tag: widget.tag);
      }
    } else {
      controller = widget.init;
      isCreator = true;
      controller?.onStart();
    }

    if (widget.global &&
        GetConfig.smartManagement == SmartManagement.onlyBuilder) {
      controller?.onStart();
    }
    remove = (widget.id == null)
        ? controller?.addListener(setState)
        : controller?.addListenerId(widget.id, setState);
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.dispose != null) widget.dispose(this);
    if (isCreator || widget.assignId) {
      if (widget.autoRemove && GetInstance().isRegistered<T>(tag: widget.tag)) {
        if (remove != null) remove();

        GetInstance().delete<T>(tag: widget.tag);
      }
    } else {
      if (remove != null) remove();
    }

    disposers.forEach((element) {
      element();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.didChangeDependencies != null) {
      widget.didChangeDependencies(this);
    }
  }

  @override
  void didUpdateWidget(GetBuilder oldWidget) {
    super.didUpdateWidget(oldWidget as GetBuilder<T>);
    if (widget.didUpdateWidget != null) widget.didUpdateWidget(oldWidget, this);
  }

  Widget get notifyChildren {
    final old = Value._remove;
    Value._remove = disposers;
    final observer = Value._setter;
    Value._setter = setState;
    final result = widget.builder(controller);
    Value._setter = observer;
    Value._remove = old;
    return result;
  }

  @override
  Widget build(BuildContext context) => notifyChildren;
}

class Value<T> extends GetxController {
  Value([this._value]);
  T _value;

  T get value {
    if (_setter != null) {
      if (!_updaters.contains(_setter)) {
        final add = addListener(_setter);
        _remove.add(add);
      }
    }
    return _value;
  }

  static StateSetter _setter;

  static HashSet<Disposer> _remove;

  set value(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    update();
  }
}

class SimpleBuilder extends StatefulWidget {
  final Widget Function(BuildContext) builder;
  const SimpleBuilder({Key key, @required this.builder})
      : assert(builder != null),
        super(key: key);
  @override
  _SimpleBuilderState createState() => _SimpleBuilderState();
}

class _SimpleBuilderState extends State<SimpleBuilder> {
  final HashSet<Disposer> disposers = HashSet<Disposer>();

  @override
  void dispose() {
    super.dispose();
    disposers.forEach((element) => element());
  }

  @override
  Widget build(BuildContext context) {
    HashSet<Disposer> old = Value._remove;
    Value._remove = disposers;
    StateSetter observer = Value._setter;
    Value._setter = setState;
    Widget result = widget.builder(context);
    Value._remove = old;
    Value._setter = observer;
    return result;
  }
}
