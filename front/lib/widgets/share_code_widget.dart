import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_image_gallery_saver/flutter_image_gallery_saver.dart';

class ShareCodeWidget extends StatefulWidget {
  const ShareCodeWidget({
    super.key,
    required this.expiryDate,
    required this.receiver,
    required this.message,
    required this.productName,
    this.giftImageUrl,
    this.giftPreviewImage,
    this.productImageUrl,
    this.productPreviewImage,
    this.isPreview = false,
  });

  final String expiryDate;
  final String receiver;
  final String message;
  final String productName;
  final String? giftImageUrl;
  final File? giftPreviewImage;
  final String? productImageUrl;
  final File? productPreviewImage;
  final bool? isPreview;

  @override
  State<ShareCodeWidget> createState() => _ShareCodeWidgetState();
}

class _ShareCodeWidgetState extends State<ShareCodeWidget> {
  GlobalKey _globalKey = GlobalKey();

  Future<Uint8List?> _captureWidget() async {
    try {
      RenderRepaintBoundary? boundary = _globalKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print("캡처 오류: $e");
      return null;
    }
  }

  // 이미지 저장 기능
  Future<void> _saveImage() async {
    Uint8List? imageBytes = await _captureWidget();
    if (imageBytes == null) return;

    final directory = await getApplicationDocumentsDirectory();
    String filePath = '${directory.path}/captured_image.png';
    File file = File(filePath);
    await file.writeAsBytes(imageBytes);

    final result = await FlutterImageGallerySaver.saveFile(filePath);

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("이미지 저장 완료"),
            content: Text("이미지가 갤러리에 저장되었습니다."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("확인"),
              ),
            ],
          );
        },
      );
    }
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('이미지가 저장되었습니다.')),
    // );
  }

  // 공유 기능
  Future<void> _shareImage() async {
    Uint8List? imageBytes = await _captureWidget();
    if (imageBytes == null) return;

    final directory = await getApplicationDocumentsDirectory();
    String filePath = '${directory.path}/shared_image.png';
    File file = File(filePath);
    await file.writeAsBytes(imageBytes);

    await Share.shareXFiles([XFile(filePath)], text: "캡처한 이미지를 공유합니다!");
  }

  @override
  Widget build(BuildContext context) {
    double boxSize = 240;

    return Padding(
      padding:
          EdgeInsets.fromLTRB(20, widget.isPreview == true ? 80 : 0, 20, 20),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              RepaintBoundary(
                key: _globalKey, // Stack 전체를 캡처하도록 설정
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 30,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(top: 50),
                        padding: EdgeInsets.fromLTRB(20, 80, 20, 30),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.lightBlue.shade100,
                              Colors.lightBlue.shade600
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 40),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                widget.message.isEmpty ? '메시지' : widget.message,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.2,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Container(
                              width: boxSize,
                              height: boxSize,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Column(
                                  children: [
                                    if (widget.isPreview == true &&
                                        widget.giftPreviewImage != null)
                                      Image.file(
                                        width: boxSize,
                                        height: boxSize,
                                        widget.giftPreviewImage!,
                                        fit: BoxFit.cover,
                                      )
                                    else if (widget.giftImageUrl != null)
                                      Image.network(
                                        widget.giftImageUrl!,
                                        fit: BoxFit.cover,
                                        width: boxSize,
                                        height: boxSize,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(
                                            Icons.image_not_supported,
                                            size: 100,
                                            color: Colors.grey,
                                          );
                                        },
                                      )
                                    else
                                      SizedBox(
                                        width: boxSize,
                                        height: boxSize,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              height: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                              ),
                                            ),
                                            Icon(
                                              Icons.photo,
                                              color: Colors.grey[500],
                                              size: 40,
                                            ),
                                          ],
                                        ),
                                      )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            Container(
                              width: boxSize,
                              alignment: Alignment.centerRight,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  widget.expiryDate.isEmpty
                                      ? '유효기한: YYYY-MM-DD'
                                      : '유효기한: ${widget.expiryDate.substring(0, 10)}',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Positioned도 캡처 영역 포함
                      Positioned(
                        top: -10,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            if (widget.isPreview == true &&
                                widget.productPreviewImage != null)
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Color.fromARGB(255, 205, 205, 205),
                                    width: 2.0,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50.0),
                                  child: Image.file(
                                    widget.productPreviewImage!,
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
                                  ),
                                ),
                              )
                            else if (widget.productImageUrl != null)
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Color.fromARGB(255, 205, 205, 205),
                                    width: 2,
                                  ),
                                  image: DecorationImage(
                                    image:
                                        NetworkImage(widget.productImageUrl!),
                                    fit: BoxFit.cover,
                                    alignment: Alignment.center,
                                  ),
                                  color: Colors.grey[300],
                                ),
                              )
                            else
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Color.fromARGB(255, 205, 205, 205),
                                    width: 2,
                                  ),
                                  color: Colors.grey[300],
                                ),
                                child: Icon(
                                  Icons.photo,
                                  color: Colors.grey[500],
                                  size: 25,
                                ),
                              ),
                            SizedBox(height: 8),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.receiver.isEmpty
                                      ? '받는사람'
                                      : '${widget.receiver}님 ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    // fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  widget.productName.isEmpty
                                      ? '(상품명) 선물이 도착했어요!'
                                      : '${widget.productName} 선물이 도착했어요!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 저장 및 공유 버튼
            ],
          ),
          SizedBox(height: 20),
          if (widget.isPreview != true)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _saveImage,
                  child: Text("이미지 저장"),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _shareImage,
                  child: Text("공유하기"),
                ),
              ],
            ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
