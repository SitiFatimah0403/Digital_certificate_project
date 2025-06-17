import 'package:flutter/material.dart';
//to import ain punya, kena import ni

void main() => runApp(DigitalCertificateApp());

class DigitalCertificateApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CA_Verification(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CA_Verification extends StatefulWidget {
  @override
  _CAVerificationState createState() => _CAVerificationState();
}

class _CAVerificationState extends State<CA_Verification> {
  final documents = [
    {
      'name': 'Selena binti Gomez',
      'title': 'SPM Certificate',
      'date': 'Jun 1, 2025',
      'status': 'Pending',
    },
    {
      'name': 'Khairul bin Amin',
      'title': 'Diploma Transcript',
      'date': 'May 25, 2025',
      'status': 'Approved',
    },
    {
      'name': 'Ayda Binti Jebat',
      'title': 'Degree Certificate',
      'date': 'July 16, 2025',
      'status': 'Rejected',
    },
  ];

  Color getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Certification Approval Dashboard'),
        actions: [CircleAvatar(child: Text('CA')), SizedBox(width: 10)],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
                  [
                    'All',
                    'Pending',
                    'Approved',
                    'Rejected',
                  ].map((status) => Chip(label: Text(status))).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final doc = documents[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(doc['name']!),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text(doc['title']!), Text(doc['date']!)],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReviewPage(doc: doc),
                              ),
                            );
                          },
                          child: Text(
                            'REVIEW >',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: getStatusColor(doc['status']!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            doc['status']!,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }
}

class ReviewPage extends StatelessWidget {
  final Map<String, String> doc;

  ReviewPage({required this.doc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Review Certificate Document')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (doc['status'] == 'Pending')
              Container(
                padding: EdgeInsets.all(8),
                color: Colors.grey.shade300,
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Date is missing'),
                  ],
                ),
              ),
            SizedBox(height: 20),
            Text('Name: ${doc['name']}'),
            Text('Issued Organisation: Ministry of Education'),
            Text('Title: ${doc['title']}'),
            Text('Date: ${doc['date']}'),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Text('Approve'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text('Reject'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
