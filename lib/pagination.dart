import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class paginatin extends StatefulWidget {
  const paginatin({super.key});

  @override
  State<paginatin> createState() => _paginatinState();
}

class _paginatinState extends State<paginatin> {
  ScrollController sc = new ScrollController();
  bool ldata = false;
  bool dload = false;
  bool isload = false;
  int count = 0;
  void put_data() {
    String id = Uuid().v1();
    FirebaseFirestore.instance.collection("demo").doc("1d6af200-6fc2-11ed-b96a-89e7575c7f63").collection("data").add({"id": id, "count": count, "time": DateTime.now()});
  }

  List data = [];
  DocumentSnapshot? lastdata;
  void get_data() async {
    isload = true;
    await FirebaseFirestore.instance.collection("demo").doc("1d6af200-6fc2-11ed-b96a-89e7575c7f63").collection("data").limit(8).orderBy("time", descending: false).get().then((value) {
      // print(value.docs[0].data());
      for (var i = 0; i < value.docs.length; i++) {
        data.add(value.docs[i].data());
      }
      // data.addAll(value.docs);
      // print(value.docs[value.docs.length - 1].data());
      lastdata = value.docs[value.docs.length - 1];
    }).then((value) {
      print("data will be inserted !!");
      //print(data
      setState(() {
        isload = false;
      });
    });
    // print(data.);
  }

  void get_moredata() async {
    if (ldata) {
      return;
    }
    Timer(Duration(seconds: 1), () {});
    setState(() {
      dload = true;
    });

    await FirebaseFirestore.instance.collection("demo").doc("1d6af200-6fc2-11ed-b96a-89e7575c7f63").collection("data").orderBy("time", descending: false).startAfter([lastdata!["time"]]).limit(3).get().then((val) {
          // val.docs.forEach((element) {
          //   print(element.data());
          // });
          for (var i = 0; i < val.docs.length; i++) {
            data.add(val.docs[i].data());
            setState(() {});
          }
          if (val.docs.length < 3) {
            setState(() {
              ldata = true;
            });
          }
          setState(() {
            lastdata = val.docs[val.docs.length - 1];
            dload = false;
          });
        });
    //   print(data);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    get_data();
    sc = ScrollController();
    sc.addListener(() {
      if (sc.offset >= sc.position.maxScrollExtent) {
        print("max scroll is done");
        get_moredata();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          put_data();
          setState(() {
            count += 1;
          });
        },
        child: Icon(Icons.add),
      ),
      body: Center(
        child: isload
            ? CircularProgressIndicator()
            : Container(
                color: Colors.greenAccent,
                width: size.width,
                height: size.height / 2,
                child: ListView.builder(
                  controller: sc,
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return Container(
                        height: size.height / 10,
                        color: Colors.greenAccent,
                        child: ListTile(
                          title: Text(data[index]["count"].toString()),
                          subtitle: Text(data[index]["id"]),
                        ));
                  },
                ),
              ),
      ),
    );
  }
}

class pagination2 extends StatefulWidget {
  const pagination2({super.key});

  @override
  State<pagination2> createState() => _pagination2State();
}

class _pagination2State extends State<pagination2> {
  ScrollController sc = new ScrollController();
  bool ldata = false;
  bool dload = false;
  bool isload = false;
  int count = 0;
  void put_data() {
    String id = Uuid().v1();
    FirebaseFirestore.instance.collection("demo").doc("1d6af200-6fc2-11ed-b96a-89e7575c7f63").collection("data").add({"id": id, "count": count, "time": DateTime.now()});
  }

  List data = [];
  DocumentSnapshot? lastdata;
  void get_data() async {
    isload = true;
    await FirebaseFirestore.instance.collection("demo").doc("1d6af200-6fc2-11ed-b96a-89e7575c7f63").collection("data").orderBy("time", descending: false).limitToLast(8).get().then((value) {
      // print(value.docs[0].data());
      for (var i = 0; i < value.docs.length; i++) {
        data.add(value.docs[i].data());
      }
      // data.addAll(value.docs);
      // print(value.docs[value.docs.length - 1].data());
      lastdata = value.docs[value.docs.length - 1];
    }).then((value) {
      print("data will be inserted !!");
      //print(data
      setState(() {
        isload = false;
      });
    });
    // print(data.);
  }

  void get_moredata() async {
    if (ldata) {
      return;
    }
    Timer(Duration(seconds: 1), () {});
    setState(() {
      dload = true;
    });

    await FirebaseFirestore.instance.collection("demo").doc("1d6af200-6fc2-11ed-b96a-89e7575c7f63").collection("data").orderBy("time", descending: false).endBefore([lastdata!["time"]]).limit(3).get().then((val) {
          // val.docs.forEach((element) {
          //   print(element.data());
          // });
          for (var i = 0; i < val.docs.length; i++) {
            data.add(val.docs[i].data());
            setState(() {});
          }
          if (val.docs.length < 3) {
            setState(() {
              ldata = true;
            });
          }
          setState(() {
            lastdata = val.docs[val.docs.length - 1];
            dload = false;
          });
        });
    //   print(data);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    get_data();
    sc = ScrollController();
    sc.addListener(() {
      // if (sc.offset >= sc.position.maxScrollExtent) {
      //   print("max scroll is done");
      //   //  get_moredata();
      // }
      if (sc.offset <= sc.position.minScrollExtent) {
        print("minimum scroll is dine !!");
        get_moredata();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          put_data();
          setState(() {
            count += 1;
          });
        },
        child: Icon(Icons.add),
      ),
      body: Center(
        child: isload
            ? CircularProgressIndicator()
            : Container(
                color: Colors.greenAccent,
                width: size.width,
                height: size.height / 2,
                child: ListView.builder(
                  controller: sc,
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return Container(
                        height: size.height / 10,
                        color: Colors.greenAccent,
                        child: ListTile(
                          title: Text(data[index]["count"].toString()),
                          subtitle: Text(data[index]["id"]),
                        ));
                  },
                ),
              ),
      ),
    );
  }
}
