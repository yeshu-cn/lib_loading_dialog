import 'package:flutter/material.dart';
import 'package:loading_dialog/loading_dialog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // button show loading dialog
            ElevatedButton(
                onPressed: () {
                  showLoadingDialog(context, barrierDismissible: true);
                },
                child: const Text('show loading dialog')),
            const SizedBox(
              height: 40,
            ),
            // button show progress dialog
            ElevatedButton(
                onPressed: () {
                  showDownloadSuccess(context);
                },
                child: const Text('show download dialog success')),
            const SizedBox(
              height: 40,
            ),
            // button show progress dialog
            ElevatedButton(
                onPressed: () {
                  showDownloadFailed(context);
                },
                child: const Text('show download dialog failed')),
          ],
        ),
      ),
    );
  }

  void showDownloadSuccess(BuildContext context) async {
    final dialog = showProgressDialog(context, msg: 'downloading...');
    // 模拟下载10秒，每秒更新一次进度
    for (var i = 0; i < 10; i++) {
      await Future.delayed(const Duration(seconds: 1), () {
        dialog.updateProgress(progress: i / 10.0, msg: 'downloading...');
      });
    }

    // 下载完成
    dialog.complete('download complete');
  }

  void showDownloadFailed(BuildContext context) async {
    final dialog = showProgressDialog(context, msg: 'downloading...');
    // 模拟下载10秒，每秒更新一次进度
    for (var i = 0; i < 10; i++) {
      await Future.delayed(const Duration(seconds: 1), () {
        dialog.updateProgress(progress: i / 10.0, msg: 'downloading...');
      });
    }

    // 下载完成
    dialog.completeWithError('download failed');
  }

}
