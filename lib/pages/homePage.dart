import 'package:expenza/bar%20graph/bar_graph.dart';
import 'package:expenza/components/my_list_tile.dart';
import 'package:expenza/database/expense_database.dart';
import 'package:expenza/helper/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:expenza/models/expense.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //New expense name and amount Text Controlelrs.
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  //future to load graph data and monthly total
  Future<Map<String, double>>? _monthlyTotalFuture;
  Future<double>? _calculateCurrentMonthTotal;

  @override
  void initState() {
    Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();

    //loading futures
    refreshData();

    super.initState();
  }

  //refresh the graph data
  void refreshData(){
    _monthlyTotalFuture = Provider.of<ExpenseDatabase>(context, listen: false).calculateMonthlyTotals();
    _calculateCurrentMonthTotal = Provider.of<ExpenseDatabase>(context, listen: false).calculateCurrentMonthTotal();
  }

  //Open New Expense function
  void openNewExpenseBox() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("New Expense"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //Name text field.
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(hintText: "Name"),
                  ),

                  //Amount text field.
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(
                      hintText: "Amount",
                    ),
                  )
                ],
              ),
              actions: [
                //cancel button
                _cancelButton(),

                //Save button
                _createNewExpenseButton(),
              ],
            )
        );
  }

  //Open Edit Box
  void openEditBox(Expense expense){

    //prefilling the existing values into the text fields.
    String existingName = expense.name;
    String existingAmount = expense.amount.toString();


    //Show dialog box
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Edit Expense"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //Name text field.
              TextField(
                controller: nameController,
                decoration: InputDecoration(hintText: existingName),
              ),

              //Amount text field.
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  hintText: existingAmount ,
                ),
              )
            ],
          ),
          actions: [
            //cancel button
            _cancelButton(),

            //Save button
            _editExpenseButton(expense),
          ],
        )
    );

  }

  //Open Delete Box
  void openDeleteBox(Expense expense){
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Delete Expense?"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
          ),
          actions: [
            //cancel button
            _cancelButton(),

            //Save button
            _deleteExpenseButton(expense.id),
          ],
        )
    );
  }

  //Main Widget
  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(
        builder: (context, value, child) {

          //get dates
          int startMonth = value.getStartMonth();
          int startYear = value.getStartYear();
          int currentMonth = DateTime.now().month;
          int currentYear = DateTime.now().year;


          //calculate the number of month since the first month
          int monthCount = calculateMonthCount(startYear, startMonth, currentYear, currentMonth);

          //only display the expenses for the running month
          List<Expense> currentMonthExpenses = value.allExpense.where((expense){
            return expense.date.year == currentYear && expense.date.month == currentMonth;
          }).toList();

          //returning UI
          return Scaffold(
            backgroundColor: Colors.grey.shade300,
              floatingActionButton: FloatingActionButton(
                onPressed: openNewExpenseBox,
                child: const Icon(Icons.add),
              ),
              appBar: AppBar(
                backgroundColor: Colors.transparent ,
                title: FutureBuilder<double>(
                  future: _calculateCurrentMonthTotal,
                  builder: (context, snapshot){
                    if(snapshot.connectionState == ConnectionState.done){
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //amount total shown on the top
                          Text("₹ "+snapshot.data!.toStringAsFixed(2)),

                          //month
                          Text(getCurrentMonthName()),

                        ],
                      );
                    }

                    else{
                      return Text("loading..");
                    }
                  },
                ),
              ),

              body: SafeArea(
                child: Column(
                  children: [
                
                    //Graph UI
                    SizedBox(
                      height: 250,
                      child: FutureBuilder(
                        future: _monthlyTotalFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            Map<String,double> monthlyTotals = snapshot.data ?? {};

                            // Create the list of monthly summary
                            List<double> monthlySummary = List.generate(monthCount,
                                (index){
                                  int year = startYear + (startMonth + index - 1) ~/ 12;
                                  int month = (startMonth + index - 1) %12 +1;

                                  //Create the key in the format of year-month
                                  String yearMonthKey = '$year - $month';

                                  return monthlyTotals[yearMonthKey] ?? 0.0;

                                });

                            //Bar Graph data
                            return MyBarGraph(
                              monthlySummary: monthlySummary, // Corrected the typo here
                              startMonth: startMonth,
                            );
                          } else {
                            return Center(child: const Text("Loading..."));
                          }
                        },
                      ),
                    ),
                    
                    
                    //Expense list UI
                    Expanded(
                      child: ListView.builder(
                          itemCount: currentMonthExpenses.length,
                          itemBuilder: (context, index) {

                            //reversing the list to show the latest item first.
                            int reversedIndex = currentMonthExpenses.length - 1 - index;

                            //Get individual Expense
                            Expense individualExpense = currentMonthExpenses[reversedIndex ];
                            //Returning list tile UI.
                            return MyListTile(
                              title: individualExpense.name,
                              trailing: formatAmount(individualExpense.amount),
                              onEditPressed: (context) => openEditBox(individualExpense),
                              onDeletePressed: (context) => openDeleteBox(individualExpense),
                            );
                          }
                      ),
                    ),
                  ],
                ),
              )
          );
        }
    );
  }

  //Cancel button
  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () {
        Navigator.pop(context);

        nameController.clear();
        amountController.clear();
      },
      child: const Text("Cancel"),
    );
  }

  //Save button ->  Creating New Expense
  Widget _createNewExpenseButton() {
    return MaterialButton(
      onPressed: () async {
        if (nameController.text.isNotEmpty &&
            amountController.text.isNotEmpty) {
          //Pop the box.
          Navigator.pop(context);

          //create new expense.
          Expense newExpense = Expense(
            name: nameController.text,
            amount: convertStringTodouble(amountController.text),
            date: DateTime.now(),
          );

          //Save it to the database.
          await context.read<ExpenseDatabase>().createNewExpense(newExpense);
          
          //refresh graph
          refreshData();

          //Clearing the Controllers after creating a new expense.
          nameController.clear();
          amountController.clear();
        }
      },
      child: const Text("Save"),
    );
  }

  //Save button -> Edit expense button
  Widget _editExpenseButton(Expense expense){
    return MaterialButton(
        onPressed: () async{
          //Save as long as one text field has been changed
          if(nameController.text.isNotEmpty || amountController.text.isNotEmpty)
            {
              //pop box
              Navigator.pop(context);

              //Creating a new updated expense
              Expense updatedExpense = Expense(
                  name: nameController.text.isNotEmpty? nameController.text :expense.name,
                  amount: amountController.text.isNotEmpty? convertStringTodouble(amountController.text) : expense.amount,
                  date: DateTime.now(),
              );

              //Old Expense ID
              int existingId =  expense.id;

              //Save to DB
              await context.read<ExpenseDatabase>().updateExpense(existingId, updatedExpense);

              //refresh graph data
              refreshData();
            }
        },
      child: const Text("Save"),
    );
  }

  //Delete Button
  Widget _deleteExpenseButton(int id) {
    return MaterialButton(
      onPressed: () async {
        // Pop box
        Navigator.pop(context);

        // Delete expense
        await context.read<ExpenseDatabase>().deleteExpense(id); // Pass the ID here

        // Refresh graph data
        refreshData();
      },
      child: Text("Delete"),
    );
  }
}
