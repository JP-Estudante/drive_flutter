    Future<void> _loginWithGoogle() async {  
       signedIn = await storage.read(key: "signedIn") == "true" ? true : false;  
       googleSignIn.onCurrentUserChanged  
           .listen((GoogleSignInAccount googleSignInAccount) async {  
         if (googleSignInAccount != null) {  
           _afterGoogleLogin(googleSignInAccount);  
         }  
       });  
       if (signedIn) {  
         try {  
           googleSignIn.signInSilently().whenComplete(() => () {});  
         } catch (e) {  
           storage.write(key: "signedIn", value: "false").then((value) {  
             setState(() {  
               signedIn = false;  
             });  
           });  
         }  
       } else {  
         final GoogleSignInAccount googleSignInAccount =  
             await googleSignIn.signIn();  
         _afterGoogleLogin(googleSignInAccount);  
       }  
     }  

     Future<void> _afterGoogleLogin(GoogleSignInAccount gSA) async {  
       googleSignInAccount = gSA;  
       final GoogleSignInAuthentication googleSignInAuthentication =  
           await googleSignInAccount.authentication;  

       final AuthCredential credential = GoogleAuthProvider.getCredential(  
         accessToken: googleSignInAuthentication.accessToken,  
         idToken: googleSignInAuthentication.idToken,  
       );  

       final AuthResult authResult = await _auth.signInWithCredential(credential);  
       final FirebaseUser user = authResult.user;  

       assert(!user.isAnonymous);  
       assert(await user.getIdToken() != null);  

       final FirebaseUser currentUser = await _auth.currentUser();  
       assert(user.uid == currentUser.uid);  

       print('signInWithGoogle succeeded: $user');  

       storage.write(key: "signedIn", value: "true").then((value) {  
         setState(() {  
           signedIn = true;  
         });  
       });  
     } 