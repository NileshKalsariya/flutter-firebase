import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:practice/firebase_path.dart';
import 'package:practice/user_model.dart';

class Service {
  static Future saveDataTofirebase(
      {required String name, required String password}) async {
    String userCollection = FirebasePath.user_collection;

    DocumentReference doc =
        FirebaseFirestore.instance.collection(userCollection).doc();
    final docId = doc.id;
    UserModel user =
        UserModel(name.toString(), password.toString(), docId.toString());
    Map<String, dynamic> jsondata = user.toJson(user);
    doc.set(jsondata);
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> FetchAllData() {
    String userCollection = FirebasePath.user_collection;
    Stream<QuerySnapshot<Map<String, dynamic>>> futureSnap =
        FirebaseFirestore.instance.collection(userCollection).snapshots();
    return futureSnap;
  }

  Future<UserModel> getPerticularDocData({required String documentId}) async {
    String userCollection = FirebasePath.user_collection;
    DocumentSnapshot<Map<String, dynamic>> data = await FirebaseFirestore
        .instance
        .collection(userCollection)
        .doc(documentId)
        .get();
    Map<String, dynamic> currentData = data.data() as Map<String, dynamic>;
    UserModel currentUser = UserModel.fromJson(currentData);
    return currentUser;
  }

  updateData({required UserModel userModel}) {
    String userCollection = FirebasePath.user_collection;
    Map<String, dynamic> newUserModel = userModel.toJson(userModel);
    FirebaseFirestore.instance
        .collection(userCollection)
        .doc(userModel.id)
        .set(newUserModel);
  }

  deleteThisDocument({required documentId}) {
    String userCollection = FirebasePath.user_collection;
    FirebaseFirestore.instance
        .collection(userCollection)
        .doc(documentId)
        .delete();
  }
}
