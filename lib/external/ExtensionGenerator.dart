import 'dart:async';

import 'package:analyzer/dart/constant/value.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:json_annotation_ex/library.dart';
import 'package:json_serializable_ex/internal/ModelVisitor.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';
import 'package:pshondation/library.dart';

class ExtensionGenerator extends GeneratorForAnnotation<JsonSerializableEx> {
  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    final sb = new StringBuffer();
    sb.writeln("// ignore_for_file: unused_local_variable, dead_code");
    sb.writeln(await super.generate(library, buildStep));
    // print(content);
    return sb.toString();
  }
  
  @override
  String generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    final visitor = ModelVisitor(element);
    element.visitChildren(visitor);
    if(!visitor.parsed)
      return "";

    final classBuffer = StringBuffer();

    final bool aIgnoreFields = annotation.read("ignoreFields").boolValue;
    final bool aIsObject = annotation.read("isObject").boolValue;
    final bool aKeepOrder = annotation.read("keepOrder").boolValue;
    final FieldRename fieldRename = _fromDartObject(annotation.read("fieldRename"))!;
    
    final bool isClass = visitor.isClass;
    final bool isEnum = visitor.isEnum;
    final String className = visitor.className;
    final List<Field> fields = [];



    if(isClass) {
      final String gJson = aIsObject ? "JsonObjectEx" : "JsonArrayEx";
      
      fields.addAll(visitor.fields.where((f) => visitor.parameters.tryFirstWhere((p) => p.name == f.name) != null));
      
      if(aIgnoreFields)
        fields.removeWhere((e) => e.options == null && e.key == null);
      fields.removeWhere((e) => e.options != null && e.options!.ignore);

      // FROM-JSON
      //------------------------------------------------------------------------
      {
        final String gClassName;
        final String gValueType;

        gClassName = generateFromJsonMethodName(className);
        gValueType = gJson;
        
        classBuffer.writeln("$className $gClassName($gValueType json) {");

        classBuffer.writeln("dynamic value;");

        classBuffer.writeln("return $className(");
        
        for (final field in fields) {
          final String name = field.name;
          final String key = field.key ?? (aIsObject ? encodedFieldName(fieldRename, field.name) : field.index.toString());
          final ObjectReturnType returnType = field.returnType;
          final String typeName = returnType.name;
          final bool isNullable = field.isNullable;
          final bool isJson = returnType.isJson;
          final bool isJsonObject = returnType.isJsonObject;

          classBuffer.write('$name: ');


          ICode generateListFunctionCall(
            ObjectReturnType returnType,
            Instance json,
          ) {
            switch(returnType.type) {
              case EType.BOOL:
              case EType.INT:
              case EType.DOUBLE:
              case EType.STRING:
                return json;
              case EType.LIST:
                // TODO NESTED LIST
                return json;
              case EType.MAP:
                // TODO NESTED JSON OBJECT
                return json..callMethod(FunctionCall("getDynamic", arguments: []));
              case EType.ENUM:
              case EType.DYNAMIC:
              case EType.CLASS:
                String? suffix = returnType.type == EType.ENUM ? "!" : null;
                String? template = returnType.type == EType.ENUM ? null : returnType.isJsonObject ? "JsonObjectEx" : "JsonArrayEx";
                if(!returnType.isJson)
                  return json;
                
                final lastCall = json.calls.last as FunctionCall;
                if(template != null)
                  lastCall.templates.add(template);
                final call = FunctionCall(generateFromJsonMethodName(returnType.name), arguments: ["e"], suffix: suffix);
                lastCall..callMethod(FunctionCall("map", arguments: ["(e) => $call"]))..callMethod(FunctionCall("toList"));
                return json; //FunctionCall(generateFromJsonMethodName(returnType.name), arguments: [json]);
              default:
                throw "Unknown type ${returnType.type}";
            }
          }
          
          ICode generateFunctionCall(
            ObjectReturnType returnType,
            Instance json,
            String variableName,
            String debugClassName,
          ) {
            switch(returnType.type) {
              case EType.BOOL:
                return json..callMethod(FunctionCall("getBoolean", arguments: [variableName], suffix: "!"));
              case EType.INT:
                return json..callMethod(FunctionCall("getInteger", arguments: [variableName], suffix: "!"));
              case EType.DOUBLE:
                return json..callMethod(FunctionCall("getDouble", arguments: [variableName], suffix: "!"));
              case EType.STRING:
                return json..callMethod(FunctionCall("getString", arguments: [variableName], suffix: "!"));
              case EType.LIST:
                final template = returnType.templates.first;
                final method = template.isJson ? "getJsonArray" : "getArray";
                json..callMethod(FunctionCall(method, arguments: [variableName], suffix: "!"));
                if(!template.isJson)
                  return json;
                return generateListFunctionCall(template, json);
              case EType.MAP:
                // TODO getJsonObject
                return json..callMethod(FunctionCall("getDynamic", arguments: [variableName]));
              case EType.ENUM:
                final call = FunctionCall(generateFromJsonMethodName(returnType.name), suffix: "!");

                json..callMethod(FunctionCall(returnType.isJsonObject ? "getString" : "getInteger", arguments: [variableName], suffix: "!"));

                return call..arguments.add(json);
              case EType.DYNAMIC:
              case EType.CLASS:
                if(returnType.isJson) {
                  final method = returnType.isJsonObject ? "getJsonObject" : "getJsonArray";
                  json..callMethod(FunctionCall(method, arguments: [variableName], suffix: "!"));
                  final call = FunctionCall(generateFromJsonMethodName(returnType.name), arguments: [json]);
                  return call;
                } return json..callMethod(FunctionCall("getDynamic", arguments: [variableName]));
              default:
                throw "Unknown type ${returnType.type}";
            }
          }
          
          
          {
            final String className;
            ICode code;

            final String parsedKey = (aIsObject ? '"$key"' : key);

            className = generateFromJsonMethodName(typeName);
            
            code = generateFunctionCall(returnType, new Instance("json"), parsedKey, className);
            
            String call = "";
            String subcall = "";

            if(code is FunctionCall) {
              final String methodSuffix = isNullable ? "" : "!";
              final instance = code.arguments.first as Instance;
              // call = "${instance}$methodSuffix";
              subcall = code.toString();
              code = instance;
            } if(code is Instance) {
              final firstCall = code.calls.first as FunctionCall;
              call = new Instance(code.name, calls: [FunctionCall(firstCall.name, arguments: firstCall.arguments)]).toString();
              if(subcall.isEmpty)
                subcall = code.toString();
            } else throw "UNHANDLED EXECUTION";
            
            if(isNullable) {
              classBuffer.write('(value = $call) == null ? null : $subcall');
            } else {
              classBuffer.write('$subcall');
            }
          } classBuffer.writeln(',');
        }
        classBuffer.writeln(');');

        classBuffer.writeln('}');
      }
      //------------------------------------------------------------------------

      
      // TO-JSON
      //------------------------------------------------------------------------
      {
        final String gClassName;
        gClassName = generateToJsonMethodName(className);
        
        classBuffer.writeln("$gJson $gClassName($className instance) {");

        classBuffer.writeln('final json = $gJson.empty();');
        
        if(fields.isNotEmpty) {
          if(aIsObject) {
            classBuffer.writeln('void write(String key, dynamic value) {');
            classBuffer.writeln('if (value != null) json.put(key, value);');
            classBuffer.writeln('}');
          } else {
            classBuffer.writeln('void write(dynamic value) {');
            if(!aKeepOrder)
              classBuffer.writeln('if (value != null) ');
            classBuffer.writeln('json.add(value);');
            classBuffer.writeln('}');
          }

          for (final field in fields) {
            final String name = field.name;
            final ObjectReturnType returnType = field.returnType;
            final String key = field.key ?? (aIsObject ? encodedFieldName(fieldRename, field.name) : field.index.toString());

            String call = "instance.$name";
            String subCall = "";

            ICode func = new Instance("instance", calls: [new Instance(name, suffix: "!")]);
            if(returnType.isJson) {
              func = FunctionCall(generateToJsonMethodName(returnType.name), arguments: [func]);
            } else if(returnType.type == EType.LIST) {
              final template = returnType.templates.first;
              if(template.isJson) {
                final call = FunctionCall(generateToJsonMethodName(template.name), arguments: ["e"]);
                func.calls.last.callMethod(FunctionCall("map", arguments: ["(e) => $call"])..callMethod(FunctionCall("toList")));
              }
            } subCall = func.toString();

            final String arg;
            if(field.isNullable)
              arg = "$call == null ? null : $subCall";
            else arg = subCall;

            if(aIsObject)
              classBuffer.writeln('write("$key", $arg);');
            else classBuffer.writeln('write($arg);');
          }
        }

        classBuffer.writeln("return json;");

        classBuffer.writeln('}');
      }
      //------------------------------------------------------------------------

      
    } else if(isEnum) {
      fields.addAll(visitor.fields);

      
      final String gJson = aIsObject ? "JsonObjectEx" : "JsonArrayEx";

      if(aIgnoreFields)
        fields.removeWhere((e) => e.options == null && e.key == null);
      fields.removeWhere((e) => e.options != null && e.options!.ignore);

      // FROM-JSON
      //------------------------------------------------------------------------
      {
        final String gClassName;
        final String gValueType;

        gClassName = generateFromJsonMethodName(className);
        gValueType = aIsObject ? "String" : "int";
        
        classBuffer.writeln("$className? $gClassName($gValueType value) {");
        
        classBuffer.writeln('switch(value) {');
        for (final field in fields) {          
          final String name = field.name;
          final String key = field.key ?? (aIsObject ? encodedFieldName(fieldRename, field.name) : field.index.toString());

          final String parsedKey = (aIsObject ? '"$key"' : key);
          classBuffer.writeln('case $parsedKey: return $className.$name;');
        } classBuffer.writeln('}');

        classBuffer.writeln('return null;');

        classBuffer.writeln('}');
      }
      //------------------------------------------------------------------------

      
      // TO-JSON
      //------------------------------------------------------------------------
      {
        final String gClassName;
        final String gReturnType;

        gClassName = generateToJsonMethodName(className);
        gReturnType = aIsObject ? "String?" : "int?";
        
        classBuffer.writeln("$gReturnType $gClassName($className instance) {");

        classBuffer.writeln('switch(instance) {');
        for (final field in fields) {
          final String name = field.name;
          final String key = field.key ?? (aIsObject ? encodedFieldName(fieldRename, field.name) : field.index.toString());

          final String parsedKey = (aIsObject ? '"$key"' : key);
          classBuffer.writeln('case $className.$name: return $parsedKey;');
        } classBuffer.writeln('}');

        classBuffer.writeln('return null;');

        classBuffer.writeln('}');
      }
      //------------------------------------------------------------------------
    } return classBuffer.toString();
  }
  
  String encodedFieldName(
    FieldRename fieldRename,
    String declaredName,
  ) {
    switch (fieldRename) {
      case FieldRename.none:
        return declaredName;
      case FieldRename.snake:
        return declaredName.snakeCase;
      case FieldRename.kebab:
        return declaredName.paramCase;
      case FieldRename.pascal:
        return declaredName.pascalCase;
      case FieldRename.camel:
        return declaredName.camelCase;
      case FieldRename.constant:
        return declaredName.constantCase;
    }
  }

  FieldRename? _fromDartObject(ConstantReader reader) => reader.isNull
      ? null
      : enumValueForDartObject(
          reader.objectValue,
          FieldRename.values,
          (f) => f.toString().split('.')[1],
        );

  T enumValueForDartObject<T>(
    DartObject source,
    List<T> items,
    String Function(T) name,
  ) => items.singleWhere((v) => source.getField(name(v)) != null);

  static String typeToJsonGetMethod(ObjectReturnType returnType, String debugClassName) {
    switch(returnType.type) {
      case EType.BOOL:
        return "getBoolean";
      case EType.INT:
        return "getInteger";
      case EType.DOUBLE:
        return "getDouble";
      case EType.STRING:
        return "getString";
      case EType.LIST:
        return "getArray";
      case EType.MAP:
        return "getJsonObject";
      case EType.ENUM:
        return returnType.isJsonObject ? "getString" : "getInteger";
      case EType.DYNAMIC:
      case EType.CLASS:
        return "getDynamic";
      default:
        throw "Unknown type ${returnType.type}";
    }
  }

  static String generateFromJsonMethodName(String className)
    => "_\$${className}FromJson";

  static String generateToJsonMethodName(String className)
    => "_\$${className}ToJson";
  
  static void printWarn(String text, [String? body]) {
    final sb = new StringBuffer();
    sb.writeln("----------------------------------------------------------------------------");
    sb.writeln("WARNING $text");
    sb.writeln(body);
    sb.writeln("----------------------------------------------------------------------------");
    print(sb.toString());
  }

  static final RegExp _regexTemplate = RegExp("<(.*)>");
  static List<String> extractTemplates(String type) {
    final List<String> templates = [];
    final matches = _regexTemplate.allMatches(type);
    if(matches.isNotEmpty) {
      final match = matches.first;
      final group = match.group(1)!;
      templates.add(group);
    } return templates;
  }
}


