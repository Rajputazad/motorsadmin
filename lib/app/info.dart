// import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:motorsadmin/auth/token.dart';
import 'package:motorsadmin/tools/toaster.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:logger/logger.dart';
import 'package:motorsadmin/tools/menu.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';


class Info extends StatefulWidget {
  const Info({super.key});
  @override
  State<Info> createState() => _Info();
}

class _Info extends State<Info> {
  // final _formKey = GlobalKey<FormState>();
  final _fbKey = GlobalKey<FormState>();
  List<Asset> _selectedImages = [];
  final TextEditingController carname = TextEditingController();
  final TextEditingController model = TextEditingController();
  final TextEditingController kilometers = TextEditingController();
  final TextEditingController service = TextEditingController();
  final TextEditingController registration = TextEditingController();
  final TextEditingController owner = TextEditingController();
  final TextEditingController fuel = TextEditingController();
  final TextEditingController transmission = TextEditingController();
  final TextEditingController insurance = TextEditingController();
  final TextEditingController numberplate = TextEditingController();
  final TextEditingController price = TextEditingController();
  final TextEditingController description = TextEditingController();

  final logger = Logger();
  late bool loding = false;
  late bool _isSubmitting = false;
  late String length = "0";
  @override
  void initState() {
    super.initState();
    // setState(() {
    //   length = _selectedImages.length as String;
    // });
    // _initializeCamera();
    // _checkValidityAndNavigate();
  }

  // Future<void> _checkValidityAndNavigate() async {
  //   setState(() {
  //     loding = false;
  //   });
  // }

