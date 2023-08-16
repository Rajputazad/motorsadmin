import 'dart:convert';

// import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:motorsadmin/app/home.dart';
import 'package:motorsadmin/auth/token.dart';
import 'package:motorsadmin/tools/toaster.dart';
import 'package:logger/logger.dart';
import 'package:motorsadmin/tools/menu.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity/connectivity.dart';
// import 'dart:io';

// import 'package:url_launcher/url_launcher.dart';

class Update extends StatefulWidget {
  final String id;
  const Update({super.key, required this.id});
  @override
  State<Update> createState() => _Update();
}

class _Update extends State<Update> {
  // final _formKey = GlobalKey<FormState>();
  final _fbKey = GlobalKey<FormState>();
  // List<Asset> _selectedImages = [];
  late TextEditingController carname;
  late TextEditingController model;
  late TextEditingController kilometers;
  late TextEditingController service;
  late TextEditingController registration;
  late TextEditingController owner;
  late TextEditingController fuel;
  late TextEditingController transmission;
  late TextEditingController insurance;
  late TextEditingController numberplate;
  late TextEditingController price;
  late TextEditingController description;
  late String getcar = dotenv.get('API_URL_GETCAR');
  late Logger logger = Logger();
  late bool loding = true;
  late bool _isSubmitting = false;
  late String length = "0";
  int activePage = 0;
  final PageController _pageController =
      PageController(viewportFraction: 0.8, initialPage: 0);
  @override
  void initState() {
    car(widget.id);

    super.initState();
  }

