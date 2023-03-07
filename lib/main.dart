//import 'dart:isolate';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:flutter_complete_guide/widgets/chart.dart';
import 'package:flutter_complete_guide/widgets/transaction_list.dart';
import './widgets/transaction_list.dart';
import './widgets/new_transaction.dart';
import './widgets/chart.dart';
// import './widgets/transaction_list.dart';
import './models/transaction.dart';
//import 'package:intl/intl.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();   //for small devices
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Expanse App',
      theme: ThemeData(
          primarySwatch: Colors.purple,
          accentColor: Colors.amber,
          // errorColor: Colors.red,
          fontFamily: 'Quicksand',
          textTheme: ThemeData.light().textTheme.copyWith(
                headline6: TextStyle(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                button: TextStyle(color: Colors.white),
              ),
          appBarTheme: AppBarTheme(
            textTheme: ThemeData.light().textTheme.copyWith(
                  headline6: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  button: TextStyle(color: Colors.white),
                ),
          )),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

//final List<Transaction> transactions = [
// Transaction(
//   id: 't1',
//   title: 'New Shoes',
//   amount: 69.99,
//   date: DateTime.now(),
// ),
// Transaction(
//   id: 't2',
//   title: 'Weekly Groceries',
//   amount: 16.53,
//   date: DateTime.now(),
// ),
//];
// String titleInput;
// String amountInput;
//final titleController =TextEditingController();   //move to new transaction
//final amountController =TextEditingController();
class _MyHomePageState extends State<MyHomePage>  with WidgetsBindingObserver {
  final List<Transaction> _userTransactions = [
    // Transaction(
    //   id: 't1',
    //   title: 'New Shoes',
    //   amount: 69.99,
    //   date: DateTime.now(),
    // ),
    // Transaction(
    //   id: 't2',
    //   title: 'Weekly Groceries',
    //   amount: 16.53,
    //   date: DateTime.now(),
    // ),
  ];
  bool _showChart = false;

@override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
  }

  @override
  dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  List<Transaction> get _recentTransactions {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          Duration(days: 7),
        ),
      );
    }).toList();
  }

  void _addNewTransaction(
      String txTitle, double txAmount, DateTime chosenDate) {
    final newTx = Transaction(
      title: txTitle,
      amount: txAmount,
      date: chosenDate,
      id: DateTime.now().toString(),
    );

    setState(() {
      _userTransactions.add(newTx);
    });
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: NewTransaction(_addNewTransaction),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
    });
  }

  List<Widget> _buildLandsacapeContent(
    MediaQueryData mediaQuery,
    AppBar appBar,
    Widget txListWidget,
  ) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Show Chart',
            style: Theme.of(context).textTheme.headline6,
          ),
          Switch.adaptive(
            activeColor: Theme.of(context).accentColor,
            value: _showChart,
            onChanged: (val) {
              setState(() {
                _showChart = val;
              });
            },
          ),
        ],
      ),
      _showChart
          ? Container(
              height: (mediaQuery.size.height -
                      appBar.preferredSize.height -
                      mediaQuery.padding.top) *
                  0.7,
              child: Chart(_recentTransactions))
          : txListWidget
    ];
  }

  List<Widget> _buildPortraitContent(
    MediaQueryData mediaQuery,
    AppBar appBar,
    Widget txListWidget,
  ) {
    return [
      Container(
          height: (mediaQuery.size.height -
                  appBar.preferredSize.height -
                  mediaQuery.padding.top) *
              0.3,
          child: Chart(_recentTransactions)),
      txListWidget
    ];
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final PreferredSizeWidget appBar = Platform.isIOS
        ? CupertinoNavigationBar(
            middle: Text(
              'Personal Expanse App',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  child: Icon(CupertinoIcons.add),
                  onTap: () => _startAddNewTransaction(context),
                ),
              ],
            ),
          )
        : AppBar(
            title: Text(
              'Personal Expanse App',
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => _startAddNewTransaction(context),
              ),
            ],
          );
    final txListWidget = Container(
        height: (mediaQuery.size.height -
                appBar.preferredSize.height -
                mediaQuery.padding.top) *
            0.7,
        child: TransactionList(_userTransactions, _deleteTransaction));
    final pageBody = SafeArea(
      child: SingleChildScrollView(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (isLandscape)
              ..._buildLandsacapeContent(
                mediaQuery,
                appBar,
                txListWidget,
              ),
            // Row(                              //move to widget landscape
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: <Widget>[
            //     Text('Show Chart',style: Theme.of(context).textTheme.headline6,),
            //     Switch.adaptive(
            //       activeColor: Theme.of(context).accentColor,
            //       value: _showChart,
            //       onChanged: (val) {
            //         setState(() {
            //           _showChart = val;
            //         });
            //       },
            //     ),
            //   ],
            // )
            if (!isLandscape)
              ..._buildPortraitContent(
                  //spread operator
                  mediaQuery,
                  appBar,
                  txListWidget),
            // Container(                   //move to the widget build portrait
            //     height: (mediaQuery.size.height -
            //             appBar.preferredSize.height -
            //             mediaQuery.padding.top) *
            //         0.3,
            //     child: Chart(_recentTransactions)
            //     ),
            //if (!isLandscape) txListWidget,  //merge build portrait
            //if (isLandscape)  //revove
            // _showChart        // merge with landscape widget
            //     ? Container(
            //         height: (mediaQuery.size.height -
            //                 appBar.preferredSize.height -
            //                 mediaQuery.padding.top) *
            //             0.7,
            //         child: Chart(_recentTransactions))
            //     : txListWidget
          ],
        ),
      ),
    );
    return Platform.isIOS
        ? CupertinoPageScaffold(
            child: pageBody,
            navigationBar: appBar,
          )
        : Scaffold(
            // appBar: AppBar(                //move to variable
            //   title: Text('Personal Expanse App',
            //   ),
            //   actions: <Widget>[
            //     IconButton(
            //       icon: Icon(Icons.add),
            //       onPressed: () =>_startAddNewTransaction(context),
            //     ),
            //   ],
            // ),
            appBar: appBar,
            body:
                pageBody //SingleChildScrollView(          //move to the widget
            //   child: Column(
            //     //mainAxisAlignment: MainAxisAlignment.start,
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     children: <Widget>[
            //       if (isLandscape)
            //         Row(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: <Widget>[
            //             Text('Show Chart'),
            //             Switch.adaptive(
            //               activeColor: Theme.of(context).accentColor,
            //               value: _showChart,
            //               onChanged: (val) {
            //                 setState(() {
            //                   _showChart = val;
            //                 });
            //               },
            //             ),
            //           ],
            //         ),
            //       if (!isLandscape)
            //         Container(
            //             height: (mediaQuery.size.height -
            //                     appBar.preferredSize.height -
            //                     mediaQuery.padding.top) *
            //                 0.3,
            //             child: Chart(_recentTransactions)),
            //       if (!isLandscape) txListWidget,
            //       if (isLandscape)
            //         _showChart
            //             ? Container(
            //                 height: (mediaQuery.size.height -
            //                         appBar.preferredSize.height -
            //                         mediaQuery.padding.top) *
            //                     0.7,
            //                 child: Chart(_recentTransactions))
            //             :
            //Chart(_recentTransactions), without media query
            // Container(        //replaced with Chart
            //   width: double.infinity,
            //   child: Card(
            //     child: Text("Chart"),
            //     elevation: 5,
            //   ),
            // ),
            //NewTransaction(),     //move to user transaction
            // Card(                             //move to new transaction
            //   elevation: 5,
            //   child: Container(
            //     padding: EdgeInsets.all(10),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.end,
            //       children: <Widget>[
            //         TextField(
            //           decoration: InputDecoration(labelText: 'Title'),
            //           controller: titleController,
            //           // onChanged: (val) {
            //           //   titleInput = val;
            //           // },
            //         ),
            //         TextField(
            //           decoration: InputDecoration(labelText: 'Amount'),
            //           controller: amountController,
            //           //onChanged: (val) => amountInput = val,
            //         ),
            //         FlatButton(
            //           child: Text('Add Transaction'),
            //           textColor: Colors.purple,
            //           onPressed: () {
            //             print(titleController.text);
            //           },
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            //TransactionList()   //move to user_transaction
            // Column(                                   //copy to transactlist
            //   children: transactions.map((tx) {
            //     return Card(
            //       child: Row(
            //         children: <Widget>[
            //           Container(
            //             margin: EdgeInsets.symmetric(
            //               vertical: 10,
            //               horizontal: 15,
            //             ),
            //             decoration: BoxDecoration(
            //               border: Border.all(
            //                 color: Colors.purple,
            //                 width: 2,
            //               ),
            //             ),
            //             padding: EdgeInsets.all(10),
            //             child: Text(
            //               '\$${tx.amount}',
            //               style: TextStyle(
            //                 fontWeight: FontWeight.bold,
            //                 fontSize: 20,
            //                 color: Colors.purple,
            //               ),
            //             ),
            //           ),
            //           Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: <Widget>[
            //               Text(
            //                 tx.title,
            //                 style: TextStyle(
            //                   fontSize: 16,
            //                   fontWeight: FontWeight.bold,
            //                 ),
            //               ),
            //               Text(
            //                 DateFormat.yMMMd().format(tx.date),
            //                 style: TextStyle(color: Colors.grey),
            //               ),
            //             ],
            //           ),
            //         ],
            //       ),
            //     );
            //   }).toList(),
            // ),
            //UserTransactions()
            //TransactionList(_userTransactions, _deleteTransaction),  //without media query
            // Container(                                                //move to the variable
            //     height: (MediaQuery.of(context).size.height -
            //             appBar.preferredSize.height -
            //             MediaQuery.of(context).padding.top) *
            //         0.7,
            //     child:
            //         TransactionList(_userTransactions, _deleteTransaction)),
            //             txListWidget
            //     ],
            //   ),
            // ),
            ,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Platform.isIOS
                ? Container()
                : FloatingActionButton(
                    child: Icon(Icons.add),
                    onPressed: () => _startAddNewTransaction(context),
                  ),
          );
  }
}
