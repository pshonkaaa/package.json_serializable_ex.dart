// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// ExtensionGenerator
// **************************************************************************

// ignore_for_file: unused_local_variable, unnecessary_non_null_assertion, dead_code
ChatMemberAdministrator _$ChatMemberAdministratorFromJson(JsonObjectEx json) {
  dynamic value;
  return ChatMemberAdministrator(
    status: _$EChatMemberStatusFromJson(
      json.getString(
        "status",
      )!,
    )!,
    user: _$UserFromJson(
      json.getJsonObject(
        "user",
      )!,
    ),
    canBeEdited: json.getArray(
      "can_be_edited",
    )!,
    listJson: (value = json.getJsonArray(
              "list_json",
            )) ==
            null
        ? null
        : json
            .getJsonArray<JsonObjectEx>(
              "list_json",
            )!
            .map(
              (e) => _$UserFromJson(
                e,
              ),
            )
            .toList(),
    listInt: (value = json.getArray(
              "list_int",
            )) ==
            null
        ? null
        : json.getArray(
            "list_int",
          )!,
    listString: json.getArray(
      "list_string",
    )!,
    listEnum: json
        .getJsonArray(
          "list_enum",
        )!
        .map(
          (e) => _$EChatMemberStatusFromJson(
            e,
          )!,
        )
        .toList(),
    customJson: (value = json.getJsonObject(
              "custom_json",
            )) ==
            null
        ? null
        : _$UserFromJson(
            json.getJsonObject(
              "custom_json",
            )!,
          ),
    json: json.getDynamic(
      "json",
    ),
    canPinMessages: (value = json.getBoolean(
              "can_pin_messages",
            )) ==
            null
        ? null
        : json.getBoolean(
            "can_pin_messages",
          )!,
    customTitle: (value = json.getString(
              "custom_title",
            )) ==
            null
        ? null
        : json.getString(
            "custom_title",
          )!,
  );
}

JsonObjectEx _$ChatMemberAdministratorToJson(ChatMemberAdministrator instance) {
  final json = JsonObjectEx.empty();
  void write(String key, dynamic value) {
    if (value != null) json.put(key, value);
  }

  write(
      "status",
      _$EChatMemberStatusToJson(
        instance.status!,
      ));
  write(
      "user",
      _$UserToJson(
        instance.user!,
      ));
  write("can_be_edited", instance.canBeEdited!);
  write(
      "list_json",
      instance.listJson == null
          ? null
          : instance.listJson!
              .map(
                (e) => _$UserToJson(
                  e,
                ),
              )
              .toList());
  write("list_int", instance.listInt == null ? null : instance.listInt!);
  write("list_string", instance.listString!);
  write(
      "list_enum",
      instance.listEnum!
          .map(
            (e) => _$EChatMemberStatusToJson(
              e,
            ),
          )
          .toList());
  write(
      "custom_json",
      instance.customJson == null
          ? null
          : _$UserToJson(
              instance.customJson!,
            ));
  write("json", instance.json!);
  write("can_pin_messages",
      instance.canPinMessages == null ? null : instance.canPinMessages!);
  write("custom_title",
      instance.customTitle == null ? null : instance.customTitle!);
  return json;
}

ChatMember _$ChatMemberFromJson(JsonObjectEx json) {
  dynamic value;
  return ChatMember(
    status: _$EChatMemberStatusFromJson(
      json.getString(
        "status",
      )!,
    )!,
    user: _$UserFromJson(
      json.getJsonObject(
        "user",
      )!,
    ),
  );
}

JsonObjectEx _$ChatMemberToJson(ChatMember instance) {
  final json = JsonObjectEx.empty();
  void write(String key, dynamic value) {
    if (value != null) json.put(key, value);
  }

  write(
      "status",
      _$EChatMemberStatusToJson(
        instance.status!,
      ));
  write(
      "user",
      _$UserToJson(
        instance.user!,
      ));
  return json;
}

User _$UserFromJson(JsonObjectEx json) {
  dynamic value;
  return User(
    id: json.getInteger(
      "id",
    )!,
    isBot: json.getBoolean(
      "is_bot",
    )!,
    firstName: json.getString(
      "first_name",
    )!,
    lastName: (value = json.getString(
              "last_name",
            )) ==
            null
        ? null
        : json.getString(
            "last_name",
          )!,
    username: (value = json.getString(
              "username",
            )) ==
            null
        ? null
        : json.getString(
            "username",
          )!,
    languageCode: (value = json.getString(
              "language_code",
            )) ==
            null
        ? null
        : json.getString(
            "language_code",
          )!,
    canJoinGroups: (value = json.getBoolean(
              "can_join_groups",
            )) ==
            null
        ? null
        : json.getBoolean(
            "can_join_groups",
          )!,
    canReadAllGroupMessages: (value = json.getBoolean(
              "can_read_all_group_messages",
            )) ==
            null
        ? null
        : json.getBoolean(
            "can_read_all_group_messages",
          )!,
    supportsInlineQueries: (value = json.getBoolean(
              "supports_inline_queries",
            )) ==
            null
        ? null
        : json.getBoolean(
            "supports_inline_queries",
          )!,
  );
}

JsonObjectEx _$UserToJson(User instance) {
  final json = JsonObjectEx.empty();
  void write(String key, dynamic value) {
    if (value != null) json.put(key, value);
  }

  write("id", instance.id!);
  write("is_bot", instance.isBot!);
  write("first_name", instance.firstName!);
  write("last_name", instance.lastName == null ? null : instance.lastName!);
  write("username", instance.username == null ? null : instance.username!);
  write("language_code",
      instance.languageCode == null ? null : instance.languageCode!);
  write("can_join_groups",
      instance.canJoinGroups == null ? null : instance.canJoinGroups!);
  write(
      "can_read_all_group_messages",
      instance.canReadAllGroupMessages == null
          ? null
          : instance.canReadAllGroupMessages!);
  write(
      "supports_inline_queries",
      instance.supportsInlineQueries == null
          ? null
          : instance.supportsInlineQueries!);
  return json;
}

EChatMemberStatus? _$EChatMemberStatusFromJson(String value) {
  switch (value) {
    case "creator":
      return EChatMemberStatus.CREATOR;
    case "administrator":
      return EChatMemberStatus.ADMINISTRATOR;
    case "member":
      return EChatMemberStatus.MEMBER;
    case "restricted":
      return EChatMemberStatus.RESTRICTED;
    case "left":
      return EChatMemberStatus.LEFT;
    case "kicked":
      return EChatMemberStatus.KICKED;
  }
  return null;
}

String? _$EChatMemberStatusToJson(EChatMemberStatus instance) {
  switch (instance) {
    case EChatMemberStatus.CREATOR:
      return "creator";
    case EChatMemberStatus.ADMINISTRATOR:
      return "administrator";
    case EChatMemberStatus.MEMBER:
      return "member";
    case EChatMemberStatus.RESTRICTED:
      return "restricted";
    case EChatMemberStatus.LEFT:
      return "left";
    case EChatMemberStatus.KICKED:
      return "kicked";
  }
  return null;
}
