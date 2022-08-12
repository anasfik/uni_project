// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, unused_local_variable, must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Notific extends StatefulWidget {
  @override
  State<Notific> createState() => _NotificState();
}

class _NotificState extends State<Notific> {
  /// Variables

  // list where we store the data from the firestore database
  late List dataList;

  // TextFields controllers to get value from TextFields to use them
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  // firestore
  FirebaseFirestore firestore = FirebaseFirestore.instance;

// load contents from firestore
  Future<List> getDataFromFirestore() async {
    dataList = await firestore.collection('mainCollection').get().then((value) {
      return value.docs.map((doc) => doc.data()).toList();
    });

    return dataList;
  }

// show dialog to put data
  showInformationDialog() {
    showDialog(
        context: (context),
        builder: (context) {
          return AlertDialog(
            title: Text(
              "عن الاعلان",
              textAlign: TextAlign.right,
            ),
            content: Container(
              width: MediaQuery.of(context).size.width * .8,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: "عنوان",
                      ),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: "وصف",
                      ),
                    ),
                    TextField(
                      controller: dateController,
                      decoration: InputDecoration(
                        labelText: "تاريخ",
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                    child: Text("حفظ"),
                    onPressed: () async {
                      //call
                      await addNewAd(
                          titleController.text.trim(),
                          descriptionController.text.trim(),
                          dateController.text.trim());
                    },
                  ),
                  TextButton(
                    child: Text("الغاء"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          );
        });
  }

//
// add new ad to firestore
  addNewAd(String title, String description, String date) async {
    try {
      await firestore.collection('mainCollection').add({
        'title': title,
        'description': description,
        'date': date,
        "createdAt": DateTime.now(),
      });
      // close dialog
      Navigator.of(context).pop();

      setState(() {});
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${e.message}"),
        ),
      );
    }
  }

// delete all ads from firestore
  deleteAll() async {
    FirebaseFirestore.instance.collection("mainCollection").get().then((value) {
      value.docs.forEach((element) {
        FirebaseFirestore.instance
            .collection("mainCollection")
            .doc(element.id)
            .delete()
            .then((value) {
          print("Success!");
          setState(() {});
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: RefreshIndicator(
        onRefresh: () async {
          await getDataFromFirestore();
        },
        child: Scaffold(
          appBar: appBar(),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              dataList = await getDataFromFirestore();

              setState(() {});
            },
            child: Icon(Icons.sync),
          ),
          drawer: Drawer(
              child: Column(
            children: [
              UserAccountsDrawerHeader(
                  accountName: Text("كلية الاقتصاد و الدراسات التجارية"),
                  accountEmail: Text("kordofan.edu.sd")),
              ListTile(
                title: Text("الصفحة الرئيسية"),
                leading: Icon(Icons.home),
                onTap: () {
                  Navigator.of(context).pushNamed("homepage");
                },
              ),
              ListTile(
                title: Text("FAQ"),
                leading: Icon(Icons.face),
                onTap: () {},
              ),
              ListTile(
                title: Text("تسجيل الخروج"),
                leading: Icon(Icons.home),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed("login");
                },
              ),
            ],
          )),
          body: listView(),
        ),
      ),
    );
  }

  PreferredSizeWidget appBar() {
    return AppBar(
      title: Text("لوحة الاعلانات"),
      actions: [
        IconButton(
          onPressed: () async {
            deleteAll();
          },
          icon: Icon(Icons.delete),
        ),
        IconButton(
          onPressed: () async {
            showInformationDialog();
          },
          icon: Icon(Icons.add),
        ),
      ],
    );
  }

  Widget listView() {
    return FutureBuilder(
        future: getDataFromFirestore(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("حدث خطأ ما"),
            );
          }

          if (snapshot.hasData && snapshot.data!.isEmpty) {
            return Center(
              child: Text("لا يوجد اعلانات"),
            );
          }
          if (snapshot.hasData) {
            return ListView.separated(
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                return listViewItem(index);
              },
              separatorBuilder: (context, index) {
                return Divider(
                  height: 0,
                );
              },
            );
          }

          return Center(
            child: Text("something weird"),
          );
        });
  }

  Widget listViewItem(int index) {
    return Container(
      margin: EdgeInsets.only(left: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          prefixIcon(),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 13, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  message(index),
                  timeAndDate(index),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget prefixIcon() {
    return Container(
      height: 50,
      width: 50,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade300,
      ),
      child: Icon(
        Icons.notifications,
        size: 25,
        color: Colors.blue[300],
      ),
    );
  }

  Widget message(int index) {
    double textSize = 20;
    return RichText(
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        text: "${dataList[index]['title']} ",
        style: TextStyle(
            fontSize: textSize,
            color: Colors.black,
            fontWeight: FontWeight.bold),
        children: [
          TextSpan(
            text: dataList[index]['description'],
            style: TextStyle(
              fontWeight: FontWeight.w400,
            ),
          )
        ],
      ),
    );
  }

  Widget timeAndDate(int index) {
    return Container(
      margin: EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            dataList[index]['date'],
            style: TextStyle(
              fontSize: 10,
            ),
          ),
          Text(
            dataList[index]['date'],
            style: TextStyle(
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
