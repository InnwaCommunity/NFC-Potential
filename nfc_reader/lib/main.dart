// import 'dart:convert';

// import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
// import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:nfc_reader/bloc/listen_nfc_option_bloc.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp( BlocProvider(
    create: (context) => ListenNfcOptionBloc(),
    child:const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  ValueNotifier<dynamic> result = ValueNotifier(null);
  final NfcManager nfcManager = NfcManager.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('NFC Reader')),
        body: SafeArea(
          child: BlocConsumer<ListenNfcOptionBloc, ListenNfcOptionState>(
            listener: (context, state) {
              if (state is StartNFCListen) {
                tagRead();
                
              }
              if (state is NFCDataLoaded) {
                tagRead();
              }
            },
            builder: (context, state) {
              if (state is ListenNfcOptionInitial) {
                NfcManager.instance.isAvailable();
                BlocProvider.of<ListenNfcOptionBloc>(context)
                    .add(RequestPermission());
                return const Center(child: Text('NFC isAvailable Please Wait'));
              } else if (state is NFCDataLoaded) {
                return Flex(
                  mainAxisAlignment: MainAxisAlignment.start,
                  direction: Axis.vertical,
                  children: [
                    const Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text('ID'),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        decoration: BoxDecoration(border: Border.all()),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(state.id),
                        )
                      ),
                    ),
                    // const Text('Raw Data'),
                    const SizedBox(height: 10,),
                    const Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text('Raw Data'),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        constraints: const BoxConstraints.expand(),
                        decoration: BoxDecoration(border: Border.all()),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text('Data: ${state.result}'),
                                const SizedBox(height: 10,),
                                Text('Handle: ${state.handle}'),
                              ],
                            ),
                          )
                        ),
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.fromLTRB(30, 10, 10, 10),
                    //   child: TextField(
                    //     decoration: InputDecoration(hintText: 'id        ${state.id}'),
                    //   ),
                    // ),
                    
                  ],
                );
              } else {
                return Flex(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  direction: Axis.vertical,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        // constraints: const BoxConstraints.expand(),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height/3,
                        decoration: BoxDecoration(border: Border.all()),
                        child:const SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Please Enter Your Card'),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              // return Container();
            },
          ),
        ),
      ),
    );
  }

  void tagRead() async {
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        // tag.mifare.read;
        // List<String> ids='' as List<String>;
        // List<String> ids =[];
        result.value = tag.data;
        
        String handle = tag.handle;
        String? id;
        // log(tag.data.toString());
        var nfc=NfcA.from(tag);
        var isodep=IsoDep.from(tag);
        if (nfc != null) {
          Uint8List nfca= Uint8List.fromList(tag.data["nfca"]['identifier']);
        id = nfca.map((e) => e.toRadixString(16).padLeft(2, '0')).join('');
        
        //.map((e) => e.toRadixString(16).padLeft(2, '0')).join('')}');
        }else{
          Uint8List nfca= Uint8List.fromList(tag.data["isodep"]['identifier']);
        id = nfca.map((e) => e.toRadixString(16).padLeft(2, '0')).join('');
        }
        var tran=nfc!.transceive(data: tag.data["nfca"]['identifier']);
        var traniso=isodep!.transceive(data: tag.data["isodep"]['identifier']);
        // ids.add(nfcaid);
        //  MifareClassic? mifareClassi;
        // Uint8List mifareclassic= Uint8List.fromList(tag.data["mifareclassic"]['identifier']);
        // String mifareclassicid = mifareclassic.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':');
        // ids.add(mifareclassicid);
        // Uint8List ndefformatable= Uint8List.fromList(tag.data["ndefformatable"]['identifier']);
        ///////////////////////////////
        // String ndefformatableid = ndefformatable.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':');
        try {
         var mifareClassi = MifareClassic.from(tag);
         List<int> blockData = await mifareClassi!.readBlock(blockIndex: 64);
         final Uint8List key = Uint8List.fromList(tag.data["nfca"]['identifier']);
         bool auth= await mifareClassi.authenticateSectorWithKeyA(sectorIndex: 1, key: key);

         
        //  MifareClassic.
          // mifareClassi!.transceive(data: data);
    //     Uint8List? read = mifareClassi!.identifier;
    //     List<int> identifier = mifareClassi.identifier;
    //     final bytes = Uint8List.fromList([0x1B, identifier[0], identifier[1], identifier[2], identifier[3]]);
        
    //   // Convert the byte list to a hexadecimal string
    //   String identifierHex = identifier.map((byte) {
    //     return byte.toRadixString(16).padLeft(2, '0');
    //   }).join('');

    //   log('NFC A Identifier: $identifierHex');
    //     // var dec=const Utf8Decoder().convert(read);
    //     // log('dec $dec');
    // //     var cipherText = cipher.process( inputAsUint8List );        
    // // String ascii= ASCII.decode(cipherText);
    //     //  String decoded = utf8.decode(identifier); 
    //     //  log('decode: $decoded');
    //     var isodep=IsoDep.from(tag);
    //     var ndefFormatable= NdefFormatable.from(tag);
    //     log('Isodep: $isodep');
    //     log('NdefFormatable  $ndefFormatable');
        
    //     //  String decoded = utf8.decode(read!); 
        
    //     var ndef = Ndef.from(tag);
    //     var nfca=NfcA.from(tag);
    //     log('MIfareClassic: $nfca type: ${mifareClassi?.type}  blockCount:${mifareClassi?.blockCount}');
    //     log('nfca?.identifier: $read');
    //     // log('decoded: $decoded');
    //     log('ndfe ${ndef?.additionalData}  ,${ndef?.additionalData}');
    //     NdefMessage? message = await ndef?.read();
    //     if (message != null) {
    //        NdefRecord record = message.records.first;
    //       String payload = String.fromCharCodes(record.payload);
    //       List<String> fields = payload.split('|');
    //       log('Fields $fields');
    //     }
        
        log('Data: ${tag.data.toString()}');
        log('Handle: $handle');
        if (mounted) {
          BlocProvider.of<ListenNfcOptionBloc>(context)
            .add(ShowNFCData(result: result.value.toString(), handle: handle,read: null,id: id));
        }
        NfcManager.instance.stopSession();
        
        } catch (e) {
          log(e.toString());
        }
      },
      // pollingOptions:
    );
    // var tag = await FlutterNfcKit.poll(
    //     timeout: const Duration(seconds: 10),
    //     iosMultipleTagMessage: "Multiple tags found!",
    //     iosAlertMessage: "Scan your tag");
    // if (tag.ndefAvailable==true) {
    //   /// decoded NDEF records (see [ndef.NDEFRecord] for details)
    //   /// `UriRecord: id=(empty) typeNameFormat=TypeNameFormat.nfcWellKnown type=U uri=https://github.com/nfcim/ndef`
    //   for (var record in await FlutterNfcKit.readNDEFRecords(cached: false)) {
    //     log(record.toString());
    //   }

    //   /// raw NDEF records (data in hex string)
    //   /// `{identifier: "", payload: "00010203", type: "0001", typeNameFormat: "nfcWellKnown"}`
    //   for (var record
    //       in await FlutterNfcKit.readNDEFRawRecords(cached: false)) {
    //     log(jsonEncode(record).toString());
    //   }
    // }
  }

  // void _ndefWrite() {
  //   NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
  //     var ndef = Ndef.from(tag);
  //     if (ndef == null || !ndef.isWritable) {
  //       result.value = 'Tag is not ndef writable';
  //       NfcManager.instance.stopSession(errorMessage: result.value);
  //       return;
  //     }

  //     NdefMessage message = NdefMessage([
  //       NdefRecord.createText('Hello World!'),
  //       NdefRecord.createUri(Uri.parse('https://flutter.dev')),
  //       NdefRecord.createMime(
  //           'text/plain', Uint8List.fromList('Hello'.codeUnits)),
  //       NdefRecord.createExternal(
  //           'com.example', 'mytype', Uint8List.fromList('mydata'.codeUnits)),
  //     ]);

  //     try {
  //       await ndef.write(message);
  //       result.value = 'Success to "Ndef Write"';
  //       NfcManager.instance.stopSession();
  //     } catch (e) {
  //       result.value = e;
  //       NfcManager.instance.stopSession(errorMessage: result.value.toString());
  //       return;
  //     }
  //   });
  // }

  // void _ndefWriteLock() {
  //   NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
  //     var ndef = Ndef.from(tag);
  //     if (ndef == null) {
  //       result.value = 'Tag is not ndef';
  //       NfcManager.instance.stopSession(errorMessage: result.value.toString());
  //       return;
  //     }

  //     try {
  //       await ndef.writeLock();
  //       result.value = 'Success to "Ndef Write Lock"';
  //       NfcManager.instance.stopSession();
  //     } catch (e) {
  //       result.value = e;
  //       NfcManager.instance.stopSession(errorMessage: result.value.toString());
  //       return;
  //     }
  //   });
  // }
}

// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // TRY THIS: Try running your application with "flutter run". You'll see
//         // the application has a blue toolbar. Then, without quitting the app,
//         // try changing the seedColor in the colorScheme below to Colors.green
//         // and then invoke "hot reload" (save your changes or press the "hot
//         // reload" button in a Flutter-supported IDE, or press "r" if you used
//         // the command line to start the app).
//         //
//         // Notice that the counter didn't reset back to zero; the application
//         // state is not lost during the reload. To reset the state, use hot
//         // restart instead.
//         //
//         // This works for code too, not just values: Most code changes can be
//         // tested with just a hot reload.
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // TRY THIS: Try changing the color here to a specific color (to
//         // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
//         // change color while the other colors stay the same.
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           //
//           // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
//           // action in the IDE, or press "p" in the console), to see the
//           // wireframe for each widget.
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
