import  'package:flutter/material.dart';


class AccountSettings extends StatefulWidget{
  const AccountSettings({super.key});
  
  State<AccountSettings> createState() => _AccountSettings();
}

class _AccountSettings extends State<AccountSettings>{
  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Settings"),
      ),
      body: Column(
        children: [
          Text("Name"),
          Text("Name Placeholder"),
          Text("Category"),
          Text("Category Placeholder"),
          Text("Category Description Placeholder")
        ],
      ),
    );
  }
}