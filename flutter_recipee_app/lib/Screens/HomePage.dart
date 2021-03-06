import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipee_app/Screens/RecipeDetails.dart';
import 'package:flutter_recipee_app/model/CategoriesModel.dart';
import 'package:flutter_recipee_app/model/Recipe.dart';
import "package:http/http.dart" as http;
import 'package:flutter_recipee_app/NewRecipe.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  List<Categories> categories = [];
  List<Recipe> recettes = [];

  bool loadCategories;
  bool loadRecettes = true;
  String categorieSelectioner;

  getRecettes(String categori) async {
    var url = Uri.parse(
        "https://www.themealdb.com/api/json/v1/1/filter.php?c=$categori");
    try {
      setState(() {
        loadRecettes = true;
      });
      var requete = await http.get(url);
      if (requete.statusCode == 200) {
        final result = jsonDecode(requete.body);

        setState(() {
          recettes = List.generate(result["meals"].length, (index) {
            return Recipe(
              id: result["meals"][index]["idMeal"],
              title: result["meals"][index]["strMeal"],
              imgPath: result["meals"][index]["strMealThumb"]
                  .replaceAll(RegExp(r"\\"), ""),
              time: "10",
            );
          });
          loadRecettes = false;
        });
      } else {
        print(requete.statusCode);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  getCategories() async {
    var url = Uri.parse(
      'https://www.themealdb.com/api/json/v1/1/categories.php',
    );
    try {
      setState(() {
        loadCategories = true;
      });
      var requete = await http.get(url);
      if (requete.statusCode == 200) {
        final result = jsonDecode(requete.body);

        setState(() {
          categories = List.generate(result["categories"].length, (index) {
            return Categories(
              nom: result["categories"][index]["strCategory"],
              image: result["categories"][index]["strCategoryThumb"]
                  .replaceAll(RegExp(r"\\"), ""),
              description: result["categories"][index]
                  ["strCategoryDescription"],
            );
          });
          loadCategories = false;
          categorieSelectioner = categories[0].nom;
          getRecettes(categorieSelectioner);
        });
      } else {
        print(requete.statusCode);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    getCategories();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        // color: Colors.grey[300],

        height: 60,
        child: loadCategories
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.amber,
                  strokeWidth: 2,
                ),
              )
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, i) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        categorieSelectioner = categories[i].nom;
                        getRecettes(categorieSelectioner);
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(10),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            child: Image.network(
                              categories[i].image,
                              width: 30,
                              height: 30,
                            ),
                          ),
                          Text(
                            categories[i].nom,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: categorieSelectioner == categories[i].nom
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      decoration: BoxDecoration(
                        color: categorieSelectioner == categories[i].nom
                            ? Colors.amber
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                itemCount: categories.length,
              ),
      ),
      body: SafeArea(
        bottom: false,
        child: DefaultTabController(
          length: 2,
          initialIndex: 0,
          child: Column(
            children: [
              SizedBox(
                height: 40,
              ),
              TabBar(
                isScrollable: true,
                indicatorColor: Colors.red,
                tabs: [
                  Tab(
                    text: "New Recipes".toUpperCase(),
                  ),
                  Tab(
                    text: "Favourites".toUpperCase(),
                  ),
                ],
                labelColor: Colors.black,
                indicator: DotIndicator(
                  color: Colors.black,
                  distanceFromCenter: 16,
                  radius: 3,
                  paintingStyle: PaintingStyle.fill,
                ),
                unselectedLabelColor: Colors.black.withOpacity(0.3),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                labelPadding: EdgeInsets.symmetric(
                  horizontal: 24,
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: <Widget>[
                    !loadRecettes
                        ? ListView.builder(
                            itemCount: recettes.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                child: InkWell(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RecipeDetails(
                                          recipe: recettes[index],
                                        ),
                                      )),
                                  child: RecipeCard(
                                    recipe: recettes[index],
                                  ),
                                ),
                              );
                            },
                          )
                        : Center(
                            child:
                                CircularProgressIndicator(color: Colors.amber),
                          ),
                    Container(
                      child: Center(
                        child: Text(
                          'Favourite Section',
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
