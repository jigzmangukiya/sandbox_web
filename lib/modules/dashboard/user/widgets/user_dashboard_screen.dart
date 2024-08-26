import 'package:flutter/material.dart';
import 'package:sandbox_demo/services/http_service.dart';

class UserDashboard extends StatefulWidget {
  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _models = [];

  @override
  void initState() {
    super.initState();
    _fetchModels();
  }

  Future<void> _fetchModels() async {
    final httpService = HttpService();
    try {
      final response = await httpService.get('/models');
      setState(() {
        _models = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void onAccessRequestButtonPressed(String modelId) async {
    setState(() {
      _isLoading = true; // Show loader
    });

    try {
      final response = await HttpService().requestModelAccess(modelId);
      showSnackbar(context, response['msg']);
    } catch (e) {
      String errorMessage;
      if (e is FetchDataException) {
        errorMessage = 'An error occurred: ${e.message}';
      } else {
        errorMessage = 'An unexpected error occurred';
      }
      showSnackbar(context, errorMessage, isError: true);
    } finally {
      setState(() {
        _isLoading = false; // Hide loader
      });
    }
  }

  void showSnackbar(BuildContext context, String message, {bool isError = false}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      duration: Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth * 0.9;
    double cardHeight = 220 * 2 / 3;

    if (screenWidth > 1400) {
      cardWidth = screenWidth / 6 - 32;
    } else if (screenWidth > 800) {
      cardWidth = screenWidth / 4 - 32;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('User Dashboard'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                )
              : _buildModelsGrid(cardWidth, cardHeight),
    );
  }

  Widget _buildModelsGrid(double cardWidth, double cardHeight) {
    return GridView.builder(
      padding: EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 1400
            ? 6
            : MediaQuery.of(context).size.width > 800
                ? 4
                : 1,
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
        childAspectRatio: cardWidth / cardHeight,
      ),
      itemCount: _models.length,
      itemBuilder: (context, index) {
        final model = _models[index];

        final modelName = model['name'] ?? 'Unknown Model';
        final modelDescription = model['description'] ?? 'No description available';
        final modelId = model['model_id'] ?? "";
        return Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  modelName,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width < 800 ? 16.0 : 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: SingleChildScrollView(
                          child: Text(
                            modelDescription,
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width < 800 ? 14.0 : 16.0,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.0), // Adjust space before button
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: () => onAccessRequestButtonPressed(modelId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      minimumSize: Size(100, 36),
                    ),
                    child: Text('Access'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
