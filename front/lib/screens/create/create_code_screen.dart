import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:giftcon_renewal/screens/share/share_code_screen.dart';
import 'package:giftcon_renewal/widgets/share_code_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

class CreateCodeScreen extends StatefulWidget {
  const CreateCodeScreen({super.key});

  @override
  State<CreateCodeScreen> createState() => _CreateCodeScreenState();
}

class _CreateCodeScreenState extends State<CreateCodeScreen> {
  String codeType = 'QR';
  File? _giftImage;
  File? _productImage;
  final TextEditingController _receiverController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  Future<void> _pickImage(String type) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (type == 'product') {
          _productImage = File(pickedFile.path);
        } else {
          _giftImage = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> uploadData(BuildContext context) async {
    if (_receiverController.text.isEmpty) {
      _showAlertMessage(context, '받는사람을 입력해주세요.');
    } else if (_productNameController.text.isEmpty) {
      _showAlertMessage(context, '상품명을 입력해주세요.');
    } else if (_messageController.text.isEmpty) {
      _showAlertMessage(context, '메시지를 입력해주세요.');
    } else if (_expiryDateController.text.isEmpty) {
      _showAlertMessage(context, '유효기간을 선택해주세요.');
    } else if (_giftImage == null) {
      _showAlertMessage(context, '기프티콘 이미지를 등록해주세요.');
    } else if (_productImage == null) {
      _showAlertMessage(context, '싱품 이미지를 등록해주세요.');
    } else {
      final baseUrl = dotenv.env['BASE_URL'];
      var dio = new Dio();

      try {
        MultipartFile productImageFile = await MultipartFile.fromFile(
          _productImage!.path,
          filename: _productImage!.path.split('/').last,
          contentType: MediaType.parse(lookupMimeType(_productImage!.path) ??
              'application/octet-stream'),
        );

        MultipartFile giftImageFile = await MultipartFile.fromFile(
          _giftImage!.path,
          filename: _giftImage!.path.split('/').last,
          contentType: MediaType.parse(
              lookupMimeType(_giftImage!.path) ?? 'application/octet-stream'),
        );

        var formData = FormData.fromMap({
          "receiver": _receiverController.text,
          "productName": _productNameController.text,
          "expiryDate": _expiryDateController.text,
          "message": _messageController.text,
          "productImage": productImageFile,
          "giftImage": giftImageFile,
        });

        Response response = await dio.post(
          '$baseUrl/upload',
          data: formData,
          options: Options(
            contentType: "multipart/form-data",
          ),
        );

        // 응답 확인
        if (response.statusCode == 200 &&
            response.data is Map<String, dynamic>) {
          String? id = response.data['id'];

          if (id != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShareCodeScreen(
                  id: id,
                ),
              ),
            );
          } else {
            print('⚠️ 업로드 성공했지만 ID 값이 없습니다.');
          }
        } else {
          print('❌ 업로드 실패: ${response.statusCode}');
        }
      } catch (e) {
        print(e);
      }
    }
  }

  void _showFullscreenBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 1.0,
          minChildSize: 0.5,
          maxChildSize: 1.0,
          builder: (BuildContext context, scrollController) {
            return Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
              ),
              color: Colors.white,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: scrollController,
                    child: ShareCodeWidget(
                      expiryDate: _expiryDateController.text,
                      receiver: _receiverController.text,
                      message: _messageController.text,
                      productName: _productNameController.text,
                      isPreview: true,
                      productPreviewImage: _productImage,
                      giftPreviewImage: _giftImage,
                    ),
                  ),
                  Positioned(
                    top: 16.0,
                    right: 16.0,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.close,
                        size: 24.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = (MediaQuery.of(context).size.width - 50) / 2;

    return Scaffold(
      appBar: AppBar(
        title: Text('기프티콘 생성'),
        titleTextStyle: TextStyle(
          fontSize: 17,
          color: Colors.black,
        ),
        backgroundColor: const Color.fromARGB(255, 166, 215, 255),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white, // 이 부분을 decoration 안으로 이동
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1), // 그림자 색상
              blurRadius: 15, // 흐림 정도
              spreadRadius: 2, // 그림자 퍼짐 정도
              offset: Offset(0, -2), // 위 방향 그림자
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () => {_showFullscreenBottomSheet(context)},
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: Size(width, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  // side: BorderSide(color: Colors.black),
                ),
              ),
              child: Text("미리보기"),
            ),
            SizedBox(width: 10),
            TextButton(
              onPressed: () => {uploadData(context)},
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: Size(width, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  // side: BorderSide(color: Colors.black),
                ),
              ),
              child: Text("생성하기"),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputField("받는사람", '받는 사람을 입력해주세요. (최대 10글자)',
                      _receiverController, 10, 1),
                  SizedBox(height: 20),
                  _buildInputField("상품명", '받는 사람을 입력해주세요. (최대 30글자)',
                      _productNameController, 30, 1),
                  SizedBox(height: 20),
                  _buildInputField(
                    "메시지",
                    '받는 사람을 입력해주세요. (최대 200글자)',
                    _messageController,
                    200,
                    4,
                  ),
                  SizedBox(height: 20),
                  _buildDatePickerField(
                    context,
                    "유효기간",
                    '유효기간을 선택해 주세요.',
                    _expiryDateController,
                  ),
                  SizedBox(height: 20),
                  _buildLabelText('이미지 등록'),
                  Row(
                    children: [
                      _buildSquareContainer(
                        '기프티콘 이미지',
                        _giftImage,
                        width,
                        'gift',
                      ),
                      SizedBox(width: 10),
                      _buildSquareContainer(
                        '상품 이미지',
                        _productImage,
                        width,
                        'product',
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabelText(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Color.fromARGB(255, 97, 94, 94),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '*',
              style: TextStyle(
                fontSize: 13,
                color: Colors.deepOrange,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
        SizedBox(height: 4),
      ],
    );
  }

  Widget _buildInputField(
    String label,
    String hintText,
    TextEditingController controller,
    int maxLength,
    int maxLine,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabelText(label),
        TextField(
          maxLength: maxLength,
          controller: controller,
          maxLines: maxLine,
          style: TextStyle(
            fontSize: 16,
          ),
          decoration: InputDecoration(
            counterText: '',
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: const Color.fromARGB(255, 205, 205, 205),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: const Color.fromARGB(255, 78, 168, 241),
              ),
            ),
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Future<dynamic> _showAlertMessage(BuildContext context, String text) {
    return showDialog(
      context: context,
      barrierDismissible: true, //바깥 영역 터치시 닫을지 여부 결정
      builder: ((context) {
        return AlertDialog(
          // title: Text("제목"),
          content: Text(text),
          actions: <Widget>[
            Container(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); //창 닫기
                },
                child: Text("네"),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSquareContainer(
    String name,
    File? image,
    double size,
    String type,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _pickImage(type),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8), // border-radius 8px 적용
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.fromARGB(255, 205, 205, 205),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: image != null
                      ? Image.file(image, fit: BoxFit.cover)
                      : Center(
                          child: TextButton(
                            onPressed: () {
                              _pickImage(type);
                            },
                            child: Text(
                              name,
                              style: TextStyle(
                                color: const Color.fromARGB(255, 97, 94, 94),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              if (image != null)
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      _pickImage(type);
                    },
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.sync,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerField(
    BuildContext context,
    String label,
    String hintText,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabelText(label),
        TextField(
          controller: controller,
          readOnly: true,
          style: TextStyle(
            fontSize: 16,
          ),
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: const Color.fromARGB(255, 205, 205, 205),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: const Color.fromARGB(255, 78, 168, 241), // 원하는 색상으로 변경
              ),
            ),
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon: Icon(
              Icons.calendar_month_outlined,
              color: Color.fromARGB(255, 174, 172, 172),
              size: 22,
            ),
          ),
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 365 * 2)),
              locale: Locale('ko', 'KR'),
            );
            if (pickedDate != null) {
              String formattedDate =
                  DateFormat('yyyy-MM-dd').format(pickedDate);
              setState(() {
                controller.text = formattedDate;
              });
            }
          },
        )
      ],
    );
  }
  //
}
