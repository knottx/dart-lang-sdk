// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class C {
  /*member: C._private:explicit=[_private.T],needsArgs,selectors=[Selector(call, _private, arity=1, types=1)],test*/
  _private<T>(t) => t is T;
}

main() {
  dynamic c = C();
  c._private<int>(0);
}
