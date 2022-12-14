import 'package:flutter/material.dart';
import 'package:fermentation/models/project.dart';
import 'package:fermentation/widgets/calendar_page.dart';
import 'package:fermentation/widgets/home_page.dart';
import 'package:fermentation/edit_project.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyApp> {
  final controller1 = TextEditingController();
  final controller2 = TextEditingController();
  final controller3 = TextEditingController();
  final controller4 = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final dbHelper = Databasehelper.instance;
  List entries = [];
  //controllers used in insert operation UI
  late List _pages;
  late List<String> _pageTitles;

  late int _currentIndex;
  late Widget _currentPage;

  @override
  void initState() {
    super.initState();
    const HomePage _page1 = HomePage();
    const CalendarPage _page2 = CalendarPage();
    _pages = [_page1, _page2];
    _pageTitles = ["Home", "Calendar"];
    _currentIndex = 0;
    _currentPage = _page1;
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _currentPage = _pages[index];
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller1.dispose();
    controller2.dispose();
    controller3.dispose();
    controller4.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _queryAll();
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(_pageTitles[_currentIndex]),
          titleTextStyle: const TextStyle(fontSize: 35),
          backgroundColor: Colors.redAccent,
          centerTitle: true,
          actions: [
            PopupMenuButton(
              icon: const Icon(Icons.edit_note_rounded),
              itemBuilder: (context) => [
                PopupMenuItem(
                    child: Form(
                        key: _formKey,
                        child: Column(children: <Widget>[
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black,
                            ),
                            child: const Text("Add Project"),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: const Text('New Project'),
                                        content: Column(children: <Widget>[
                                          TextFormField(
                                            controller: controller1,
                                            decoration: const InputDecoration(
                                              border: UnderlineInputBorder(),
                                              labelText:
                                                  'Enter your project name',
                                            ),
                                          ),
                                          TextFormField(
                                            controller: controller2,
                                            decoration: const InputDecoration(
                                              border: UnderlineInputBorder(),
                                              labelText:
                                                  'Enter your project start date',
                                            ),
                                          ),
                                          TextFormField(
                                            controller: controller3,
                                            decoration: const InputDecoration(
                                              border: UnderlineInputBorder(),
                                              labelText:
                                                  'Enter your project end date',
                                            ),
                                          )
                                        ]),
                                        actions: [
                                          TextButton(
                                              child: const Text('Cancel'),
                                              onPressed: () =>
                                                  Navigator.pop(context)),
                                          TextButton(
                                              child: const Text('Add'),
                                              onPressed: () {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(const SnackBar(
                                                        backgroundColor:
                                                            Colors.pink,
                                                        content: Text(
                                                            'Added project')));
                                                _insert(
                                                    controller1.text,
                                                    controller2.text,
                                                    controller3.text);
                                                _queryAll();
                                                setState(() {});
                                                controller1.clear();
                                                controller2.clear();
                                                controller3.clear();
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                              }),
                                        ],
                                      ));
                            },
                          ),
                          TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.black,
                              ),
                              child: const Text("Edit Project"),
                              onPressed: () {
                                _queryAll();
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => const EditPage()));
                              }),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black,
                            ),
                            child: const Text("Delete Project"),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => const AlertDialog(
                                      title: Text('My Title')));
                            },
                          ),
                        ])))
              ],
            ),
          ],
        ),
        body: _currentPage,
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'Calendar',
            ),
          ],
          currentIndex: _currentIndex,
          selectedItemColor: const Color.fromARGB(255, 230, 71, 23),
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  void _insert(name, start, end) async {
    // row to insert
    Project project = Project();
    project.setParams(name, start, end);
    await dbHelper.insert(project);
  }

  void _queryAll() async {
    final allRows = await dbHelper.queryAllRows();
    entries.clear();
    allRows.forEach((row) => entries.add(row));
    setState(() {});
  }

  void _deleteProject(int id) async {
    dbHelper.delete(id);
  }

  void _updateProject(Project project) {
    dbHelper.update(project);
  }
}
