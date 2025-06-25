import 'package:digital_certificate_project/auth/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'generate_cert.dart'; // Add this at the top



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Required before Firebase use
  runApp(CertificateApp());
}

class CertificateApp extends StatelessWidget {
  CertificateApp({super.key});

  final AuthService _authService = AuthService(); // for logout

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Certificate Authority',
      theme: ThemeData(

        colorScheme: ColorScheme.light(
          primary: Colors.indigo,
          secondary: Colors.indigoAccent,
          surface: Colors.white,
          background: Colors.grey[100]!,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Colors.black,
          onBackground: Colors.white54,
        ),
        scaffoldBackgroundColor: Colors.grey[100],
        useMaterial3: true,
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Color.fromARGB(255, 0, 0, 0),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.indigo),
          ),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color.fromARGB(181, 0, 0, 0), // Your custom black color
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontFamily: 'RobotoMono',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),

      ),
      home: HomePage(authService: _authService),
      debugShowCheckedModeBanner: false,
    );
  }

}

class Client {
  String id; // Firestore document ID
  String name;
  String event;
  String issuanceDate;

  Client(this.name, {this.id = '', this.event = '', this.issuanceDate = ''});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'event': event,
      'issuanceDate': issuanceDate,
    };
  }

  factory Client.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Client(
      data['name'] ?? '',
      id: doc.id,
      event: data['event'] ?? '',
      issuanceDate: data['issuanceDate'] ?? '',
    );
  }
}


class HomePage extends StatefulWidget {
  final AuthService authService;
  const HomePage({super.key, required this.authService});

  @override
  State<HomePage> createState() => _HomePageState();


}

class _HomePageState extends State<HomePage> {
  List<Client> clients = [
    Client('Ali Abu Yazid', event: 'Coding Bootcamp', issuanceDate: '2025-06-21'),
    Client('Yu Ji-min', event: 'Artificial Intelligence Course', issuanceDate: '2025-03-23')
  ];


  void _addClient() async {
    final nameController = TextEditingController();
    final eventController = TextEditingController();
    final dateController = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Add Client'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: eventController,
                decoration: InputDecoration(labelText: 'Event'),
              ),
              TextField(
                controller: dateController,
                decoration: InputDecoration(labelText: 'Issuance Date'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, {
                  'name': nameController.text,
                  'event': eventController.text,
                  'date': dateController.text,
                });
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );

    if (!mounted || result == null || result['name']!.trim().isEmpty) return;

    final newClient = Client(
      result['name']!.trim(),
      event: result['event'] ?? '',
      issuanceDate: result['date'] ?? '',
    );

