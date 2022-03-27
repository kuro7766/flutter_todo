import 'package:flutter/material.dart';
import 'package:flutter_todo/async_mutex.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  var currentIndex = 0;
  var pageController = PageController();
  var colors = [Colors.transparent, Colors.green, Colors.blue, Colors.yellow];
  var radius = 20.0;
  var textEditController = TextEditingController();
  List t0=[];
  List t1=[];
  var showCancel = false.obs;
  var initialize = false;
  var itemH = 50.0;
  AsyncMutex asyncMutex = AsyncMutex();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      () async {
        await GetStorage().initStorage;

        t0 = GetStorage().read('0') ?? [];
        t1 = GetStorage().read('1') ?? [];

        initialize = true;
        setState(() {});
      }();
    });
  }

  void save() {
    asyncMutex.run(() async {
      await GetStorage().write('0', t0);
      await GetStorage().write('1', t1);
    });
  }

  @override
  Widget build(BuildContext context) {
    // if (!initialize) {
    //   return Container();
    // }
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.today_outlined),
            title: Text('Todo'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.find_in_page_rounded),
            title: Text('已完成'),
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.settings),
          //   title: Text('设置'),
          // ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.person),
          //   title: Text('我'),
          // ),
        ],
        currentIndex: currentIndex,
        onTap: (index) {
          currentIndex = index;
          pageController.animateToPage(index,
              duration: const Duration(milliseconds: 200), curve: Curves.ease);
          setState(() {});
        },
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: PageView(
          onPageChanged: (index) {
            currentIndex = index;
            setState(() {});
          },
          controller: pageController,
          children: [
            Builder(builder: (context) {
              return SafeArea(
                  child: Column(
                children: [
                  Expanded(
                      child: ListView.builder(
                    itemBuilder: (c, i) {
                      var isChecked = false;
                      return SizedBox(
                        height: itemH,
                        child: GestureDetector(
                          onTap: (){
                            var s = t0[i];
                            t0.removeAt(i);
                            t0.insert(0, s);
                            save();

                            // var s = t1[i];
                            // t1.removeAt(i);
                            // t0.insert(0, s);
                            // save();
                            setState(() {});
                          },
                          onLongPress: () {
                            var s = t0[i];
                            t0.removeAt(i);
                            t1.insert(0, s);
                            save();

                            // var s = t1[i];
                            // t1.removeAt(i);
                            // t0.insert(0, s);
                            // save();
                            setState(() {});
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: Padding(
                              padding: EdgeInsets.only(right: 18),
                              child: GestureDetector(
                                child: Container(
                                  color: Colors.transparent,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [Text(t0[i])].reversed.toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    reverse: true,
                    physics: BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    itemCount: t0.length,
                  )),
                  SizedBox(
                    height: 100,
                    child: Stack(
                      children: [
                        Center(
                          child: AnimatedPadding(
                              duration: Duration(milliseconds: 200),
                              padding: EdgeInsets.only(
                                  left: 15,
                                  right: 15.0 + (showCancel.value ? 35 : 0)),
                              child: Focus(
                                onFocusChange: (hasFocus) {
                                  showCancel.value = hasFocus;
                                  print(hasFocus);
                                  setState(() {});
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 18.0, right: 18),
                                  child: TextField(
                                    autofocus: true,
                                    onSubmitted: (str) {
                                      t0.insert(0, str);
                                      textEditController.text = '';
                                      setState(() {});
                                      save();
                                    },
                                    controller: textEditController,
                                    decoration: new InputDecoration(
                                      errorText: true
                                          ? (true ? null : '该字段不能为空')
                                          : null,
                                      labelText: '做什么?',
                                      focusedBorder: new OutlineInputBorder(
                                        borderSide: new BorderSide(),
                                        borderRadius: const BorderRadius.all(
                                          const Radius.circular(30.0),
                                        ),
                                      ),
                                      border: new OutlineInputBorder(
                                        borderSide: new BorderSide(),
                                        borderRadius: const BorderRadius.all(
                                          const Radius.circular(30.0),
                                        ),
                                      ),
                                      enabledBorder: new OutlineInputBorder(
                                        borderSide: new BorderSide(),
                                        borderRadius: const BorderRadius.all(
                                          const Radius.circular(30.0),
                                        ),
                                      ),
                                      // filled: true,
                                      // hintStyle: new TextStyle(color: Colors.grey[800]),
                                      // hintText: "用户名",
                                    ),
                                  ),
                                ),
                              )),
                        ),
                        Center(
                          child: Obx(() {
                            return Visibility(
                              visible: showCancel.value,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        child: Text(
                                          '取消',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        onTap: () {
                                          print('x');
                                          FocusScope.of(context)
                                              .requestFocus(FocusNode());

                                          // FocusManager.instance.primaryFocus?.unfocus();
                                          textEditController.text = '';
                                        },
                                      )
                                    ]),
                              ),
                            );
                          }),
                        )
                      ],
                    ),
                  )
                ],
              ));
            }),
            Builder(builder: (context) {
              return SafeArea(
                  child: ListView.builder(
                itemBuilder: (c, i) {
                  var isChecked = true;
                  return GestureDetector(
                    onTap: () {
                      // var s = t0[i];
                      // t0.removeAt(i);
                      // t1.insert(0,s);
                      // save();

                      var s = t1[i];
                      t1.removeAt(i);
                      t0.insert(0, s);
                      save();
                      setState(() {});
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: SizedBox(
                        height: itemH,
                        child: Padding(
                          padding: EdgeInsets.only(right: 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children:
                                [Text('√'), Text(t1[i])].reversed.toList(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                physics: BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                itemCount: t1.length,
                reverse: true,
              ));
            }),
            // Stack(
            //   children: [
            //     Center(
            //       child: SwitchListTile(value: GetStorage().read('left-hand')??true, onChanged: (v){
            //         GetStorage().write('left-hand', v);
            //         setState(() {
            //
            //         });
            //       }),
            //     ),
            //     Center(child: Text('左手模式'))
            //   ],
            // )
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