  // Future<void> _selectImageSource() async {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Select Image Source'),
  //         content: SingleChildScrollView(
  //           child: ListBody(
  //             children: <Widget>[
  //               GestureDetector(
  //                 child: const Text('Take a Photo'),
  //                 onTap: () {
  //                   Navigator.of(context).pop();
  //                   // _takePhotos();
  //                 },
  //               ),
  //               const SizedBox(height: 16),
  //               GestureDetector(
  //                 child: const Text('Choose from Gallery'),
  //                 onTap: () {
  //                   Navigator.of(context).pop();
  //                   _selectImages();
  //                 },
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  void _selectImages() async {
    _selectedImages = [];
    List<Asset> resultList = [];
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 20, // Set the maximum number of images the user can select
        enableCamera: true,
      );
    } on Exception catch (e) {
      // Handle the exception if any
      logger.d('Error selecting images: $e');
    }

    if (!mounted) return;

    setState(() {
      logger.d(resultList.length);
      _selectedImages = resultList;
      length = (resultList.length).toString();
    });
  }

  bool _isFormValid() {
    // Validate the form using the _formKey
    // logger.d(_fbKey.currentState);
    return _fbKey.currentState?.validate() ?? false;
  }

  void _submitForm() async {
    const apiUrl = 'https://motors-c9hk.onrender.com/upload';
    // logger.d(_selectedImages.isEmpty);
    try {
      if (_selectedImages.isNotEmpty) {
        setState(() {
          _isSubmitting = true;
        });
        var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

        // Add car details to the request
        String? token = await TokenManager.getToken() as String;
        logger.d(token);
        request.headers['authorization'] = token;
        request.headers['Content-Type'] = 'application/json';

        for (var i = 0; i < _selectedImages.length; i++) {
          var asset = _selectedImages[i];
          ByteData byteData = await asset.getByteData();
          List<int> imageData = byteData.buffer.asUint8List();

          var multipartFile = http.MultipartFile.fromBytes(
            'images',
            imageData,
            filename: 'image$i.jpg',
          );
          request.files.add(multipartFile);
        }
        request.fields['carname'] = carname.text;
        request.fields['model'] = model.text;
        request.fields['kilometers'] = kilometers.text;
        request.fields['service'] = service.text;
        request.fields['registration'] = registration.text;
        request.fields['fuel'] = fuel.text;
        request.fields['transmission'] = transmission.text;
        request.fields['insurance'] = insurance.text;
        request.fields['price'] = price.text;
        request.fields['description'] = description.text;
        request.fields['numberplate'] = numberplate.text;
        request.fields['owner'] = owner.text;

        // Add the image file to the request

        var response = await request.send();
        // logger.d(response.toString());

        // response.stream.transform(utf8.decoder).listen((value) {
        //   logger.d('value');
        //   logger.d(value);
        // });
        logger.d('Error: ${response.statusCode}');
        if (response.statusCode == 200) {
          _fbKey.currentState?.reset;
          carname.clear();
          model.clear();
          kilometers.clear();
          service.clear();
          registration.clear();
          owner.clear();
          fuel.clear();
          transmission.clear();
          insurance.clear();
          numberplate.clear();
          price.clear();
          description.clear();
          _selectedImages = [];
          length = "0";
          setState(() {
            _isSubmitting = false;
          });

        // ignore: use_build_context_synchronously
        showToast(context, Colors.green, "Car details submitted successfully");
        
        } else {
          logger.d('Error: ${response.reasonPhrase}');
        }
      } else {
        showToast(context, Colors.red, "At least one image is required");
      }
    } catch (e) {
      logger.d('Error: $e');
      setState(() {
        showToast(context, Colors.red, e.toString());
        _isSubmitting = false;
      });
    }
  }
  // }

  // void _pickImage() async {
  //   final image = await ImagePicker().pickImage(source: ImageSource.gallery);

  //   setState(() {
  //     if (image != null) {
  //       _selectedImage = File(image.path);
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return loding
        ? Container(
            color: Colors.white,
            child:  Center(child:  LoadingAnimationWidget.beat( // LoadingAnimationwidget that call the
        color: Colors.blue,                          // staggereddotwave animation
        size: 35,
      ),))
        : Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 4, 12, 240),
              title: const Text("Information"),
            ),
            drawer: Drawer(
              child: MainDrawer(
                  isDashboardScreen: false,
                  isCarScreen: false,
                  isInfoScreen: true),
            ),
            body: _isSubmitting
                ? Container(
                    color: Colors.white,
                    child:  Center(child: LoadingAnimationWidget.beat( // LoadingAnimationwidget that call the
        color: Colors.blue,                          // staggereddotwave animation
        size: 35,
      )))
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _fbKey,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        // child: Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: carname,
                              decoration:
                                  const InputDecoration(labelText: 'Car Name'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the car name.';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: model,
                              decoration:
                                  const InputDecoration(labelText: 'Car Model'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the car model.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                // You can save the value if needed
                              },
                            ),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              controller: kilometers,
                              decoration: const InputDecoration(
                                  labelText: 'Kilometers'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Kilometers in numbers.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                // You can save the value if needed
                              },
                            ),
                            TextFormField(
                              controller: service,
                              decoration: const InputDecoration(
                                  labelText: 'Last service'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the Last service.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                // You can save the value if needed
                              },
                            ),
                            TextFormField(
                              controller: registration,
                              decoration: const InputDecoration(
                                  labelText: 'Registration'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the Registration.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                // You can save the value if needed
                              },
                            ),
                            TextFormField(
                              controller: owner,
                              decoration:
                                  const InputDecoration(labelText: 'Ownerl'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the owner.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                // You can save the value if needed
                              },
                            ),
                            TextFormField(
                              controller: fuel,
                              decoration:
                                  const InputDecoration(labelText: 'Fuel'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the fuel type.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                // You can save the value if needed
                              },
                            ),
                            TextFormField(
                              controller: transmission,
                              decoration: const InputDecoration(
                                  labelText: 'Transmission'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the transmission Manual/Auto.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                // You can save the value if needed
                              },
                            ),
                            TextFormField(
                              controller: insurance,
                              decoration:
                                  const InputDecoration(labelText: 'Insurance'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the insurance.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                // You can save the value if needed
                              },
                            ),
                            TextFormField(
                              controller: numberplate,
                              decoration: const InputDecoration(
                                  labelText: 'Numberplate'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the numberplate.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                // You can save the value if needed
                              },
                            ),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              controller: price,
                              decoration:
                                  const InputDecoration(labelText: 'Price'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the price in numbers.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                // You can save the value if needed
                              },
                            ),
                            TextFormField(
                              controller: description,
                              decoration: const InputDecoration(
                                  labelText: 'Description'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter any description of car.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                // You can save the value if needed
                              },
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            ElevatedButton(
                              onPressed: _selectImages,
                              child: const Text('Pick Car Image'),
                            ),
                            SizedBox(child: Text("$length images selected")),
//     CustomCameraPreview(
//      imageFiles: _homeController.imageFiles,
//      cameraController: controller!,
// );
                            // if (_selectedImage != null)
                            // Expanded(
                            // child:   ListView.builder(
                            //     itemCount: _selectedImages.length,
                            //     itemBuilder: (context, index) {
                            //       return AssetThumb(
                            //         asset: _selectedImages[index],
                            //         width: 100,
                            //         height: 100,
                            //       );
                            //     },
                            //   ),
                            // ),
                            const SizedBox(
                              height: 16,
                            ),
                            ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.green)),
                              // onPressed: _submitForm,
                              onPressed: () {
                                !_isFormValid() ? null : _submitForm();
                              },
                              child: const Text('Submit'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            // ),
          );
  }
}
