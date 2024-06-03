import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Recipe {
  String name;
  String description;
  List<String> ingredients;
  List<String> directions;
  bool isAddedToGrocery;

  Recipe({
    required this.name,
    required this.description,
    required this.ingredients,
    required this.directions,
    this.isAddedToGrocery = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'ingredients': ingredients,
        'directions': directions,
        'isAddedToGrocery': isAddedToGrocery,
      };

  static Recipe fromJson(Map<String, dynamic> json) => Recipe(
        name: json['name'],
        description: json['description'],
        ingredients: List<String>.from(json['ingredients']),
        directions: List<String>.from(json['directions']),
        isAddedToGrocery: json['isAddedToGrocery'],
      );
}

class RecipeProvider with ChangeNotifier {
  List<Recipe> _recipes = [];

  List<Recipe> get recipes => _recipes;

  RecipeProvider() {
    _loadRecipes();
  }

  void addRecipe(Recipe recipe) {
    _recipes.add(recipe);
    _saveRecipes();
    notifyListeners();
  }

  void updateRecipe(Recipe recipe) {
    final index = _recipes.indexWhere((r) => r.name == recipe.name);
    if (index != -1) {
      _recipes[index] = recipe;
      _saveRecipes();
      notifyListeners();
    }
  }

  void removeRecipe(Recipe recipe) {
    _recipes.remove(recipe);
    _saveRecipes();
    notifyListeners();
  }

  Future<void> _loadRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final recipesJson = prefs.getString('recipes') ?? '[]';
    _recipes = List<Map<String, dynamic>>.from(json.decode(recipesJson))
        .map((json) => Recipe.fromJson(json))
        .toList();
    notifyListeners();
  }

  Future<void> _saveRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final recipesJson = json.encode(_recipes.map((recipe) => recipe.toJson()).toList());
    prefs.setString('recipes', recipesJson);
  }
}