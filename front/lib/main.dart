import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:giftcon_renewal/screens/create/create_code_screen.dart';

// flutter build ios --verbose

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/config/.env');
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = 0;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      locale: Locale('ko'),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ko'),
      ],
      home: CreateCodeScreen(),
    );
  }
}


/*
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter API Demo',
      home: Scaffold(
        appBar: AppBar(title: Text('API 호출 예시')),
        body: Center(child: ApiRequestButton()),
      ),
    );
  }
}

class ApiRequestButton extends StatelessWidget {
  // API 호출 함수
  Future<void> fetchData() async {
    final baseUrl = dotenv.env['BASE_URL']; // .env에서 BASE_URL 값 가져오기
    final url =
        '$baseUrl/search/b605fd88-ebec-4e0d-a48d-7d187a6c616a'; // /search API 엔드포인트 추가
    final response = await http.get(Uri.parse(url)); // HTTP GET 요청

    if (response.statusCode == 200) {
      print('API 응답: ${response.body}');
    } else {
      print('API 호출 실패');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: fetchData,
      child: Text('API 호출'),
    );
  }
}
*/