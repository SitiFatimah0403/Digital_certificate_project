import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

//Open google login screen 
  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

  //retrieve accessToken & idToken from Google 
    final googleAuth = await googleUser.authentication;

//Create firebase credential from accessToken & idToken
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

//logs user into firebase using Google credential (link to Firebase Authentication )
    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;

  //only allow user that using their upm account to login 
    if (user != null && user.email!.endsWith('@upm.edu.my')) {
      return user;
    } else {
      await signOut();
      throw Exception('Only @upm.edu.my emails are allowed');
    }
  }

//log user out of both firebase and google account
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

//expose currently signed in firebase user
  User? get currentUser => _auth.currentUser;
}


//Next :
/* 
1) Link this service to your LoginScreen button.

2) After login, check the user's role from Firestore and redirect accordingly.

3) Handle error from signInWithGoogle() and show a dialog/snackbar for invalid domains.
*/