import 'package:digital_certificate_project/auth/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() {
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
        colorScheme: ColorScheme.dark(
          primary: Colors.indigo,
          secondary: Colors.indigoAccent,
          surface: Colors.grey[900]!,
          background: Colors.black,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
        ),
      ),
      home: HomePage(authService: _authService),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Client {
  String name;
  String event;
  String issuanceDate;

  Client(this.name, {this.event = '', this.issuanceDate = ''});
}

class HomePage extends StatefulWidget {
  final AuthService authService;
  const HomePage({super.key, required this.authService});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Client> clients = [Client('Client A'), Client('Client B')];

  void _addClient() async {
    TextEditingController controller = TextEditingController();

    String? newName = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Add Client'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Enter client name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text('Add'),
          ),
        ],
      ),
    );

    if (newName != null && newName.trim().isNotEmpty) {
      setState(() {
        clients.add(Client(newName.trim()));
      });
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

    if (result != null) {
      setState(() {
        clients[index].name = result['name'] ?? client.name;
        clients[index].event = result['event'] ?? client.event;
        clients[index].issuanceDate = result['date'] ?? client.issuanceDate;
      });
    }
  }

  void _goToGenerateCertPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GenerateCertPage(clients: clients)),
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
            colors: [Colors.grey[900]!, Colors.black],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: _goToGenerateCertPage,
                    icon: Icon(Icons.card_membership),
                    label: Text('Generate Cert'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _goToLtcPage,
                    icon: Icon(Icons.verified_user),
                    label: Text('CTC'),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: _addClient,
                    icon: Icon(Icons.add),
                    label: Text('Add Name'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _viewAll,
                    icon: Icon(Icons.list),
                    label: Text('View All'),
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
                          icon: Icon(Icons.edit, color: Colors.indigoAccent),
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

class GenerateCertPage extends StatelessWidget {
  final List<Client> clients;
  const GenerateCertPage({super.key, required this.clients});

  void _uploadFile(BuildContext context, String clientName) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null) {
      final file = result.files.first;
      String fileType = file.extension?.toLowerCase() == 'pdf' ? 'PDF' : 'Image';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                file.extension?.toLowerCase() == 'pdf'
                    ? Icons.picture_as_pdf
                    : Icons.image,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text('Uploaded $fileType for $clientName: ${file.name}'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Confirm Certificate Info'), centerTitle: true),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[900]!, Colors.black],
          ),
        ),
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: clients.length,
          itemBuilder: (context, index) {
            final client = clients[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(client.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text("Event: ${client.event}"),
                    Text("Issuance Date: ${client.issuanceDate}"),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(Icons.upload_file),
                          label: Text("Upload PDF"),
                          onPressed: () => _uploadFile(context, client.name),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: Icon(Icons.image),
                          label: Text("Upload Photo"),
                          onPressed: () => _uploadFile(context, client.name),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
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
            colors: [Colors.grey[900]!, Colors.black],
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
