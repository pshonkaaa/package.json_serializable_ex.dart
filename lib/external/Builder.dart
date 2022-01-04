library truecollaboration.json_serializable_ex;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'ExtensionGenerator.dart';


Builder generateExtension(BuilderOptions options)
  => SharedPartBuilder([ExtensionGenerator()], 'extension_generator');