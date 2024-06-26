// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

extension NullableObjectExtension on Object? {
  /// If the target is [T], return it, otherwise `null`.
  T? ifTypeOrNull<T>() {
    var self = this;
    return self is T ? self : null;
  }
}
