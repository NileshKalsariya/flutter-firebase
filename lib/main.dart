import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:practice/service.dart';
import 'package:practice/user_model.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AddScreen(title: 'Flutter Demo Home Page'),
    );
  }
}

class AddScreen extends StatefulWidget {
  final String title;
  AddScreen({Key? key, required this.title}) : super(key: key);

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  TextEditingController name_controller = new TextEditingController();
  TextEditingController password_controller = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                controller: name_controller,
                validator: (value) {
                  if (value == '' || value == null) {
                    return 'please enter a name';
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text('Enter name'),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              TextFormField(
                controller: password_controller,
                validator: (value) {
                  if (value == '' || value == null) {
                    return 'please enter a password';
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  label: Text('Enter password'),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  style: ButtonStyle(),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await Service.saveDataTofirebase(
                          name: name_controller.text.toString(),
                          password: password_controller.text.toString());
                      _formKey.currentState!.reset();
                      FocusScope.of(context).unfocus();
                      Fluttertoast.showToast(msg: 'user added successfully');
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return ListingScreen();
                      }));
                    }
                  },
                  child: Text('save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ListingScreen extends StatefulWidget {
  const ListingScreen({Key? key}) : super(key: key);

  @override
  _ListingScreenState createState() => _ListingScreenState();
}

class _ListingScreenState extends State<ListingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: Service.FetchAllData(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData && snapshot.data!.docs.length != 0) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.connectionState == ConnectionState.none) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    int length = snapshot.data!.docs.length;
                    final docList = snapshot.data!.docs;
                    return ListView.separated(
                        separatorBuilder: (context, index) => Divider(
                              height: 1,
                              thickness: 2,
                            ),
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> currentUser =
                              docList[index].data() as Map<String, dynamic>;
                          UserModel currentModel =
                              UserModel.fromJson(currentUser);
                          return ListTile(
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text((index + 1).toString()),
                              ],
                            ),
                            title: Text(currentModel.name.toString()),
                            subtitle: Text(currentModel.password.toString()),
                            trailing: Wrap(
                              spacing: 10,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return UpdateScreen(
                                          documentId: currentModel.id!);
                                    }));
                                  },
                                  color: Colors.green,
                                  icon: Icon(Icons.edit),
                                ),
                                IconButton(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                              title: Text(
                                                  'are you sure you want to  :-  ${currentModel.name}'),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: double.infinity,
                                                    child: RaisedButton(
                                                      color: Colors.green,
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text('No'),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: double.infinity,
                                                    child: RaisedButton(
                                                      color: Colors.red,
                                                      onPressed: () async {
                                                        await Service()
                                                            .deleteThisDocument(
                                                                documentId:
                                                                    currentModel
                                                                        .id);
                                                        Navigator.pop(context);
                                                        Fluttertoast.showToast(
                                                            msg:
                                                                'user deleted successfully');
                                                      },
                                                      child: Text('Yes'),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ));
                                  },
                                  color: Colors.red,
                                  icon: Icon(Icons.delete),
                                ),
                              ],
                            ),
                          );
                        });
                  }
                } else {
                  return Container(
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Text('no data available'),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class UpdateScreen extends StatefulWidget {
  String documentId;
  UpdateScreen({Key? key, required this.documentId}) : super(key: key);

  @override
  _UpdateScreenState createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  TextEditingController name_controller = new TextEditingController();
  TextEditingController password_controller = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  UserModel data = UserModel(null, null, null);
  @override
  void initState() {
    super.initState();
    getData(widget.documentId);
  }

  getData(docId) async {
    UserModel Mydata = await Service().getPerticularDocData(documentId: docId);

    setState(() {
      name_controller.text = Mydata.name!;
      password_controller.text = Mydata.password!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'update',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: name_controller,
                validator: (value) {
                  if (value == '' || value == null) {
                    return 'please enter a name';
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text('Enter name'),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              TextFormField(
                controller: password_controller,
                validator: (value) {
                  if (value == '' || value == null) {
                    return 'please enter a password';
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  label: Text('Enter password'),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  style: ButtonStyle(),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      UserModel userModel = UserModel(name_controller.text,
                          password_controller.text, widget.documentId);
                      await Service().updateData(userModel: userModel);
                      _formKey.currentState!.reset();
                      FocusScope.of(context).unfocus();
                      Fluttertoast.showToast(msg: 'user updated successfully');
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return ListingScreen();
                      }));
                    }
                  },
                  child: Text('Update'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
