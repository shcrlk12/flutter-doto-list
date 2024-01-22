import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Todo List App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.purpleAccent),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var todoList = <TodoItemInfo>[];
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

  addTodoList(TodoItemInfo todo) {
      todoList.add(todo);
      notifyListeners();
  }

  removeTodoList(TodoItemInfo todoItemInfo){
    todoList.remove(todoItemInfo);
    notifyListeners();
  }


  void Okay() {
    var animatedList = listKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;

    switch(selectedIndex){
      case 0:
        page = AddTodoList();
        break;
      case 1:
        page = TodoListView();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
        break;
    }
    var theme = Theme.of(context);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraint) {
          return Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraint.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.list),
                      label: Text('Todo List'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(child:
                Container(
                  color: theme.colorScheme.surfaceVariant,
                  child: page,
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}

class AddTodoList extends StatelessWidget {

  AddTodoList({
    super.key,
  });
  final fieldTextController = TextEditingController();

  void clearText() {
    fieldTextController.clear();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    String todo = '';
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: AnimatedList(
            key: appState.listKey,
            initialItemCount: appState.todoList.length,
            reverse: true,
            itemBuilder:(context, index, animation){
              var icon;

              if(appState.todoList.elementAt((appState.todoList.length - 1) - index).todoType == 1){
                icon = Icons.circle_outlined;
              }
              else if(appState.todoList.elementAt((appState.todoList.length - 1) - index).todoType == 2){
                icon = Icons.done;
              }
              return SizeTransition(
                  sizeFactor: animation,
                  child: Center(
                      child: TextButton.icon(
                        onPressed: () {
                        },
                        icon: Icon(icon, size: 12),
                        label: Text(
                          appState.todoList.elementAt((appState.todoList.length - 1) - index).description,
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      )
                  ),
              );
            }
          ),
        ),
        SizedBox(
          width: 250,
          child: TextField(
            maxLength: 32,
            controller: fieldTextController,
            onChanged: (data){
              todo = data;
            },
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Todo List',
            ),
          ),
        ),
        SizedBox(height: 15,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: (){
                if(todo.isNotEmpty) {
                  appState.addTodoList(
                      TodoItemInfo(description: todo, todoType: 2));
                  appState.Okay();
                  clearText();
                }
              },
              icon: Icon(Icons.done),
              label: Text('완료'),
            ),
            SizedBox(width: 10,),
            ElevatedButton.icon(
              onPressed: (){
                if(todo.isNotEmpty) {
                  appState.addTodoList(
                      TodoItemInfo(description: todo, todoType: 1));
                  appState.Okay();
                  clearText();
                }
              },
              icon: Icon(Icons.add),
              label: Text('추가'),
            ),
          ],
        ),
        Spacer(flex: 2),
      ],
    );
  }
}

class TodoListView extends StatelessWidget {
  const TodoListView({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Column(
      children: [
        Text('Todo List'),
        SizedBox(height: 10,),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: GridView.count(
              crossAxisCount: 1,
              childAspectRatio: 800/70,
              children: appState.todoList.map((TodoItemInfo todo) {
                return TodoItem(todo: todo);
                }).toList(),
            ),
          ),
        )
      ],
    );
  }
}

class TodoItemInfo{
  const TodoItemInfo({
    required this.description,
    required this.todoType,
  });

  final String description;
  final int todoType;
}

class TextStyles {
  static const todoItemTextStyle = TextStyle(fontSize: 18,);
}

class TodoItem extends StatelessWidget {
  const TodoItem({
    super.key,
    required this.todo,
  });

  final TodoItemInfo todo;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var theme = Theme.of(context);
    var icon;

    if(todo.todoType == 1){
      icon = Icons.circle_outlined;
    }
    else if(todo.todoType == 2){
      icon = Icons.done;
    }

    return Row(
        children: [
          Icon(icon , size: 16, color: theme.colorScheme.primary),
          SizedBox(width: 5),
          Expanded(child: Text(todo.description, style: TextStyles.todoItemTextStyle)),
          IconButton(icon: Icon(Icons.delete_outline), onPressed: (){
            showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('삭제 하시겠 습니까?'),
                    content: Text(todo.description),
                    actions: [
                    TextButton(onPressed: (){
                      Navigator.of(context).pop();
                    }, child: Text('아니요')),
                    TextButton(onPressed: (){
                      appState.removeTodoList(todo);
                      Navigator.of(context).pop();
                    }, child: Text('예')),
                  ],);
              });
          },)
        ],
    );
  }
}
