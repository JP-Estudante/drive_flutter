import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Drive Integration',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GoogleSignIn googleSignIn = GoogleSignIn.standard(scopes: [ga.DriveApi.driveScope]);
  final FirebaseAuth _auth = FirebaseAuth.instance;

  GoogleSignInAccount? googleSignInAccount;
  final TextEditingController _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Google Drive Integration')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _loginWithGoogle,
              child: Text('Login com Google'),
            ),
            ElevatedButton(
              onPressed: () => _showNoteModal(context),
              child: Text('Criar Nota e Salvar no Drive'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loginWithGoogle() async {
    googleSignIn.onCurrentUserChanged.listen((account) {
      if (account != null) _afterGoogleLogin(account);
    });

    try {
      googleSignInAccount = await googleSignIn.signIn();
      _afterGoogleLogin(googleSignInAccount);
    } catch (e) {
      print('Erro no login: $e');
    }
  }

  Future<void> _afterGoogleLogin(GoogleSignInAccount? account) async {
    if (account == null) return;
    final GoogleSignInAuthentication auth = await account.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );

    await _auth.signInWithCredential(credential);
    print('Login realizado!');
  }

  void _showNoteModal(BuildContext context) {
    final FocusNode _focusNode = FocusNode();
    _noteController.clear(); // Limpa o campo de texto ao abrir o modal
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                focusNode: _focusNode,
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Digite sua nota',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final noteText = _noteController.text.trim();
                  if (noteText.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Nota não pode ser vazia!')),
                    );
                  } else {
                    _saveNoteToGoogleDrive(noteText);
                    Navigator.pop(context); // Fecha o modal
                  }
                },
                child: Text('Salvar no Drive'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveNoteToGoogleDrive(String noteText) async {
    try {
      if (noteText.isEmpty) {
        print('Texto da nota está vazio.');
        return;
      }

      var client = GoogleHttpClient(await googleSignIn.currentUser!.authHeaders);
      var drive = ga.DriveApi(client);

      var fileToUpload = ga.File();
      fileToUpload.name = 'nota_${DateTime.now().toIso8601String()}.txt';

      await drive.files.create(
        fileToUpload,
        uploadMedia: ga.Media(
          Stream.fromIterable([noteText.codeUnits]),
          noteText.length,
        ),
      );

      print('Nota enviada com sucesso!');
    } catch (e) {
      print('Erro ao salvar nota: $e');
    }
  }
}

class GoogleHttpClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  GoogleHttpClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _inner.send(request..headers.addAll(_headers));
  }
}
