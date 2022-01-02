class UserModel {
  String? password;
  String? name;
  String? id;

  UserModel(this.name, this.password, this.id);

  UserModel.fromJson(Map<String, dynamic> json) {
    this.password = json['password'];
    this.name = json['userName'];
    this.id = json['id'];
  }

  toJson(UserModel user) {
    Map<String, dynamic> data = {};
    data['userName'] = user.name;
    data['password'] = user.password;
    data['id'] = user.id;
    return data;
  }
}
