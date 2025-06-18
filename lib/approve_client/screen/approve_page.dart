import 'package:flutter/material.dart';
import 'status_page.dart';


class CertificatePage extends StatelessWidget {
  final String recipientName;
  final String courseName;
  final String date;

  const CertificatePage({
    Key? key,
    required this.recipientName,
    required this.courseName,
    required this.date,
  }) : super(key: key);

  void _onApprove(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => StatusPage(status: "Approved"),
    ),
  );
}

void _onReject(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => StatusPage(status: "Rejected"),
    ),
  );
}

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Certificate container
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 3),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/upm.png',
                      height: 160, // adjust as needed
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Text('Image failed to load');
                      },
                    ),

                    SizedBox(height: 50),
                    Text(
                      'This is to certify that',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 20),
                    Text(
                      recipientName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 50),
                    Text(
                      'has successfully completed the',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 20),
                    Text(
                      courseName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 50),
                    Text('Dated: $date', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 100,
                              height: 1,
                              color: Colors.black,
                            ),
                            SizedBox(height: 5),
                            Text('Signature'),
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              width: 100,
                              height: 1,
                              color: Colors.black,
                            ),
                            SizedBox(height: 5),
                            Text('Seal/Stamp'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Buttons outside the certificate
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _onApprove(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    icon: Icon(Icons.check),
                    label: Text("Approve"),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: () => _onReject(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    icon: Icon(Icons.close),
                    label: Text("Reject"),
                  ),
                ],
              ),
              SizedBox(height: 1),
            ],
          ),
        ),
      ),
    );
  }
}
