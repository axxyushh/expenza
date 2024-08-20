import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


double convertStringTodouble(String string)
{
  double? amount = double.tryParse(string);

  return amount ?? 0;
}

//Double Rupees Amount format
String formatAmount(double amount){

  //Change the format to rupee
  final format = NumberFormat.currency(
      locale: "en_US",
      symbol: "₹ ",
      decimalDigits: 2,
  );

  return format.format(amount);
}

//Calculate the number of month since the first start month.
int calculateMonthCount(int startYear, startMonth, currentYear, currentMonth){
  int monthCount = (currentYear - startYear) * 12 + currentMonth - startMonth +1;
  return monthCount;

}

//Get current month name
 String getCurrentMonthName(){
  DateTime now = DateTime.now();
  List<String> months = [
    "JAN",
    "FEB",
    "MAR",
    "APR",
    "MAY",
    "JUN",
    "JUL",
    "AUG",
    "SEP",
    "OCT",
    "NOV",
    "DEC",
  ];
  return months[now.month - 1];
 }