import 'package:flutter/material.dart';
import 'package:mealapp/models/category.dart';
import 'package:mealapp/models/meal.dart';
import '../dummy_data.dart';
import 'package:shared_preferences/shared_preferences.dart';


class MealProvider with ChangeNotifier {
  Map<String, bool> filters = {
    'gluten': false,
    'lactose': false,
    'vegan': false,
    'vegetarian': false,
  };
  List<Meal> availableMeals = DUMMY_MEALS;
  List<Meal> favoriteMeals = [];
  List<String> prefsMealId=[];
  List<Category> availableCategory= DUMMY_CATEGORIES;

  void setFilters() async{

    availableMeals = DUMMY_MEALS.where((meal) {
      if (filters['gluten'] && !meal.isGlutenFree) {
        return false;
      }
      if (filters['lactose'] && !meal.isLactoseFree) {
        return false;
      }
      if (filters['vegan'] && !meal.isVegan) {
        return false;
      }
      if (filters['vegetarian'] && !meal.isVegetarian) {
        return false;
      }
      return true;
    }).toList();

    List<Category> ac = [];
    availableMeals.forEach((meal) {
      meal.categories.forEach((catId) {
        DUMMY_CATEGORIES.forEach((cat) {

          if(cat.id== catId)
            {
              if(!ac.any((cat) => cat.id == catId))
                ac.add(cat);
            }
        });
      });
    });
    availableCategory= ac;
    notifyListeners();


     SharedPreferences  pref = await SharedPreferences.getInstance();
    pref.setBool("gluten", filters['gluten'] );
    pref.setBool("lactose", filters['lactose'] );
    pref.setBool("vegan", filters['vegan'] );
    pref.setBool("vegetarian", filters['vegetarian'] );
    notifyListeners();
  }
  void getData() async{
    SharedPreferences  prefs = await SharedPreferences.getInstance();
    filters['gluten']= prefs.getBool("gluten")??false;
    filters['lactose'] = prefs.getBool("lactose")??false;
    filters['vegan'] = prefs.getBool("vegan")??false;
    filters['vegetarian'] = prefs.getBool("vegetarian")??false;

   prefsMealId= prefs.getStringList("prefsMealId")??[];

    for(var mealId in prefsMealId){
      final existingIndex = favoriteMeals.indexWhere((meal) => meal.id == mealId);

      if (existingIndex < 0){
        favoriteMeals.add(
          DUMMY_MEALS.firstWhere((meal) => meal.id == mealId),
        );
      }

    }

    notifyListeners();
  }

  bool isFavoritesMeals= false;
  void toggleFavorite(String mealId) async{
    SharedPreferences  prefs = await SharedPreferences.getInstance();

    final existingIndex = favoriteMeals.indexWhere((meal) => meal.id == mealId);
    if (existingIndex >= 0) {

      favoriteMeals.removeAt(existingIndex);
      prefsMealId.remove(mealId);
    } else {
      favoriteMeals.add(
        DUMMY_MEALS.firstWhere((meal) => meal.id == mealId),

      );
      prefsMealId.add(mealId);
    }
    isFavoritesMeals=favoriteMeals.any((meal) => meal.id == mealId);
    notifyListeners();
    prefs.setStringList("prefsMealId", prefsMealId);
  }
  bool isFavorite(String mealId){

    return favoriteMeals.any((meal) => meal.id == mealId);
  }


}
