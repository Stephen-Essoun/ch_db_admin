import 'package:ch_db_admin/shared/failure.dart';
import 'package:ch_db_admin/shared/usecase.dart';
import 'package:ch_db_admin/src/dependencies/auth.dart';
import 'package:ch_db_admin/src/auth/domain/entities/user_credentials.dart';
import 'package:ch_db_admin/src/auth/domain/usecase/log_out.dart';
import 'package:ch_db_admin/src/auth/domain/usecase/sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends ChangeNotifier {
  final SignIn _signIn;
  final SignOut _signOut;

  AuthController({
    required SignIn signIn,
    required SignOut signOut,
  })  : _signIn = signIn,
        _signOut = signOut;

  bool _isLoading = false;
  get isLoading => _isLoading;

  Future<String?> getOrgName() async {
    // Retrieve the stored organization ID from SharedPreferences
    final orgId = locator.get<SharedPreferences>().getString('org_id');

    if (orgId == null) {
      print('Organization ID is not set');
      return null;
    }

    // Reference to the Firestore document for the organization
    final db =
        FirebaseFirestore.instance.collection('organisations').doc(orgId);

    try {
      // Get the document from Firestore
      final snapshot = await db.get();

      // Check if the document exists and retrieve the `orgName` field
      if (snapshot.exists) {
        print('orgName exits');
        return snapshot.data()?['orgName'] as String?;
      } else {
        print('No organization found for ID: $orgId');
        return null;
      }
    } catch (e) {
      print('Error retrieving organization name: $e');
      return null;
    }
  }

  // Function to set or update the orgName in Firestore
  Future<void> setOrgName(String orgName) async {
    // Retrieve the stored organization ID from SharedPreferences
    final orgId = locator.get<SharedPreferences>().getString('org_id');

    if (orgId == null) {
      print('Organization ID is not set');
      return;
    }

    // Reference to the Firestore document for the organization
    final db =
        FirebaseFirestore.instance.collection('organisations').doc(orgId);

    try {
      // Set or update the `orgName` field in Firestore
      await db.set({'orgName': orgName});
      print('Organization name updated successfully');
    } catch (e) {
      print('Error updating organization name: $e');
    }
  }

  Future<Either<Failure, User?>> signIn(UserLoginCredentials data) async {
    _isLoading = true;
    notifyListeners();
    final result = await _signIn(Params(data));
    _isLoading = false;
    notifyListeners();
    return result.fold((failure) {
      return left(Failure(failure.message));
    }, (success) async {
      final prefs = locator.get<SharedPreferences>();
      prefs.setString('org_id', success!.uid);
      return right(success);
    });
  }

  Future<Either<Failure, String>> signOut() async {
     _isLoading = true;
    notifyListeners();
    final result = await _signOut(NoParams());
    return result.fold((failure) {
       _isLoading = false;
    notifyListeners();
      return left(Failure(failure.message));
    }, (success) {
       _isLoading = false;
    notifyListeners();
      return right(success);
    });
  }
}