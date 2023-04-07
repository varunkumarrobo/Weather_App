import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/data_model.dart';
import '../providers/location_provider.dart';
import '../services/database_service.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final DatabaseManager _databaseManager = DatabaseManager();
  List<Map<String, dynamic>> favs = [];
  TextEditingController searchController = TextEditingController();
  List<String> description = [];
  List<String> temp = [];
  List<String> images = [];
  List<String> place = [];
  List<String> state = [];

  @override
  fetchFavs(isFav) async {
    var weartherProvider = Provider.of<Wearther>(
      context,
      listen: false,
    );
    favs = [];
    List<DataModel>? model;
    if (isFav) {
      if (searchController.text.trim() == '') {
        model = await _databaseManager.getFav();
      } else {
        model = await _databaseManager.getFavFilterLike(
          searchController.text,
        );
      }
    } else {
      if (searchController.text.trim() == "") {
        model = await _databaseManager.getRecent();
      } else {
        model = await _databaseManager.getRecentFilterLike(
          searchController.text,
        );
      }
    }
    for (var dataModel in model) {
      await weartherProvider
          .getCityWeather(dataModel.toJson()["place"])
          .then((value) async {
        description.add(
          weartherProvider.deatils[0].description,
        );
        temp.add(
          weartherProvider.deatils[0].temp.toString(),
        );
        log(
          temp.toString(),
        );
        log(
          description.toString(),
        );
        images.add(weartherProvider.deatils[0].icon);
        log(images.toString());
      }).onError((error, stackTrace) {
        log(' ghijk ${error.toString()}');
      });
      if (!isFav) {
        model = await _databaseManager.getFav();
        for (var dataModel in model) {
          place.add(dataModel.toJson()["place"]);
          state.add(dataModel.toJson()["region"]);
        }
      }
      favs.add(dataModel.toJson());
    }
  }

  @override
  void dispose() {
    fetchFavs;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavProvider>(context, listen: false);
    final argument =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    bool isFav = argument["fav"];
    return Scaffold(
      backgroundColor: Colors.pinkAccent,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black, size: 30),
        leading: IconButton(
          onPressed: () async {
            List<DataModel>? model = await _databaseManager.getFav();
            for (var dataModel in model) {
              if (dataModel.toJson()["place"] == place &&
                  dataModel.toJson()["region"] == state) {
                favoriteProvider.icon = Icons.favorite;
                isFav = true;
                favoriteProvider.update();
                FocusScope.of(context).unfocus();
                Navigator.pop(context);
                return;
              }
            }
            favoriteProvider.icon = Icons.favorite_outline_sharp;
            isFav = false;
            favoriteProvider.update();
            FocusScope.of(context).unfocus();
            Navigator.pop(context);
            return;
          },
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
        title: CustomAppBarTitle(
          isFav: isFav,
          searchController: searchController,
        ),
        backgroundColor: Colors.white,
        actions: [
          Consumer<SearchIndexProvider>(
            builder: (BuildContext context, value, Widget? child) {
              return InkWell(
                onTap: () {
                  if (value.index == 0) {
                    value.IndexOne();
                  } else {
                    searchController.text = "";
                    value.IndexZero();
                    setState(() {});
                  }
                },
                child: Icon(
                  value.index == 0 ? Icons.search : Icons.cancel_outlined,
                  size: 30,
                ),
              );
            },
          ),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
      body: FutureBuilder<dynamic>(
          future: fetchFavs(isFav),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.connectionState == ConnectionState.done) {
              return Stack(children: [
                favs.length != 0
                    ? TopInfoBar(
                        isFavorite: isFav,
                        favsListLength: favs,
                      )
                    : TopInfoBarWithNodata(isFav: isFav),
                Positioned(
                  top: 65,
                  left: 18,
                  right: 16,
                  child: Container(
                    color: Colors.transparent,
                    height: MediaQuery.of(context).size.height - 200,
                    child: ListView.builder(
                        itemCount: favs.length,
                        itemBuilder: (BuildContext context, int index) {
                          return SizedBox(
                            height: 100,
                            child: GestureDetector(
                              onLongPress: () {
                                if (!isFav) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        content: Text(
                                          "Remove ${favs[index]["place"]} from recent search?",
                                          style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 18),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              "NO",
                                              style: TextStyle(
                                                  color: Colors.deepPurple),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              _databaseManager
                                                  .deleteRecent(DataModel(
                                                place: favs[index]["place"],
                                                region: favs[index]["region"],
                                              ))
                                                  .whenComplete(() {
                                                log("sucess deletion");
                                                Navigator.pop(context);
                                                setState(() {
                                                  log('messageabcd');
                                                });
                                              }).onError((error, stackTrace) {
                                                log(
                                                  error.toString(),
                                                );
                                              });
                                            },
                                            child: const Text(
                                              "YES",
                                              style: TextStyle(
                                                color: Colors.deepPurple,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                              child: Card(
                                margin: const EdgeInsets.only(
                                  bottom: 5,
                                ),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero),
                                color: const Color(0xffCCCCFF).withOpacity(0.5),
                                child: Container(
                                  padding: const EdgeInsets.all(15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(
                                            "${favs[index]["place"]}, ${favs[index]["region"]}",
                                            style: const TextStyle(
                                                color: Colors.yellow,
                                                fontSize: 25),
                                          ),
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: SizedBox(
                                              child: Row(
                                                children: [
                                                  Image.network(
                                                    images[index],
                                                    width: 22,
                                                    height: 25,
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                    "${temp[index]}°C",
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 22),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                    description[index],
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        child: Icon(
                                          (isFav ||
                                                  (place.contains(favs[index]
                                                          ["place"]) &&
                                                      state.contains(
                                                        favs[index]["region"],
                                                      )))
                                              ? Icons.favorite
                                              : Icons.favorite_outline_sharp,
                                          color: isFav
                                              ? Colors.yellow
                                              : (place.contains(favs[index]
                                                          ["place"]) &&
                                                      state.contains(
                                                        favs[index]["region"],
                                                      ))
                                                  ? Colors.yellow
                                                  : Colors.white,
                                        ),
                                        onTap: () {
                                          if (isFav ||
                                              (place.contains(
                                                      favs[index]["place"]) &&
                                                  state.contains(
                                                      favs[index]["region"]))) {
                                            _databaseManager
                                                .deleteFav(
                                              DataModel(
                                                place: favs[index]["place"],
                                                region: favs[index]["region"],
                                              ),
                                            )
                                                .whenComplete(() {
                                              log("Sucess Deletion");
                                              // place = [];
                                              //           state = [];
                                              //           setState(() {
                                              //             "${favs[index]["place"]} removed from favourites"
                                              //                 .ToastMessage(
                                              //                     Colors.white);
                                              //           });
                                              setState(() {});
                                            }).onError((error, stackTrace) {
                                              log(error.toString());
                                            });
                                          } else {
                                            _databaseManager
                                                .insertFav(
                                              DataModel(
                                                place: favs[index]["place"],
                                                region: favs[index]["region"],
                                              ),
                                            )
                                                .whenComplete(() {
                                              log("Sucess");
                                              // place = [];
                                              //           state = [];
                                              //           setState(() {
                                              //             "${favs[index]["place"]} removed from favourites"
                                              //                 .ToastMessage(
                                              //                     Colors.white);
                                              //           });
                                              setState(() {});
                                            }).onError((error, stackTrace) {
                                              log(error.toString());
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                ),
              ]);
            }
            return const Text('Error');
          }),
    );
  }
}

class CustomAppBarTitle extends StatefulWidget {
  const CustomAppBarTitle({
    super.key,
    required this.isFav,
    required this.searchController,
  });

  final bool isFav;
  final TextEditingController searchController;

  @override
  State<CustomAppBarTitle> createState() => _CustomAppBarTitleState();
}

class _CustomAppBarTitleState extends State<CustomAppBarTitle> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SearchIndexProvider>(
      builder: (BuildContext context, value, Widget? child) {
        return IndexedStack(
          index: value.index,
          alignment: Alignment.center,
          children: [
            Text(
              widget.isFav ? "Favourite" : "Recent Search",
              style: const TextStyle(color: Colors.black, fontSize: 24),
            ),
            SizedBox(
              width: 200,
              child: TextField(
                controller: widget.searchController,
                cursorColor: Colors.black,
                onSubmitted: (data) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: widget.isFav ? "Search Favourite" : "Search Recent",
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}


class TopInfoBarWithNodata extends StatelessWidget {
  const TopInfoBarWithNodata({
    Key? key,
    required this.isFav,
  }) : super(key: key);

  final bool isFav;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 130,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              isFav ? "No Favorites added." : "No Recent Search",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class TopInfoBar extends StatefulWidget {
  const TopInfoBar({
    super.key,
    required this.isFavorite,
    required this.favsListLength,
  });

  final bool isFavorite;
  final List<Map<String, dynamic>> favsListLength;

  @override
  State<TopInfoBar> createState() => _TopInfoBarState();
}

class _TopInfoBarState extends State<TopInfoBar> {
  final DatabaseManager _databaseManager = DatabaseManager();

  bool get isFav => widget.isFavorite;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      left: 18,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isFav
                ? "${widget.favsListLength.length} City added as favourite"
                : "You recently searched for",
            style: const TextStyle(color: Colors.white),
          ),
          TextButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Text(
                        isFav
                            ? "Are you sure you want to remove all the favourites?"
                            : "Are you sure you want to remove all the recent searches?",
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 18),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "NO",
                            style: TextStyle(color: Colors.deepPurple),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            if (isFav) {
                              _databaseManager.deleteAllFav().whenComplete(() {
                                log('Sucess deletion');
                                setState(() {
                                  Navigator.pop(context);
                                });
                              }).onError((error, stackTrace) {
                                log(error.toString());
                              });
                            } else {
                              _databaseManager
                                  .deleteAllRecent()
                                  .whenComplete(() {
                                log('Sucess deletion');
                                setState(() {
                                  Navigator.pop(context);
                                });
                              }).onError((error, stackTrace) {
                                log(error.toString());
                              });
                            }
                          },
                          child: const Text(
                            "YES",
                            style: TextStyle(color: Colors.deepPurple),
                          ),
                        ),
                      ],
                    );
                  });
            },
            child: Text(
              isFav ? "Remove All" : "Clear All",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
