import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:giftcon_renewal/widgets/share_code_widget.dart';
import 'package:http/http.dart' as http;

class ShareCodeScreen extends StatefulWidget {
  const ShareCodeScreen({
    super.key,
    required this.id,
  });
  final String id;

  @override
  State<ShareCodeScreen> createState() => _ShareCodeScreenState();
}

class _ShareCodeScreenState extends State<ShareCodeScreen> {
  Future<Map<String, dynamic>?>? _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = fetchData(); // 한 번만 실행
  }

  Future<Map<String, dynamic>?> fetchData() async {
    var baseUrl = dotenv.env['BASE_URL'];
    var url = '$baseUrl/search/${widget.id}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        return jsonResponse;
      }
    } catch (e) {
      print('API 호출 실패');
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('공유하기'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 24),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: FutureBuilder<Map<String, dynamic>?>(
            future: _futureData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("에러 발생: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data == null) {
                return Center(child: Text("데이터가 없습니다."));
              }
              var data = snapshot.data!;
              return Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: ShareCodeWidget(
                  expiryDate: data["expiryDate"],
                  receiver: data["receiver"],
                  message: data["message"],
                  productName: data["productName"],
                  giftImageUrl:
                      'http://3.15.229.232:8080${data["giftImagePath"]}',
                  productImageUrl:
                      'http://3.15.229.232:8080${data["productImagePath"]}',
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
