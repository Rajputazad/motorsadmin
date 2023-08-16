import 'dart:convert';
// import 'dart:math';
import 'package:intl/intl.dart';
import 'package:motorsadmin/app/update.dart';
import 'package:motorsadmin/auth/token.dart';
import 'package:motorsadmin/tools/dailog2.dart';
import 'package:motorsadmin/tools/menu.dart';
import 'package:motorsadmin/tools/toaster.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:motorsadmin/app/car.dart';
import 'package:connectivity/connectivity.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final TextEditingController _search = TextEditingController();
  bool loding = true;
  final logger = Logger();
  late List<Map<String, dynamic>> cardata = [];
  final apiurl = dotenv.get('API_URL');
  final getcar = dotenv.get('API_URL_GET');
  final getsearch = dotenv.get('API_URL_SEARCH');
  final cerdelete = dotenv.get('API_URL_DELETE');
  final color = const Color.fromARGB(255, 0, 102, 185);
  @override
  void initState() {
    getcars();
    dely();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<bool> checkInternetConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  String formatAmountInRupees(double amount) {
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    return formatCurrency.format(amount);
  }

  bool showContainer = true;

  void dely() {
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        showContainer = false;
      });
    });
  }

  late bool add = true;
  late bool content = false;
  // late bool nodata = false;

  final ScrollController _scrollController = ScrollController();
  void _scrollListener() async {
    content = true;
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (add == true) {
        page++;
      }
      // logger.d(page);
      setState(() {
        // height = 130;
      });
      await getcars();

      setState(() {
        content = false;
        // height = 80;
      });
    }
  }

  int page = 1;
  Future getcars() async {
    bool isConnected = await checkInternetConnectivity();

    if (isConnected) {
      try {
        var pag = page.toString();
        var url = Uri.parse(apiurl + getcar + pag);

        // logger.d(url);
        var result = await http.get(url);
        if (result.statusCode == 200) {
          var data = jsonDecode(result.body);

          setState(() {
            loding = false;
            var jsonData = data["data"];

            cardata = cardata + jsonData.cast<Map<String, dynamic>>();
            // cardata = cardata.reversed.toList();
            if (cardata.isEmpty && page == 1) {
              nodata = true;
            } else {
              nodata = false;
            }
            if (data["data"].length == 0) {
              setState(() {
                add = false;
                // nodata = true;
              });
            } else {
              setState(() {
                add = true;
              });

              // logger.d(data["data"].length == 0);
            }
          });
        }
      } on Exception catch (e) {
        setState(() {
          loding = true;
        });
        // ignore: use_build_context_synchronously
        showToast(context, Colors.red, e.toString());

        logger.d(e);
      }
    } else {
      // ignore: use_build_context_synchronously
      showToast(
          context, Colors.red, "Check your internet connection and try again");
    }
    // logger.d(apiurl);
    // print(apiurl);
  }

  bool nodata = false;
  search() async {
    //  loding = false;
    content = false;
    logger.d(_search.text);
    try {
      var uri = Uri.parse(apiurl + getsearch + _search.text);
      var res = await http.get(uri);
      logger.d(uri);

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        var jsonData = data["data"];
        setState(() {
          cardata = jsonData.cast<Map<String, dynamic>>();
          if (cardata.isEmpty) {
            nodata = true;
          } else {
            nodata = false;
          }
          logger.d(cardata);
        });
      } else {
        logger.d(res.body);
        // cardata = [];
        // page = 1;
        _refreshIndicatorKey.currentState?.show();
      }
    } on Exception catch (e) {
      logger.d(e);
      // cardata = [];
      // page = 1;
      _refreshIndicatorKey.currentState?.show();
    }
  }

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  void showOptions(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  // Handle edit action
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              Update(id: id))); // Close the dialog
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () async {
                  // Handle delete action
                  var title = "Delete?";
                  var message = "Do you want to delete this data?";
                  bool? res = await dialog2(context, title, message);
                  if (res == true) {
                    logger.d(res);
                    var url = Uri.parse(apiurl + cerdelete + id);
                    String? token = await TokenManager.getToken() as String;
                    var headers = {
                      'Content-Type': 'application/json',
                      'authorization': token
                    };
                    var resp = await http.delete(
                      url,
                      headers: headers,
                    );
                    final Map<String, dynamic> responseData =
                        jsonDecode(resp.body);
                    if (resp.statusCode == 200) {
                      _refreshIndicatorKey.currentState?.show();
                      // ignore: use_build_context_synchronously
                      showToast(context, Colors.green, responseData["message"]);
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context); // Close the dialog
                    } else {
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context); // Close the dialog
                      // ignore: use_build_context_synchronously
                      showToast(context, Colors.red, responseData["message"]);
                      logger.d(resp.body);
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Close'),
                onTap: () {
                  // Close the dialog without any action
                  Navigator.pop(context); // Close the dialog
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // final listViewHeight = screenHeight - 80;
    return Scaffold(
      drawer: Drawer(
        child: MainDrawer(
            isDashboardScreen: true, isCarScreen: false, isInfoScreen: false),
      ),
      appBar: AppBar(
        backgroundColor: color, // Replace with your desired app bar color
        // title: const Text('My App'),
        elevation: 0.1,
        actions: [
          Expanded(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Builder(builder: (context) {
                    return IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    );
                  }),
                  // child: Text(
                  //   "Uday Motors",
                  //   style: TextStyle(fontSize: 20, color: color),
                  // ),
                ),
                // Spacer(),
                Container(
                  constraints: const BoxConstraints(maxWidth: 200.0),
                  height: 35,
                  child: TextField(
                    controller: _search,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: color),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 231, 229, 229),
                      prefixIcon: Icon(
                        Icons.search,
                        color: color,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) {
                      search();
                      // Handle search query submitted
                    },
                    onChanged: (String value) {
                      search();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      body: loding
          ? Center(
              child: LoadingAnimationWidget.inkDrop(
                color: color,
                size: 35,
              ),
            )
          : Material(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                // child: Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stack(children: [

                    // ]),
                    Stack(children: [
                      SizedBox(
                        height: screenHeight - 80,
                        child: RefreshIndicator(
                          key: _refreshIndicatorKey,
                          color: Colors.white,
                          backgroundColor: Colors.blue,
                          strokeWidth: 4.0,
                          onRefresh: () async {
                            // Replace this delay with the code to be executed during refresh
                            // and return a Future when code finishes execution.
                            setState(() {
                              nodata = false;
                              cardata = [];
                              page = 1;
                            });
                            await getcars();
                            // return Future<void>.delayed(const Duration(seconds: 3));
                          },
                          child: nodata
                              ? const Center(
                                  child: Text(
                                  "No data found",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ))
                              : ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  controller: _scrollController,
                                  itemCount: cardata.length + 1,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    if (index == cardata.length) {
                                      return content
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10, bottom: 10),
                                              child: Center(
                                                child: LoadingAnimationWidget
                                                    .staggeredDotsWave(
                                                  color: color,
                                                  size: 35,
                                                ),
                                              ),
                                            )
                                          : null;
                                    }
                                    final car = cardata[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10.0, left: 10, right: 10),
                                      child: Card(
                                        elevation:
                                            2, // Set the elevation for the card
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10), // Set the border radius for the card
                                        ),
                                        child: InkWell(
                                          onLongPress: () =>
                                              showOptions(context, car["_id"]),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Cardetails(
                                                          id: car["_id"])),
                                            );
                                          },
                                          child: SizedBox(
                                            // color: Colors.amber,
                                            width: 410,
                                            height: 100,
                                            // child: Expanded(
                                            child: Row(
                                              children: [
                                                showContainer
                                                    ? SizedBox(
                                                        width: 141,
                                                        height: 100,
                                                        child:
                                                            Shimmer.fromColors(
                                                          baseColor:
                                                              Colors.grey[300]!,
                                                          highlightColor:
                                                              Colors.grey[100]!,
                                                          child: Card(
                                                            elevation: 1.0,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            child:
                                                                const SizedBox(
                                                              height: 80,
                                                              // width: 80,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : SizedBox(
                                                        height: 100,
                                                        width: 141,
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  10.0), // Set the border radius value
                                                          child: car["imagedetails"] !=
                                                                      null &&
                                                                  car["imagedetails"]
                                                                      .isNotEmpty
                                                              ? Image.network(
                                                                  car["imagedetails"]
                                                                          [0]
                                                                      ["url"],
                                                                  fit: BoxFit
                                                                      .cover,
                                                                )
                                                              : Image.asset(
                                                                  'assets/images/1.jpeg'), // Replace with your image asset path
                                                        ),
                                                      ),
                                                // child: Image(image: AssetImage("assets/images/1.jpeg")),

                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10),
                                                  child: SizedBox(
                                                    height: 80,
                                                    width: 170,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 4.0),
                                                          child: SizedBox(
                                                            height: 32,
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Text(
                                                                car["carname"],
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                maxLines: 2,
                                                                style: TextStyle(
                                                                    color:
                                                                        color,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                                // textAlign: TextAlign.center,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 4.0),
                                                          child: Text(
                                                            // '${car['kilometers']} + ${car['fuel']} + ${car['transmission']}',
                                                            car["numberplate"],
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 2,
                                                            style: TextStyle(
                                                                color: color,
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 4.0),
                                                          child: Text(
                                                              formatAmountInRupees(
                                                                  double.parse(car[
                                                                      'price'])),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      // ),
                                    );
                                  }),
                        ),
                      ),
                      Positioned(
                        bottom: 16.0,
                        right: 16.0,
                        child: FloatingActionButton(
                          onPressed: () {
                            // getcar();
                            _refreshIndicatorKey.currentState?.show();
                          },
                          child: const Icon(Icons.refresh),
                        ),
                      ),
                    ]),

                    // child: Visibility(
                    //   visible: true,

                    // ),

                    // )
                  ],
                ),
              ),
            ),
      // ),
    );
  }
}
