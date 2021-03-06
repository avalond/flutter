// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

final GlobalKey<ScrollableState> scrollableKey = new GlobalKey<ScrollableState>();

bool refreshCalled = false;

Future<Null> refresh() {
  refreshCalled = true;
  return new Future<Null>.value();
}

Future<Null> holdRefresh() {
  refreshCalled = true;
  return new Completer<Null>().future;
}

void main() {
  testWidgets('RefreshIndicator', (WidgetTester tester) async {
    refreshCalled = false;
    await tester.pumpWidget(
      new RefreshIndicator(
        scrollableKey: scrollableKey,
        refresh: refresh,
        child: new Block( // ignore: DEPRECATED_MEMBER_USE
          scrollableKey: scrollableKey,
          children: <String>['A', 'B', 'C', 'D', 'E', 'F'].map((String item) {
            return new SizedBox(
              height: 200.0,
              child: new Text(item)
            );
          }).toList(),
        ),
      ),
    );

    await tester.fling(find.text('A'), const Offset(0.0, 300.0), 1000.0);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1)); // finish the scroll animation
    await tester.pump(const Duration(seconds: 1)); // finish the indicator settle animation
    await tester.pump(const Duration(seconds: 1)); // finish the indicator hide animation
    expect(refreshCalled, true);
  });

  testWidgets('RefreshIndicator - bottom', (WidgetTester tester) async {
    refreshCalled = false;
    await tester.pumpWidget(
      new RefreshIndicator(
        scrollableKey: scrollableKey,
        refresh: refresh,
        location: RefreshIndicatorLocation.bottom,
        child: new Block( // ignore: DEPRECATED_MEMBER_USE
          scrollableKey: scrollableKey,
          children: <Widget>[
            new SizedBox(
              height: 200.0,
              child: new Text('X')
            ),
          ],
        ),
      ),
    );

    await tester.fling(find.text('X'), const Offset(0.0, -300.0), 1000.0);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1)); // finish the scroll animation
    await tester.pump(const Duration(seconds: 1)); // finish the indicator settle animation
    await tester.pump(const Duration(seconds: 1)); // finish the indicator hide animation
    expect(refreshCalled, true);
  });

  testWidgets('RefreshIndicator - not enough', (WidgetTester tester) async {
    refreshCalled = false;
    await tester.pumpWidget(
      new RefreshIndicator(
        scrollableKey: scrollableKey,
        refresh: refresh,
        child: new Block( // ignore: DEPRECATED_MEMBER_USE
          scrollableKey: scrollableKey,
          children: <Widget>[
            new SizedBox(
              height: 200.0,
              child: new Text('X')
            ),
          ],
        ),
      ),
    );

    await tester.fling(find.text('X'), const Offset(0.0, 100.0), 1000.0);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(refreshCalled, false);
  });

  testWidgets('RefreshIndicator - show - slow', (WidgetTester tester) async {
    refreshCalled = false;
    await tester.pumpWidget(
      new RefreshIndicator(
        scrollableKey: scrollableKey,
        refresh: holdRefresh, // this one never returns
        child: new Block( // ignore: DEPRECATED_MEMBER_USE
          scrollableKey: scrollableKey,
          children: <Widget>[
            new SizedBox(
              height: 200.0,
              child: new Text('X')
            ),
          ],
        ),
      ),
    );

    bool completed = false;
    tester.state<RefreshIndicatorState>(find.byType(RefreshIndicator))
      .show()
      .then<Null>((Null value) { completed = true; });
    await tester.pump();
    expect(completed, false);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(refreshCalled, true);
    expect(completed, false);
    completed = false;
    refreshCalled = false;
    tester.state<RefreshIndicatorState>(find.byType(RefreshIndicator))
      .show()
      .then<Null>((Null value) { completed = true; });
    await tester.pump();
    expect(completed, false);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(refreshCalled, false);
  });

  testWidgets('RefreshIndicator - show - fast', (WidgetTester tester) async {
    refreshCalled = false;
    await tester.pumpWidget(
      new RefreshIndicator(
        scrollableKey: scrollableKey,
        refresh: refresh,
        child: new Block( // ignore: DEPRECATED_MEMBER_USE
          scrollableKey: scrollableKey,
          children: <Widget>[
            new SizedBox(
              height: 200.0,
              child: new Text('X')
            ),
          ],
        ),
      ),
    );

    bool completed = false;
    tester.state<RefreshIndicatorState>(find.byType(RefreshIndicator))
      .show()
      .then<Null>((Null value) { completed = true; });
    await tester.pump();
    expect(completed, false);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(refreshCalled, true);
    expect(completed, true);
    completed = false;
    refreshCalled = false;
    tester.state<RefreshIndicatorState>(find.byType(RefreshIndicator))
      .show()
      .then<Null>((Null value) { completed = true; });
    await tester.pump();
    expect(completed, false);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(refreshCalled, true);
    expect(completed, true);
  });

  testWidgets('RefreshIndicator - show - fast - twice', (WidgetTester tester) async {
    refreshCalled = false;
    await tester.pumpWidget(
      new RefreshIndicator(
        scrollableKey: scrollableKey,
        refresh: refresh,
        child: new Block( // ignore: DEPRECATED_MEMBER_USE
          scrollableKey: scrollableKey,
          children: <Widget>[
            new SizedBox(
              height: 200.0,
              child: new Text('X')
            ),
          ],
        ),
      ),
    );

    bool completed1 = false;
    tester.state<RefreshIndicatorState>(find.byType(RefreshIndicator))
      .show()
      .then<Null>((Null value) { completed1 = true; });
    bool completed2 = false;
    tester.state<RefreshIndicatorState>(find.byType(RefreshIndicator))
      .show()
      .then<Null>((Null value) { completed2 = true; });
    await tester.pump();
    expect(completed1, false);
    expect(completed2, false);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(refreshCalled, true);
    expect(completed1, true);
    expect(completed2, true);
  });
}