  AnimatedContainer slider(images, pagePosition, active) {
    double margin = active ? 0 : 15;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
      margin: EdgeInsets.all(margin),
      decoration: BoxDecoration(
          image: DecorationImage(image: NetworkImage(images[pagePosition]))),
    );
  }

  Future<bool> checkInternetConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  dynamic cardetals;
  late List<String> images = [];
  car(id) async {
    var url = Uri.parse(apiurl + getcar + id);
    try {
      var res = await http.get(url);
      if (res.statusCode == 200) {
        setState(() {
          loding = false;
          cardetals = jsonDecode(res.body);
          cardetals = cardetals["data"];
        });

        carname = TextEditingController(text: cardetals["carname"]);
        model = TextEditingController(text: cardetals["model"]);
        kilometers = TextEditingController(text: cardetals["kilometers"]);
        service = TextEditingController(text: cardetals["service"]);
        registration = TextEditingController(text: cardetals["registration"]);
        owner = TextEditingController(text: cardetals["owner"]);
        fuel = TextEditingController(text: cardetals["fuel"]);
        transmission = TextEditingController(text: cardetals["transmission"]);
        insurance = TextEditingController(text: cardetals["insurance"]);
        numberplate = TextEditingController(text: cardetals["numberplate"]);
        description = TextEditingController(text: cardetals["description"]);
        price = TextEditingController(text: cardetals["price"]);
        logger.d(cardetals["imagedetails"].toString().runtimeType);
        var nestedArray = cardetals["imagedetails"] as List<dynamic>;
        images = nestedArray.map((item) => item['url'].toString()).toList();
        // logger.d(images);
      }
    } catch (e) {
      loding = true;

      logger.d(e);
    }
  }

  // List<String> imagePaths = [];
  // Future<void> _selectImages() async {
  //   // final PermissionStatus isPhotosPermission =
  //   if (await Permission.storage.request().isGranted ||
  //       await Permission.photos.request().isGranted) {
  //     try {
  //       final result = await FilePicker.platform.pickFiles(
  //         type: FileType.image,
  //         allowMultiple: true,
  //       );

  //       if (result != null && result.files.isNotEmpty) {
  //         List<String> paths = result.files
  //             .where((file) => file.path != null)
  //             .map((file) => file.path!)
  //             .toList();
  //         imagePaths = paths;
  //         setState(() {
  //           // logger.d(resultList.length);
  //           // _selectedImages = resultList;
  //           length = (imagePaths.length).toString();
  //         });
  //         // Send the images to the backend
  //         // await sendImagesToBackend(paths);
  //       }
  //     } catch (e) {
  //       logger.d("Error picking/sending images: $e");
  //     }
  //   } else {
  //     // ignore: use_build_context_synchronously
  //     showToast(context, Colors.red, "permission denied");
  //   }
  // }

  bool _isFormValid() {
    // Validate the form using the _formKey
    // logger.d(_fbKey.currentState);
    return _fbKey.currentState?.validate() ?? false;
  }

  final apiurl = dotenv.get('API_URL');
  final cerupdate = dotenv.get('API_URL_UPDATE');

  void _submitForm() async {
    setState(() {
      loding = true;
    });

    // logger.d(_selectedImages.isEmpty);
    try {
      var uri = Uri.parse(apiurl + cerupdate + widget.id);
      

      // Add car details to the request
      String? token = await TokenManager.getToken() as String;
      // logger.d(token);

      // for (String imagePath in imagePaths) {
      //   File imageFile = File(imagePath);
      //   request.files.add(
      //     await http.MultipartFile.fromPath('images', imageFile.path),
      //   );
      // }
      logger.d(carname.text);
      var data = {
        'carname': carname.text,
        'model': model.text,
        'kilometers': kilometers.text,
        'service': service.text,
        'registration': registration.text,
        'fuel': fuel.text,
        'transmission': transmission.text,
        'insurance': insurance.text,
        'price': price.text,
        'description': description.text,
        'numberplate': numberplate.text,
        'owner': owner.text,
      };
      var body = jsonEncode(data);
      var response = await http.put(
        uri,
        headers: {
          "authorization": token,
          "Content-Type": "application/json",
        },
        body: body,
      );
      // logger.d('Error: ${response}');

      if (response.statusCode == 200) {
        setState(() {
          Navigator.pop(context);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const Home()));
        });
        // loding = false;

        // ignore: use_build_context_synchronously
        showToast(context, Colors.green, "Car details update successfully");
      } else {
        logger.d('Error: ${response.body}');
        // ignore: use_build_context_synchronously
        showToast(context, Colors.red, response.body);
      }
    } catch (e) {
      logger.d('Error: $e');
      setState(() {
        showToast(context, Colors.red, e.toString());
        loding = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return loding
        ? Container(
            color: Colors.white,
            child: Center(
              child: LoadingAnimationWidget.beat(
                // LoadingAnimationwidget that call the
                color: Colors.blue, // staggereddotwave animation
                size: 35,
              ),
            ))
        : Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 0, 102, 185),
              title: const Text("Update car information"),
            ),
            drawer: Drawer(
              child: MainDrawer(
                  isDashboardScreen: false,
                  isCarScreen: false,
                  isInfoScreen: false),
            ),
            body: _isSubmitting
                ? Container(
                    color: Colors.white,
                    child: Center(
                        child: LoadingAnimationWidget.beat(
                      // LoadingAnimationwidget that call the
                      color: Colors.blue, // staggereddotwave animation
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
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 200,
                              child: PageView.builder(
                                  itemCount: images.length,
                                  pageSnapping: true,
                                  controller: _pageController,
                                  onPageChanged: (page) {
                                    setState(() {
                                      activePage = page;
                                    });
                                  },
                                  itemBuilder: (context, pagePosition) {
                                    bool active = pagePosition == activePage;
                                    return GestureDetector(
                                        onTap: () {
                                          // _showImageFullScreen(
                                          //   context,
                                          //   pagePosition,
                                          // );
                                        },
                                        child: slider(
                                            images, pagePosition, active));
                                  }),
                            ),
                            TextFormField(
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
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
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              decoration: const InputDecoration(
                                  labelText: 'Fuel petrol/diesel/CNG/other'),
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              decoration: const InputDecoration(
                                  labelText: 'Transmission-Manual/Auto'),
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
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
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              controller: price,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
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
                            // ElevatedButton(
                            //   onPressed: () async {
                            //     // var url = 'https://photos.app.goo.gl/ymM';
                            //     // if (await canLaunch(url)) {
                            //     _selectImages();
                            //     //   await launch(url);
                            //     // } else {
                            //     //   var playStoreUrl =
                            //     //       'https://play.google.com/store/apps/details?id=com.google.android.apps.photos';
                            //     //   await launch(playStoreUrl);
                            //     // }
                            //   },
                            //   child: const Text('Pick Car Image'),
                            // ),
                            // SizedBox(child: Text("$length images selected")),

                            const SizedBox(
                              height: 10,
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
                              child: const Text('Update'),
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