abstract class ICode {
  bool get nullable;
  List<ICode> get calls;
  void callMethod(FunctionCall call);
}

class Instance extends ICode {
  final String name;

  @override
  final bool nullable;

  final String? suffix;
  
  @override
  final List<ICode> calls = [];
  Instance(this.name, {
    this.nullable = false,
    this.suffix,
    List<ICode>? calls,
  }) {
    this.calls.addAll(calls ?? []);
  }
  
  @override
  void callMethod(FunctionCall call) {
    calls.add(call);
  }

  @override
  String toString() {
    final sb = new StringBuffer();
    sb.write("$name");
    if(suffix != null)
      sb.write("$suffix");
    for(int i = 0; i < calls.length; i++) {
      final isFirst = i == 0;
      final isLast = i == calls.length - 1;
      final call = calls[i];
      
      if(isFirst && nullable)
        sb.write(nullable ? "?" : "");
      if(isLast)
        sb.write(".");
      else sb.write("..");
      sb.write(call.toString());
    } return sb.toString();
  }
}

class FunctionCall extends ICode {
  String name;
  List<dynamic> arguments = [];
  List<String> templates = [];

  @override
  final bool nullable;
  
  String? suffix;
  
  @override
  final List<ICode> calls = [];
  FunctionCall(
    this.name, {
      List<dynamic>? arguments,
      this.suffix,
      this.nullable = false,
  }) {
    this.arguments.addAll(arguments ?? []);
  }
  
  @override
  void callMethod(FunctionCall call) {
    calls.add(call);
  }

  @override
  String toString() {
    final sb = new StringBuffer();
    sb.write("$name");
    if(templates.isNotEmpty) {
      sb.write("<");
      for(int i = 0; i < templates.length; i++) {
        if(i > 0)
          sb.write(", ");
        final template = templates[i];
        sb.write(template);
      }
      sb.write(">");
    }
    sb.write("(");
    for(final argument in arguments) {
      if(argument is ICode)
        sb.write(argument.toString());
      else sb.write(argument.toString());
      sb.write(", ");
    }
    sb.write(")");
    if(suffix != null)
      sb.write(suffix);
    for(final call in calls)
      sb.write("." + call.toString());
    return sb.toString();
  }
}