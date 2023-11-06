import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

LoadingDialog showLoadingDialog(BuildContext context, {String? msg, bool barrierDismissible = false}) {
  LoadingDialog dialog = LoadingDialog(context: context);
  dialog.show(msg: msg ?? '加载中...', barrierDismissible: barrierDismissible, showProgress: false);
  return dialog;
}

LoadingDialog showProgressDialog(BuildContext context, {String? msg, bool barrierDismissible = false}) {
  LoadingDialog dialog = LoadingDialog(context: context);
  dialog.show(msg: msg ?? '加载中...', barrierDismissible: barrierDismissible, showProgress: true);
  return dialog;
}

class LoadingDialogData {
  String msg;

  // 进度0-1
  double progress;

  // 显示完成动画，并关闭对话框
  bool complete;

  // 显示错误动画，并关闭对话框
  bool error;

  // 完成，错误界面的显示时间
  Duration delayDuration;

  bool showProgress;

  LoadingDialogData({
    required this.msg,
    required this.progress,
    required this.complete,
    required this.error,
    required this.delayDuration,
    required this.showProgress,
  });

  LoadingDialogData copyWith({
    String? msg,
    double? progress,
    bool? complete,
    bool? error,
    Duration? delayDuration,
    bool? showProgress,
  }) {
    return LoadingDialogData(
      msg: msg ?? this.msg,
      progress: progress ?? this.progress,
      complete: complete ?? this.complete,
      error: error ?? this.error,
      delayDuration: delayDuration ?? this.delayDuration,
      showProgress: showProgress ?? this.showProgress,
    );
  }
}

class LoadingDialog {
  final ValueNotifier<LoadingDialogData> _data = ValueNotifier(LoadingDialogData(
      error: false,
      complete: false,
      progress: 0,
      msg: 'Loading',
      delayDuration: const Duration(milliseconds: 2000),
      showProgress: false));

  /// [_dialogIsOpen] Shows whether the dialog is open.
  //  Not directly accessible.
  bool _dialogIsOpen = false;

  /// [_context] Required to show the alert.
  // Can only be accessed with the constructor.
  late BuildContext _context;

  LoadingDialog({required context}) {
    _context = context;
  }

  void updateProgress({required double progress, String? msg}) {
    if (progress < 0) {
      progress = 0;
    }
    if (progress > 1) {
      progress = 1;
    }
    _data.value = _data.value.copyWith(progress: progress, msg: msg);
  }

  void updateMessage({required String msg, bool showProgress = true}) {
    _data.value = _data.value.copyWith(msg: msg, showProgress: showProgress);
  }

  void complete(String msg, {Duration? delayDuration}) {
    _data.value = _data.value.copyWith(complete: true, msg: msg, delayDuration: delayDuration);
  }

  void completeWithError(String msg, {Duration? delayDuration}) {
    _data.value = _data.value.copyWith(error: true, msg: msg, delayDuration: delayDuration);
  }

  /// [dismiss] Closes the progress dialog.
  void dismiss() {
    if (_dialogIsOpen) {
      Navigator.pop(_context);
      _dialogIsOpen = false;
    }
  }

  ///[isOpen] Returns whether the dialog box is open.
  bool isOpen() {
    return _dialogIsOpen;
  }

  show({
    required String msg,
    bool barrierDismissible = true,
    bool showProgress = true,
  }) {
    _dialogIsOpen = true;
    _data.value = _data.value.copyWith(msg: msg, showProgress: showProgress);
    return showDialog(
      barrierDismissible: barrierDismissible,
      context: _context,
      builder: (context) => WillPopScope(
        child: AlertDialog(
          insetPadding: const EdgeInsets.all(100.0),
          elevation: 5,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          content: ValueListenableBuilder(
            valueListenable: _data,
            builder: (BuildContext context, LoadingDialogData value, Widget? child) {
              if (value.complete || value.error) {
                Future.delayed(_data.value.delayDuration, () {
                  dismiss();
                });
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 45.0,
                    height: 45.0,
                    child: LoadingDialogIndicator(complete: _data.value.complete, error: _data.value.error),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    _data.value.msg,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _getMessageTextStyle(),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  if (_data.value.showProgress && !_data.value.complete && !_data.value.error)
                    Text(
                      '${(_data.value.progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 17,
                        color: Color(0xff353535),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        onWillPop: () {
          if (barrierDismissible) {
            _dialogIsOpen = false;
          }
          return Future.value(barrierDismissible);
        },
      ),
    );
  }

  TextStyle _getMessageTextStyle() {
    if (_data.value.showProgress) {
      return const TextStyle(
        fontSize: 12,
        color: Color(0xff6f6f6f),
      );
    } else {
      return const TextStyle(
        fontSize: 16,
        color: Color(0xff6f6f6f),
      );
    }
  }
}

class LoadingDialogIndicator extends StatefulWidget {
  final bool complete;
  final bool error;

  const LoadingDialogIndicator({Key? key, required this.complete, required this.error}) : super(key: key);

  @override
  State<LoadingDialogIndicator> createState() => _LoadingDialogIndicatorState();
}

class _LoadingDialogIndicatorState extends State<LoadingDialogIndicator> with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.complete) {
      return Lottie.asset('packages/lib_loading_dialog/assets/anim/load_success.json', controller: _controller, onLoaded: (composition) {
        _controller.duration = const Duration(milliseconds: 1000 * 1);
        _controller.forward();
      });
    } else if (widget.error) {
      return Lottie.asset('packages/lib_loading_dialog/assets/anim/load_failed.json', controller: _controller, onLoaded: (composition) {
        _controller.duration = const Duration(milliseconds: 1000 * 1);
        _controller.forward();
      });
    } else {
      return Lottie.asset('packages/lib_loading_dialog/assets/anim/loading.json');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
