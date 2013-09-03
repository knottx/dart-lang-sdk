// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "dart:async";
import "dart:io";

import "package:async_helper/async_helper.dart";
import "package:expect/expect.dart";


void testWatchCreateFile() {
  var dir = new Directory('').createTempSync();
  var file = new File(dir.path + '/file');

  var watcher = dir.watch();

  asyncStart();
  var sub;
  sub = watcher.listen((event) {
    if (event is FileSystemCreateEvent &&
        event.path.endsWith('file')) {
      asyncEnd();
      sub.cancel();
      dir.deleteSync(recursive: true);
    }
  }, onError: (e) {
    dir.deleteSync(recursive: true);
    throw e;
  });

  file.createSync();
}


void testWatchModifyFile() {
  var dir = new Directory('').createTempSync();
  var file = new File(dir.path + '/file');
  file.createSync();

  var watcher = dir.watch();

  asyncStart();
  var sub;
  sub = watcher.listen((event) {
    if (event is FileSystemModifyEvent) {
      Expect.isTrue(event.path.endsWith('file'));
      sub.cancel();
      asyncEnd();
      dir.deleteSync(recursive: true);
    }
  }, onError: (e) {
    dir.deleteSync(recursive: true);
    throw e;
  });

  file.writeAsStringSync('a');
}


void testWatchMoveFile() {
  var dir = new Directory('').createTempSync();
  var file = new File(dir.path + '/file');
  file.createSync();

  var watcher = dir.watch();

  asyncStart();
  var sub;
  sub = watcher.listen((event) {
    if (event is FileSystemMoveEvent) {
      Expect.isTrue(event.path.endsWith('file'));
      Expect.isTrue(event.destination.endsWith('file2'));
      sub.cancel();
      asyncEnd();
      dir.deleteSync(recursive: true);
    }
  }, onError: (e) {
    dir.deleteSync(recursive: true);
    throw e;
  });

  file.renameSync(dir.path + '/file2');
}


void testWatchDeleteFile() {
  var dir = new Directory('').createTempSync();
  var file = new File(dir.path + '/file');
  file.createSync();

  var watcher = dir.watch();

  asyncStart();
  var sub;
  sub = watcher.listen((event) {
    if (event is FileSystemDeleteEvent) {
      Expect.isTrue(event.path.endsWith('file'));
      sub.cancel();
      asyncEnd();
      dir.deleteSync(recursive: true);
    }
  }, onDone: () {
    Expect.isTrue(gotEvent);
  }, onError: (e) {
    dir.deleteSync(recursive: true);
    throw e;
  });

  file.deleteSync();
}


void testWatchOnlyModifyFile() {
  var dir = new Directory('').createTempSync();
  var file = new File(dir.path + '/file');

  var watcher = dir.watch(events: FileSystemEvent.MODIFY);

  asyncStart();
  var sub;
  sub = watcher.listen((event) {
    Expect.isTrue(event is FileSystemModifyEvent);
    Expect.isTrue(event.path.endsWith('file'));
    sub.cancel();
    asyncEnd();
    dir.deleteSync(recursive: true);
  }, onError: (e) {
    dir.deleteSync(recursive: true);
    throw e;
  });

  file.createSync();
  file.writeAsStringSync('a');
}


void testMultipleEvents() {
  var dir = new Directory('').createTempSync();
  var file = new File(dir.path + '/file');
  var file2 = new File(dir.path + '/file2');

  var watcher = dir.watch();

  asyncStart();
  int state = 0;
  var sub;
  sub = watcher.listen((event) {
    switch (state) {
      case 0:
        Expect.isTrue(event is FileSystemCreateEvent);
        state = 1;
        break;

      case 1:
        if (event is FileSystemCreateEvent) break;
        Expect.isTrue(event is FileSystemModifyEvent);
        state = 2;
        break;

      case 2:
        if (event is FileSystemModifyEvent) break;
        Expect.isTrue(event is FileSystemMoveEvent);
        state = 3;
        break;

      case 3:
        if (event is FileSystemMoveEvent) break;
        Expect.isTrue(event is FileSystemDeleteEvent);
        sub.cancel();
        asyncEnd();
        dir.deleteSync();
        break;
    }
  });

  file.createSync();
  file.writeAsStringSync('a');
  file.renameSync(file2.path);
  file2.deleteSync();
}


void testWatchRecursive() {
  var dir = new Directory('').createTempSync();
  if (Platform.isLinux) {
    Expect.throws(() => dir.watch(recursive: true));
    return;
  }
  var dir2 = new Directory(dir.path + '/dir');
  dir2.createSync();
  var file = new File(dir.path + '/dir/file');

  var watcher = dir.watch(recursive: true);

  asyncStart();
  var sub;
  sub = watcher.listen((event) {
    if (event.path.endsWith('file')) {
      sub.cancel();
      asyncEnd();
      dir.deleteSync(recursive: true);
    }
  }, onError: (e) {
    dir.deleteSync(recursive: true);
    throw e;
  });

  file.createSync();
}


void testWatchNonRecursive() {
  var dir = new Directory('').createTempSync();
  var dir2 = new Directory(dir.path + '/dir');
  dir2.createSync();
  var file = new File(dir.path + '/dir/file');

  var watcher = dir.watch(recursive: false);

  asyncStart();
  var sub;
  sub = watcher.listen((event) {
    if (event.path.endsWith('file')) {
      throw "File change event not expected";
    }
  }, onError: (e) {
    dir.deleteSync(recursive: true);
    throw e;
  });

  file.createSync();

  new Timer(const Duration(milliseconds: 300), () {
    sub.cancel();
    asyncEnd();
    dir.deleteSync(recursive: true);
  });
}


void main() {
  testWatchCreateFile();
  testWatchModifyFile();
  testWatchMoveFile();
  testWatchDeleteFile();
  testWatchOnlyModifyFile();
  testMultipleEvents();
  testWatchNonRecursive();
}
