import 'package:flutter/material.dart';
import 'package:google_docs/screens/documentsScreen.dart';
import 'package:google_docs/screens/homeScreen.dart';
import 'package:google_docs/screens/loginScreen.dart';
import 'package:routemaster/routemaster.dart';

final loggedOutRoute = RouteMap(
    routes: {'/': (route) => const MaterialPage(child: LoginScreen())});

final loggedInRoute = RouteMap(routes: {
  '/': (route) => const MaterialPage(child: HomeScreen()),
  '/document/:id': (route) =>
      MaterialPage(child: DocumentScreen(id: route.pathParameters['id'] ?? ''))
});
