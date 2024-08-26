// admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sandbox_demo/services/http_service.dart';

class AdminTable extends StatefulWidget {
  @override
  State<AdminTable> createState() => _AdminTableState();
}

class _AdminTableState extends State<AdminTable> {
  List<Map<String, dynamic>> _pendingRequests = [];
  List<Map<String, dynamic>> _approvedRequests = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    try {
      final pendingResponse = await HttpService().getAdminDashboard();
      // final approvedResponse = await HttpService().getApprovedRequests();

      setState(() {
        _pendingRequests = List<Map<String, dynamic>>.from(
          (pendingResponse['pending_requests'] as List<dynamic>).map((item) => item as Map<String, dynamic>),
        );
        // _approvedRequests = List<Map<String, dynamic>>.from(
        //   (approvedResponse['approved_requests'] as List<dynamic>).map((item) => item as Map<String, dynamic>),
        // );
        _isLoading = false;
      });
    } catch (error) {
      print('Error fetching requests: $error');
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString).toLocal(); // Convert to local time
      final formatter = DateFormat('dd MMM yyyy HH:mm:ss'); // Format date as needed
      return formatter.format(date);
    } catch (e) {
      print('Error formatting date: $e');
      return dateString; // Return original string if formatting fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Requests'),
        automaticallyImplyLeading: false, // This hides the back button
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTable(
                        title: 'Pending Requests',
                        data: _pendingRequests,
                        columns: const [
                          DataColumn(label: Text('Sr No')),
                          DataColumn(label: Text('Model Name')),
                          DataColumn(label: Text('User')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Requested At')),
                          DataColumn(label: Text('')),
                        ],
                        rowBuilder: (index, item) {
                          return DataRow(
                            cells: [
                              DataCell(Text((index + 1).toString())),
                              DataCell(Text(item['model_name'] ?? '')),
                              DataCell(Text(item['user_name'] ?? '')),
                              DataCell(Text(item['status'].toString().toUpperCase())),
                              DataCell(Text(_formatDate(item['requested_at'] ?? ''))),
                              DataCell(
                                item['status'].toString().toLowerCase() == "pending"
                                    ? ElevatedButton(
                                        onPressed: () {
                                          // Define the action here
                                          _showActionDialog(context, item);
                                        },
                                        child: Text('Action'),
                                      )
                                    : SizedBox(),
                              ),
                            ],
                          );
                        },
                      ),
                      // SizedBox(height: 16.0), // Space between tables
                      // _buildTable(
                      //   title: 'Approved Requests',
                      //   data: _approvedRequests,
                      //   columns: const [
                      //     DataColumn(label: Text('Sr No')),
                      //     DataColumn(label: Text('Name')),
                      //     DataColumn(label: Text('Description')),
                      //     DataColumn(label: Text('Created At')),
                      //   ],
                      //   rowBuilder: (index, item) {
                      //     return DataRow(
                      //       cells: [
                      //         DataCell(Text((index + 1).toString())),
                      //         DataCell(Text(item['name'] ?? '')),
                      //         DataCell(Text(item['description'] ?? '')),
                      //         DataCell(Text(_formatDate(item['created_at'] ?? ''))),
                      //       ],
                      //     );
                      //   },
                      // ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildTable({
    required String title,
    required List<Map<String, dynamic>> data,
    required List<DataColumn> columns,
    required DataRow Function(int index, Map<String, dynamic> item) rowBuilder,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.blueGrey[100],
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: columns,
                rows: List<DataRow>.generate(
                  data.length,
                  (index) => rowBuilder(index, data[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActionDialog(BuildContext context, Map<String, dynamic> item) {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Action for ${item['model_name']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Max No. of access'),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter access number',
                  border: OutlineInputBorder(),
                ),
                maxLength: 4, // Restrict input to 4 digits
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                final String inputText = _controller.text;
                final int? value = int.tryParse(inputText);
                final int? maxAccesses = int.tryParse(inputText);

                // Validation
                if (inputText.isEmpty || value == null || value < 0 || value > 9999) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a valid integer between 0 and 9999.')),
                  );
                } else {
                  await _grantAccessToModel(context, item['user_id'], item['model_id'], maxAccesses ?? 0);
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
              child: Text('Submit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void showSnackbar(BuildContext context, String message, {bool isError = false}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      duration: Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _grantAccessToModel(BuildContext context, String userId, String modelId, int maxAccesses) async {
    try {
      final HttpService httpService = HttpService();
      final response = await httpService.grantAccessToModel(userId, modelId, maxAccesses);

      // Handle success based on API response
      if (response['msg'] == 'Access granted successfully') {
        showSnackbar(context, "Access granted successfully!", isError: false);
      } else {
        showSnackbar(context, "Unexpected response from the server", isError: true);
      }
    } catch (e) {
      // Handle error
      showSnackbar(context, "'Failed to grant access:", isError: true);
    }
  }
}
