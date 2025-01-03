import 'dart:io';

import 'package:ch_db_admin/shared/exceptions/app_exception.dart';
import 'package:ch_db_admin/shared/exceptions/database_exception.dart';
import 'package:ch_db_admin/shared/exceptions/network_exception.dart';
import 'package:ch_db_admin/src/attendance/data/models/attendance.dart';
import 'package:ch_db_admin/src/dependencies/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceDB {
  final prefs = locator.get<SharedPreferences>();
  final db = FirebaseFirestore.instance
      .collection('organisations')
      .doc(locator.get<SharedPreferences>().getString('org_id'))
      .collection('attendance');

  // CREATE: Add a new attendance record
  Future<String> createAttendance(AttendanceModel attendanceData) async {
    try {
      final docRef = db.doc();
      await docRef.set(attendanceData.toJson());
      return 'Attendance record added successfully';
    } on FirebaseException catch (e) {
      throw DatabaseException(
          e.message ?? 'Couldn\'t create attendance record. Try again.',
          code: e.code);
    } on SocketException catch (e) {
      throw NetworkException(e.message);
    } on Exception catch (e) {
      throw AppException(e.toString());
    }
  }

  // READ: Fetch all attendance records
  Future<List<AttendanceModel>> getAllAttendance() async {
    try {
      final snapshot = await db.get();
      final attendanceRecords = snapshot.docs
          .map((doc) => AttendanceModel.fromFirestore(doc))
          .toList();
      return attendanceRecords;
    } on FirebaseException catch (e) {
      throw DatabaseException(
          e.message ?? 'Couldn\'t fetch attendance records. Try again.',
          code: e.code);
    } on SocketException catch (e) {
      throw NetworkException(e.message);
    } on Exception catch (e) {
      throw AppException(e.toString());
    }
  }

  // READ: Fetch a single attendance record by ID
  Future<AttendanceModel?> getAttendanceById(String recordId) async {
    try {
      final docSnapshot = await db.doc(recordId).get();
      if (docSnapshot.exists) {
        return AttendanceModel.fromFirestore(docSnapshot);
      } else {
        print("Attendance record not found.");
        return null;
      }
    } on FirebaseException catch (e) {
      throw DatabaseException(
          e.message ?? 'Couldn\'t fetch attendance record. Try again.',
          code: e.code);
    } on SocketException catch (e) {
      throw NetworkException(e.message);
    } on Exception catch (e) {
      throw AppException(e.toString());
    }
  }

  // UPDATE: Update an attendance record by ID
  // Future<String> updateAttendance(AttendanceModel updatedData) async {
  //   try {
  //     await db.doc(updatedData.id).update(updatedData.toJson());
  //     print("Attendance record updated successfully.");
  //     return 'Attendance record updated successfully';
  //   } on FirebaseException catch (e) {
  //     throw DatabaseException(
  //         e.message ?? 'Couldn\'t update attendance record. Try again.',
  //         code: e.code);
  //   } on SocketException catch (e) {
  //     throw NetworkException(e.message);
  //   } on Exception catch (e) {
  //     throw AppException(e.toString());
  //   }
  // }

  // DELETE: Delete an attendance record by ID
  Future<String> deleteAttendance(String recordId) async {
    try {
      await db.doc(recordId).delete();
      print("Attendance record deleted successfully.");
      return 'Attendance record deleted successfully';
    } on FirebaseException catch (e) {
      throw DatabaseException(
          e.message ?? 'Couldn\'t delete attendance record. Try again.',
          code: e.code);
    } on SocketException catch (e) {
      throw NetworkException(e.message);
    } on Exception catch (e) {
      throw AppException(e.toString());
    }
  }
}