import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'recipe_provider.dart';

class MealPlanningPage extends StatefulWidget {
  final Function(List<String>) addToGroceryList;

  const MealPlanningPage({super.key, required this.addToGroceryList});

  @override
  // ignore: library_private_types_in_public_api
  _MealPlanningPageState createState() => _MealPlanningPageState();
}

class _MealPlanningPageState extends State<MealPlanningPage> {
  void _addRecipe() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController ingredientsController = TextEditingController();
    final TextEditingController directionsController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Recipe'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Recipe Name'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                    ),
                    TextField(
                      controller: ingredientsController,
                      decoration: const InputDecoration(labelText: 'Ingredients (comma separated)'),
                    ),
                    TextField(
                      controller: directionsController,
                      decoration: const InputDecoration(labelText: 'Directions (comma separated)'),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  Provider.of<RecipeProvider>(context, listen: false).addRecipe(
                    Recipe(
                      name: nameController.text,
                      description: descriptionController.text,
                      ingredients: ingredientsController.text.split(',').map((e) => e.trim()).toList(),
                      directions: directionsController.text.split(',').map((e) => e.trim()).toList(),
                    ),
                  );
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _editRecipe(Recipe recipe) {
    final TextEditingController nameController = TextEditingController(text: recipe.name);
    final TextEditingController descriptionController = TextEditingController(text: recipe.description);
    final TextEditingController ingredientsController = TextEditingController(text: recipe.ingredients.join(', '));
    final TextEditingController directionsController = TextEditingController(text: recipe.directions.join(', '));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Recipe'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Recipe Name'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                    ),
                    TextField(
                      controller: ingredientsController,
                      decoration: const InputDecoration(labelText: 'Ingredients (comma separated)'),
                    ),
                    TextField(
                      controller: directionsController,
                      decoration: const InputDecoration(labelText: 'Directions (comma separated)'),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    recipe.name = nameController.text;
                    recipe.description = descriptionController.text;
                    recipe.ingredients = ingredientsController.text.split(',').map((e) => e.trim()).toList();
                    recipe.directions = directionsController.text.split(',').map((e) => e.trim()).toList();
                  });
                  Provider.of<RecipeProvider>(context, listen: false).updateRecipe(recipe);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteRecipe(Recipe recipe) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Recipe'),
          content: Text('Are you sure you want to delete ${recipe.name}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Provider.of<RecipeProvider>(context, listen: false).removeRecipe(recipe);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addToGroceryList(Recipe recipe) {
    widget.addToGroceryList(recipe.ingredients);
    setState(() {
      recipe.isAddedToGrocery = true;
    });
    Provider.of<RecipeProvider>(context, listen: false).updateRecipe(recipe);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Storage'),
      ),
      body: Consumer<RecipeProvider>(
        builder: (context, recipeProvider, child) {
          return recipeProvider.recipes.isEmpty
              ? Center(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.1,
                          child: Image.asset(
                            'assets/recipe_background.png', // Add your background image asset
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 100,
                              color: Colors.purple.withOpacity(0.5),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'No Recipes Yet!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Tap the + button to add your first recipe.',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black.withOpacity(0.5),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: Image.asset(
                          'assets/recipe_background.png', // Add your background image asset
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    ListView.builder(
                      itemCount: recipeProvider.recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = recipeProvider.recipes[index];
                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(recipe.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Description: ${recipe.description}'),
                                Text('Ingredients: ${recipe.ingredients.join(', ')}'),
                                Text('Directions: ${recipe.directions.join(', ')}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editRecipe(recipe),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteRecipe(recipe),
                                ),
                              ],
                            ),
                            leading: IconButton(
                              icon: const Icon(Icons.add_shopping_cart),
                              onPressed: recipe.isAddedToGrocery ? null : () => _addToGroceryList(recipe),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRecipe,
        child: const Icon(Icons.add),
      ),
    );
  }
}
