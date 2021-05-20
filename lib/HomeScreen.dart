import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    _askPermissions(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.blue,),
      body: contactList(),
    );
  }


  Widget contactList() {
    return SingleChildScrollView(
      primary: true,

      child: Container(
        child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            List<Widget> list = [];
            contacts[index].phones.forEach((chart) => {
            list.add(Text(chart.value))}
            );
            return Container(
              child: ListTile(
                title: Text(contacts[index].displayName),
                subtitle:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: list
                ),

              ),
            );
          },
        ),
      ),
    );
  }

  void getContactsList() async {
    try {
      Iterable<Contact> _contacts = await getOnlyContactsStartWith03();
      // ignore: missing_return
      for(Contact mContact in _contacts){
            if(mContact != null){
              List<Item> newPhones = [];
              if(mContact.phones != null && mContact.phones.isNotEmpty){

                for(Item phoneNo in mContact.phones){
                  if(phoneNo.value.isNotEmpty){
                    if(phoneNo.value.startsWith("03")){


                      String removedNo= phoneNo.value.substring(1);
                      Item item = Item(label:'phone',value:"+92"+removedNo);
                      newPhones.add(item);


                    }
                    else {
                      newPhones.add(phoneNo);

                    }
                  }
                }
                mContact.phones = newPhones;
                await ContactsService.updateContact(mContact);

                contacts.add(mContact);
              }
            }
          }

      setState(() {
      print(contacts.length.toString());
      });
    } catch (e) {
      print(e);
    }

    debugPrint(contacts.length.toString());

  }
  Future<List<Contact>> getOnlyContactsStartWith03() async {
    List<Contact> newContacts = [];

    try {
      Iterable<Contact> _contacts = await ContactsService.getContacts();
      for(Contact mContact in _contacts){
        bool isAddable = false;
            if(mContact != null){
              if(mContact.phones != null && mContact.phones.isNotEmpty){

                    for(Item phoneNo in mContact.phones){
                      if(phoneNo.value.isNotEmpty){
                        if(phoneNo.value.startsWith("03")){
                          isAddable = true;
                        }
                  }
                }
              }
              if(isAddable){
                newContacts.add(mContact);

              }
            }
          }

    } catch (e) {
      print(e);
    }
  return newContacts;

  }


  Future<void> _askPermissions(BuildContext context) async {
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.denied) {
      _handleInvalidPermissions(permissionStatus, context);
    }
    else{
      getContactsList();
    }
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus,
      BuildContext context) {
    if (permissionStatus == PermissionStatus.denied) {
      final snackBar = SnackBar(content: Text('Access to contact data denied'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      final snackBar =
      SnackBar(content: Text('Contact data not available on device'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}