    try {
      final docRef = await FirebaseFirestore.instance
          .collection('clients')
          .add(newClient.toMap());

      setState(() {
        clients.add(Client(
          newClient.name,
          event: newClient.event,
          issuanceDate: newClient.issuanceDate,
        ));
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Client added to Firestore')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding client: $e')),
      );
    }
  }





  void _saveNewClient(String name) async {
    final newClient = Client(name);

    setState(() {
      clients.add(newClient);
    });

    try {
      await FirebaseFirestore.instance.collection('clients').add(newClient.toMap());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Client added to Firestore')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding client to Firestore')),
      );
    }
  }



  void _editClient(int index) async {
    final client = clients[index];
    final nameController = TextEditingController(text: client.name);
    final eventController = TextEditingController(text: client.event);
    final dateController = TextEditingController(text: client.issuanceDate);

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Client'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: eventController,
              decoration: InputDecoration(labelText: 'Event Joined'),
            ),
            TextField(
              controller: dateController,
              decoration: InputDecoration(labelText: 'Issuance Date'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, {
              'name': nameController.text,
              'event': eventController.text,
              'date': dateController.text,
            }),
            child: Text('Save'),
          ),
        ],
      ),
    );

    // 🛑 Avoid using context if widget is gone
    if (!mounted || result == null) return;

    setState(() {
      client.name = result['name'] ?? client.name;
      client.event = result['event'] ?? client.event;
      client.issuanceDate = result['date'] ?? client.issuanceDate;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('clients')
          .where('name', isEqualTo: client.name)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.update(client.toMap());
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Client updated in Firestore')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating client: $e')),
      );
    }
  }





  void _goToGenerateCertPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GenerateCertPage()),
    );
  }

  void _viewAll() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ViewAllPage(clients: clients)),
    );
  }

  void _goToLtcPage() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => LtcPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Certificate Authority"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () async {
              await widget.authService.signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white54, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _goToGenerateCertPage,
                      style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.card_membership, size: 20),
                          SizedBox(height: 6),
                          Text(
                            'Generate Cert',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _goToLtcPage,
                      style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_user, size: 20),
                          SizedBox(height: 6),
                          Text(
                            'CTC',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _addClient,
                      style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 20),
                          SizedBox(height: 6),
                          Text(
                            'Add Name',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _viewAll,
                      style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.list, size: 20),
                          SizedBox(height: 6),
                          Text(
                            'View All',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),


              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: clients.length,
                  itemBuilder: (context, index) {
                    final client = clients[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Text(
                          client.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Event: ${client.event}\nDate: ${client.issuanceDate}',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.edit, color: Colors.black),
                          onPressed: () => _editClient(index),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GenerateCertFirestorePage extends StatelessWidget {
  const GenerateCertFirestorePage({super.key});

  Future<List<Map<String, dynamic>>> fetchRequestCertData() async {
    final snapshot = await FirebaseFirestore.instance.collection('requestCert').get();
    print("📄 Documents fetched: ${snapshot.docs.length}");
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  void _uploadFile(BuildContext context, Map<String, dynamic> data) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      final file = result.files.first;
      final fileName = '${data['name']}_${DateTime.now().millisecondsSinceEpoch}.${file.extension}';
      final storageRef = FirebaseStorage.instance.ref().child('certificates/$fileName');

      try {
        await storageRef.putData(file.bytes!);
        final downloadUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance.collection('requestCert').add({
          'name': data['name'],
          'event': data['title'],
          'issuanceDate': data['date'],
          'fileUrl': downloadUrl,
          'fileType': file.extension,
          'uploadedAt': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Uploaded & saved for ${data['name']}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print("🧱 GenerateCertFirestorePage build() called");
    return Scaffold(
      appBar: AppBar(title: Text('Request Certificates'), centerTitle: true),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchRequestCertData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final dataList = snapshot.data!;
          if (dataList.isEmpty) {
            return const Center(child: Text('No certificate requests found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dataList.length,
            itemBuilder: (context, index) {
              final data = dataList[index];
              final timestamp = data['uploadedAt'];
              final readableTime = timestamp is Timestamp
                  ? DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch).toLocal().toString()
                  : 'N/A';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['name'] ?? '',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("Event: ${data['title'] ?? 'No title'}"),
                      Text("Issuance Date: ${data['date'] ?? 'No date'}"),
                      if (timestamp != null)
                        Text("Uploaded At: $readableTime", style: TextStyle(color: Colors.grey[700])),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.upload_file),
                            label: const Text("Upload Cert"),
                            onPressed: () => _uploadFile(context, data),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


class ViewAllPage extends StatelessWidget {
  final List<Client> clients;
  const ViewAllPage({super.key, required this.clients});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("All Clients"), centerTitle: true),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white , Colors.white],
          ),
        ),
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: clients.length,
          itemBuilder: (context, index) {
            final client = clients[index];
            return Card(
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                title: Text(client.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('Event: ${client.event} | Date: ${client.issuanceDate}'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class LtcPage extends StatelessWidget {
  const LtcPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("CTC Page"), centerTitle: true),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[900]!, Colors.black],
          ),
        ),
        child: Center(
          child: Text("CTC Content", style: TextStyle(fontSize: 24)),
        ),
      ),
    );
  }
}
