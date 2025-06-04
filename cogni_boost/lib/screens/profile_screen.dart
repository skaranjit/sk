import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile & Settings')),
      body: ListView(
        padding: EdgeInsets.all(8.0),
        children: <Widget>[
          SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).primaryColorLight,
            child: Icon(Icons.person, size: 60, color: Colors.white),
          ),
          SizedBox(height: 10),
          Center(child: Text("User Name", style: Theme.of(context).textTheme.headlineSmall)),
          SizedBox(height: 20),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.notifications, color: Theme.of(context).colorScheme.secondary),
                  title: Text('Notification Settings'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () { /* Navigate to notification settings */ },
                ),
                ListTile(
                  leading: Icon(Icons.palette, color: Theme.of(context).colorScheme.secondary),
                  title: Text('Appearance'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () { /* Navigate to appearance settings */ },
                ),
                ListTile(
                  leading: Icon(Icons.lock, color: Theme.of(context).colorScheme.secondary),
                  title: Text('Account & Security'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () { /* Navigate to account settings */ },
                ),
                ListTile(
                  leading: Icon(Icons.help_outline, color: Theme.of(context).colorScheme.secondary),
                  title: Text('Help & Support'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () { /* Navigate to help page */ },
                ),
                ListTile(
                  leading: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.secondary),
                  title: Text('About CogniBoost'),
                  onTap: () { /* Show about dialog */ },
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400], foregroundColor: Colors.white),
              onPressed: () { /* Handle Logout */ },
              child: Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }
}
