// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:macros/macros.dart';
import 'macro_dependency.dart';

macro

class MethodMacro implements ClassDeclarationsMacro {
  const MethodMacro();

  @override
  FutureOr<void> buildDeclarationsForClass(ClassDeclaration clazz,
      MemberDeclarationBuilder builder) async {
    builder.declareInType(new DeclarationCode.fromString(generateBody()));
  }
}
