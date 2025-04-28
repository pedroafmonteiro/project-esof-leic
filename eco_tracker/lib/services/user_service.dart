import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class UserService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getUserRole() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final roleRef = _database.ref().child(user.uid).child('role');
    final snapshot = await roleRef.get();

    if (!snapshot.exists) {
      return 'user';
    }

    return snapshot.value.toString();
  }

  Future<bool> isMaintainer() async {
    try {
      final role = await getUserRole();
      return role == 'maintainer';
    } catch (e) {
      return false;
    }
  }

  Future<String> getUserCompany() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final companyRef = _database.ref().child(user.uid).child('company');
    final snapshot = await companyRef.get();

    if (!snapshot.exists) {
      return '';
    }

    return snapshot.value.toString();
  }

  Future<Map<String, String>> getUserInfo() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final userRef = _database.ref().child(user.uid);
    final snapshot = await userRef.get();

    if (!snapshot.exists) {
      return {
        'role': 'user',
        'company': '',
        'email': user.email ?? '',
        'displayName': user.displayName ?? '',
      };
    }

    final userData = Map<String, dynamic>.from(snapshot.value as Map);

    return {
      'role':
          userData.containsKey('role') ? userData['role'].toString() : 'user',
      'company':
          userData.containsKey('company') ? userData['company'].toString() : '',
      'email': user.email ?? '',
      'displayName': user.displayName ?? '',
    };
  }
}
