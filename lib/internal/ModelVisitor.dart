import 'dart:developer';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:json_annotation_ex/library.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_gen/src/type_checker.dart';
import 'package:true_core/core/library.dart';


class ModelVisitor extends SimpleElementVisitor<void> {
  static const TypeChecker jsonSerializableEx = TypeChecker.fromRuntime(JsonSerializableEx);
  static const TypeChecker jsonFieldEx = TypeChecker.fromRuntime(JsonFieldEx);

  late final String className;
  late final bool isEnum;
  late final bool isClass;
  bool parsed = false;


  final List<Field> fields = [];
  final List<Parameter> parameters = [];

  // @override
  // void visitClassElement(ClassElement element) {
  //   debugger();
  //   print(element);
  // }

  ModelVisitor(Element element) {
    if(element is ClassElement) {
      className = element.name.replaceFirst('*', '');
      isClass = !element.isEnum;
      isEnum = element.isEnum;

      if(isClass) {
        final superClasses = element.allSupertypes.map((e) => e.element).where((e) => jsonSerializableEx.firstAnnotationOf(e) != null).toList().reversed.toList();
        fields.addAll(extractFields(superClasses, fields.length));
      }
      
      if(isEnum)
        parsed = true;
    }
  }

  @override
  void visitConstructorElement(ConstructorElement element) {
    final classElement = element.returnType.element;
    // if(classElement.isAbstract)
    //   return;
      
    if(parsed)
      return;
    parsed = true;


    final parameters = element.parameters.toList();
    for(int index = 0; index < parameters.length; index++) {
      final parameter = parameters[index];
      final String name = parameter.name;
      final bool isFinal = parameter.isFinal;

      this.parameters.add(new Parameter(
        index: index,
        name: name,
        isFinal: isFinal,
      ));
    }
  }

  @override
  void visitFieldElement(FieldElement element) {
    if(isEnum && !element.isEnumConstant)
      return;
    final field = extractField(element, fields.length);
    if(fields.tryFirstWhere((e) => e.name == field.name) != null)
      return;
    fields.add(field);
  }

  static List<Field> extractFields(List<ClassElement> classes, int startIndex) {
    final Map<String, Field> outFields = {};
    for(final e in classes) {
      final fields = e.fields.toList();
      for(int i = 0; i < fields.length; i++) {
        final field = fields[i];
        final name = field.name;
        if(outFields.containsKey(name))
          continue;
        outFields[name] = extractField(field, startIndex++);
      }
    } return outFields.values.toList();
  }

  static Field extractField(FieldElement field, int inx) {
    Element typeElement = field.type.element!;
    DartObject? annotation;
    
    final String name = field.name;
    String? key;
    int index = inx;
    final ObjectReturnType returnType = elementToObjectReturnType(typeElement);
    final List<ObjectReturnType> subTypes = [];
    final bool isFinal = field.isFinal;
    final bool isNullable = field.type.nullabilitySuffix == NullabilitySuffix.question;
    bool isJson = false;
    bool isObject = false;
    CutomFieldOptions? options;
    
    annotation = jsonFieldEx.firstAnnotationOfExact(field);
    if(annotation != null) {
      final bool ignore;

      if(annotation.getField("key") != null) {
        key = annotation.getField("key")!.toStringValue() ?? key;
        index = annotation.getField("key")!.toIntValue() ?? index;
      } ignore = annotation.getField("ignore")!.toBoolValue()!;
      
      options = CutomFieldOptions(
        key: key,
        ignore: ignore,
      );
    }

    annotation = jsonSerializableEx.firstAnnotationOf(typeElement);
    if(annotation != null) {
      isJson = true;
      isObject = annotation.getField("isObject")!.toBoolValue()!;
    }

    if(field.type is InterfaceType) {
      final type = field.type as InterfaceType;
      returnType.templates.addAll(type.typeArguments.map((e) => elementToObjectReturnType(e.element!)));
    }

    return new Field(
      index: index,
      name: name,
      returnType: returnType,
      key: key,
      isFinal: isFinal,
      isNullable: isNullable,
      options: options,
    );
  }

  static ObjectReturnType elementToObjectReturnType(Element element) {
    EType? type;
    bool isJson = false;
    bool isJsonObject = false;
    switch(element.name) {
      case "dynamic": type = EType.DYNAMIC; break;
      case "bool": type = EType.BOOL; break;
      case "int": type = EType.INT; break;
      case "double": type = EType.DOUBLE; break;
      case "String": type = EType.STRING; break;
      case "Iterable": type = EType.LIST; break;
      case "List": type = EType.LIST; break;
      case "Map": type = EType.MAP; break;
    }

    if(type == null && element is ClassElement) {
      final annotation = jsonSerializableEx.firstAnnotationOf(element);
      if(annotation != null) {
        isJson = true;
        isJsonObject = annotation.getField("isObject")!.toBoolValue()!;
      }

      if(element.isEnum)
        type = EType.ENUM;
      else type = EType.CLASS;
    }
    
    if(type == null)
      throw(new Exception("unknown type ${element.name}"));
    return new ObjectReturnType(
      type: type,
      name: element.name!,
      templates: [],
      isJson: isJson,
      isJsonObject: isJsonObject,
    );
  }
}

class Field {
  final int index;
  final String name;
  final String? key;
  final ObjectReturnType returnType;
  final bool isFinal;
  final bool isNullable;
  final CutomFieldOptions? options;
  const Field({
    required this.index,
    required this.name,
    required this.key,
    required this.returnType,
    required this.isFinal,
    required this.isNullable,
    required this.options,
  });
}

class ObjectReturnType {
  final EType type;
  final String name;
  final List<ObjectReturnType> templates;
  final bool isJson;
  final bool isJsonObject;
  ObjectReturnType({
    required this.type,
    required this.name,
    required this.templates,
    required this.isJson,
    required this.isJsonObject,
  });
}

enum EType {
  DYNAMIC,
  BOOL,
  INT,
  DOUBLE,
  STRING,
  LIST,
  MAP,
  ENUM,
  CLASS,
}

class CutomFieldOptions {
  final dynamic key;
  final bool ignore;
  const CutomFieldOptions({
    required this.key,
    required this.ignore,
  });
}

class Parameter {
  final int index;
  final String name;
  final bool isFinal;
  Parameter({
    required this.index,
    required this.name,
    required this.isFinal,
  });
}