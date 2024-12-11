    _uploadFileToGoogleDrive() async {  
       var client = GoogleHttpClient(await googleSignInAccount.authHeaders);  
       var drive = ga.DriveApi(client);  
       ga.File fileToUpload = ga.File();  
       var file = await FilePicker.getFile();  
       fileToUpload.parents = ["appDataFolder"];  
       fileToUpload.name = path.basename(file.absolute.path);  
       var response = await drive.files.create(  
         fileToUpload,  
         uploadMedia: ga.Media(file.openRead(), file.lengthSync()),  
       );  
       print(response);  
     } 