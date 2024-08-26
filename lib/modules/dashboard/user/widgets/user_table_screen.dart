import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting
import 'package:sandbox_demo/services/http_service.dart';

class UserTableScreen extends StatefulWidget {
  @override
  State<UserTableScreen> createState() => _UserTableScreenState();
}

class _UserTableScreenState extends State<UserTableScreen> {
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
      final pendingResponse = await HttpService().getPendingRequests();
      final approvedResponse = await HttpService().getApprovedRequests();

      setState(() {
        _pendingRequests = List<Map<String, dynamic>>.from(
          (pendingResponse['pending_requests'] as List<dynamic>).map((item) => item as Map<String, dynamic>),
        );
        _approvedRequests = List<Map<String, dynamic>>.from(
          (approvedResponse['approved_requests'] as List<dynamic>).map((item) => item as Map<String, dynamic>),
        );
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
                          DataColumn(label: Text('Requested At')),
                        ],
                        rowBuilder: (index, item) {
                          return DataRow(
                            cells: [
                              DataCell(Text((index + 1).toString())),
                              DataCell(Text(item['model_name'] ?? '')),
                              DataCell(Text(_formatDate(item['requested_at'] ?? ''))),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 16.0), // Space between tables
                      _buildTable(
                        title: 'Approved Requests',
                        data: _approvedRequests,
                        columns: const [
                          DataColumn(label: Text('Sr No')),
                          DataColumn(label: Text('Model Name')),
                          DataColumn(label: Text('Max Access')),
                          DataColumn(label: Text('Access Count')),
                          DataColumn(label: Text('Granted At')),
                        ],
                        rowBuilder: (index, item) {
                          return DataRow(
                            cells: [
                              DataCell(Text((index + 1).toString())),
                              DataCell(Text(item['model_name'] ?? '')),
                              DataCell(Text(item['max_accesses'].toString())),
                              DataCell(Text(item['access_count'].toString())),
                              DataCell(Text(_formatDate(item['granted_at'] ?? ''))),
                            ],
                          );
                        },
                      ),
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
}
