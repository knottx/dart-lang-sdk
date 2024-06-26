// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Note: When an interface is implemented by single instantiated class, an `is`
// test on the interface can be compiled to an `is` test on the instantiated
// class and implemented as an `instanceof` test.
// [testSingleInstantatiedSubtype] demonstates that an `$is` property is not
// required when the optimization applies (the empty `checks=[]` data).
// [testMultipleInstantatiedSubtypes] avoids the optimization by adding another
// instantiated class that implements the tested interface so there is true
// multiple inheritance. The `checks=` then contain the required `$is` property.

/*class: A:*/
class A {}

/*class: B:checks=[],indirectInstance*/
class B implements A {}

/*class: C:checks=[],instance*/
class C extends B {} // Implements A through `extends B`.

@pragma('dart2js:noInline')
test(o) => o is A;

testSingleInstantatiedSubtype() {
  test(new C());
  test(null);
}

/*class: A2:checkedInstance*/
class A2 {}

/*class: B2:checks=[$isA2],indirectInstance*/
class B2 implements A2 {}

/*class: C2:checks=[],instance*/
class C2 extends B2 {} // Implements A2 through `extends B2`.

/*class: D2:checks=[$isA2],instance*/
class D2 implements A2 {} // Second class implementing A2.

@pragma('dart2js:noInline')
testA2(o) => o is A2;

testMultipleInstantatiedSubtypes() {
  testA2(C2());
  testA2(D2());
  testA2(null);
}

main() {
  testSingleInstantatiedSubtype();
  testMultipleInstantatiedSubtypes();
}
