import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/services/user_data_services.dart';

class CategoryDialog extends StatefulWidget {
  final List<dynamic> userCategories;
  const CategoryDialog({super.key, required this.userCategories});

  @override
  State<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  late List<dynamic> userCategories;
  final UserDataServices _userDataServices = UserDataServices(userID: FirebaseAuth.instance.currentUser!.uid);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userCategories = widget.userCategories;
  }

  void updateCategories(List<dynamic> updatedCategoryList) {
    setState(() {
      userCategories = updatedCategoryList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Categories"),
      content: SizedBox(
        width: double.maxFinite,
        height: 350,
        child: CategoryCheckList(userCategories: userCategories, updateCategoryList: updateCategories),
      ),
      actions:  [
        ElevatedButton(
            onPressed: (){
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    content: const Text("Save changes to categories?"),
                    actions: [
                      TextButton(
                          onPressed: (){
                            _userDataServices.updateCategories(userCategories);
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          child: const Text("Yes")
                      ),
                      TextButton(
                          onPressed: (){
                            setState(() {
                              userCategories = widget.userCategories;
                            });
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          child: const Text("No")
                      ),
                    ],
                  )
              );

            },
            child: const Text("Update")
        ),
      ],
    );
  }
}

class CategoryCheckList extends StatefulWidget {
  final List<dynamic> userCategories;
  final Function(List<dynamic>) updateCategoryList;
  const CategoryCheckList({super.key, required this.userCategories, required this.updateCategoryList});

  @override
  State<CategoryCheckList> createState() => _CategoryCheckListState();
}

class _CategoryCheckListState extends State<CategoryCheckList> {
  List<String> availableCategories = ['Copywriter', 'Translator', 'Graphic Designer', 'Administrative', 'Editor', 'Data Entry', 'Marketing',
    'Social Media Manager', 'Finance', 'Human Resources', 'Photographer', 'Programmer', 'Web Development', 'Writing', 'Accountant',
    'Content Marketer', 'Customer Service', 'Engineering', 'IT', 'Legal', 'Medical', 'Virtual Assistant', 'App Developer',
    'Digital Marketing', 'Carpentry'];
  late List<dynamic> userCategories;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userCategories = widget.userCategories;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount:availableCategories.length,
        itemBuilder:(context, index)  {
          return CheckboxListTile(
            value: userCategories.contains(availableCategories[index]),
            onChanged: (bool? value) {
              if (!userCategories.contains(availableCategories[index])) {
                setState(() {
                  userCategories.add(availableCategories[index]);
                });
              } else if (userCategories.contains(availableCategories[index])) {
                setState(() {
                  userCategories.remove(availableCategories[index]);
                });
              }
              widget.updateCategoryList(userCategories);
            },
            title: Text(availableCategories[index]),
          );
        }
    );
  }
}