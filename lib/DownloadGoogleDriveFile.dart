//  Future<void> _downloadGoogleDriveFile(String fName, String gdID) async {  
//        var client = GoogleHttpClient(await googleSignInAccount.authHeaders);  
//        var drive = ga.DriveApi(client);  
//        ga.Media file = await drive.files  
//            .get(gdID, downloadOptions: ga.DownloadOptions.FullMedia);  
//        print(file.stream);  

//        final directory = await getExternalStorageDirectory();  
//        print(directory.path);  
//        final saveFile = File('${directory.path}/${new DateTime.now().millisecondsSinceEpoch}$fName');  
//        List<int> dataStore = [];  
//        file.stream.listen((data) {  
//          print("DataReceived: ${data.length}");  
//          dataStore.insertAll(dataStore.length, data);  
//        }, onDone: () {  
//          print("Task Done");  
//          saveFile.writeAsBytes(dataStore);  
//          print("File saved at ${saveFile.path}");  
//        }, onError: (error) {  
//          print("Some Error");  
//        });  
//      }  