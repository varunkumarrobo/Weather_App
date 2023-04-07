import 'package:flutter/material.dart';
import 'package:trial_wea/screens/favorite_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          ListTile(
            selectedTileColor: Colors.transparent,
            title: const Text(' Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text(' Favourite'),
            onTap: () {
              //  _key.currentState!.closeDrawer();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FavoriteScreen(),
                      settings: const RouteSettings(arguments: {"fav": true},),),);
            },
          ),
          ListTile(
            title: const Text('Recent Search'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FavoriteScreen(),
                      settings:
                          const RouteSettings(arguments: {"fav": false},),),);
              // Navigator.pushReplacement(context,
              //     MaterialPageRoute(builder: (context) => const RecentSearch()));
            },
          ),
        ],
      ),
    );
  }
}
