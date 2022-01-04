part of 'models.dart';

// @JsonSerializableEx(fieldRename: FieldRename.snake)
// enum EType {
//   DEFAULT,
//   NEW_ADDED,
//   OLD_DELETED,
// }

// @JsonSerializableEx()
// abstract class IModel {
//   final EType type;
//   final String abc;
//   IModel({
//     required this.type,
//     required this.abc,
//   });
// }

// @JsonSerializableEx(fieldRename: FieldRename.snake)
// class ProfileModel extends IModel {
//   final String name;
//   final int age;
//   final bool allowedToday;
//   final bool? test;
//   final List<int> codes;
//   final NestedModel model;

//   @override
//   final String abc;

//   ProfileModel({
//     required this.name,
//     required this.age,
//     required this.allowedToday,
//     required this.test,
//     required this.codes,
//     required this.model,
//     required this.abc,
//     required EType type,
//     String? optional,
//   }) : super(
//     type: type,
//     abc: abc,
//   );
  
//   factory ProfileModel.fromJson(JsonObjectEx json) => _$ProfileModelFromJson(json);
//   Map<String, dynamic> toJson() => _$ProfileModelToJson(this);
// }

// @JsonSerializableEx(isObject: false, keepOrder: true)
// class NestedModel {
//   final String first;
//   final int second;
//   final bool third;
//   final bool? fourth;
//   final List<int> five;
//   NestedModel({
//     required this.first,
//     required this.second,
//     required this.third,
//     required this.fourth,
//     required this.five,
//   });
// }










@JsonSerializableEx(fieldRename: FieldRename.snake)
class ChatMemberAdministrator extends ChatMember {
  List<bool> canBeEdited;
  List<User>? listJson;
  List<int>? listInt;
  List<String> listString;
  List<EChatMemberStatus> listEnum;
  User? customJson;
  JsonObjectEx json;
  bool? canPinMessages;
  String? customTitle;

  ChatMemberAdministrator({
    required EChatMemberStatus status,
    required User user,
    required this.canBeEdited,
    required this.listJson,
    required this.listInt,
    required this.listString,
    required this.listEnum,
    required this.customJson,
    required this.json,
    this.canPinMessages,
    this.customTitle,
  }) : super(
    status: status,
    user: user,
  );
  
  factory ChatMemberAdministrator.fromJson(JsonObjectEx json) => _$ChatMemberAdministratorFromJson(json);
  JsonObjectEx toJson() => _$ChatMemberAdministratorToJson(this);
}

@JsonSerializableEx(fieldRename: FieldRename.snake)
class ChatMember {
  EChatMemberStatus status;
  User user;

  ChatMember({
    required this.status,
    required this.user,
  });
  
}

@JsonSerializableEx(fieldRename: FieldRename.snake)
enum EChatMemberStatus {
  CREATOR,
  ADMINISTRATOR,
  MEMBER,
  RESTRICTED,
  LEFT,
  KICKED,
}


@JsonSerializableEx(fieldRename: FieldRename.snake)
class User extends ITelegramModel {
  int id;
  bool isBot;
  String firstName;
  String? lastName;
  String? username;
  String? languageCode;
  bool? canJoinGroups;
  bool? canReadAllGroupMessages;
  bool? supportsInlineQueries;
  User({
    required this.id,
    required this.isBot,
    required this.firstName,
    this.lastName,
    this.username,
    this.languageCode,
    this.canJoinGroups,
    this.canReadAllGroupMessages,
    this.supportsInlineQueries,
  });
  
  factory User.fromJson(JsonObjectEx json) => _$UserFromJson(json);
  JsonObjectEx toJson() => _$UserToJson(this);
}


abstract class ITelegramModel {
}