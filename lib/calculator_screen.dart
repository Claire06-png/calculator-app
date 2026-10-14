/*
SUMMARY OF ISSUES

I'll break this down into the following categories:

❌ Functional bugs / Logic issues

🛑 Potential runtime exceptions

⚠️ Code clarity / readability

🧹 Best practices

📱 UI/UX Concerns

1. ❌ FUNCTIONAL BUGS / LOGIC ISSUES
🔴 clearAll() logic is incorrect
number1="0";
operand="0";


Setting operand = "0" is wrong — operand should be an operator like +, -, ×, etc., or an empty string.

Fix:

number1 = "";
operand = "";
number2 = "";

🔴 appendValue() logic is flawed

Your current logic can lead to incorrect assignments of values. For example:

The check:

else if(number2.isEmpty || operand.isNotEmpty){


This can cause number2 to be updated even when operand is empty, leading to malformed inputs.

Also, the check for the value == Btn.del is misplaced inside appendValue(), although onBtnTap() already handles it before calling appendValue().

🛠️ Fix:

Refactor the conditionals in appendValue() for better separation of concerns.

Ensure you only append to number2 if operand.isNotEmpty.

🔴 appendValue() — Conflicts for decimal point (.)
if(value == Btn.dot && number1.contains(Btn.dot)) return;


This condition is duplicated for number2 but should be inside the relevant block (either for number1 or number2 only).

Also, the logic can be cleaner and more predictable.

🔴 No input validation before double.parse()

In calculate() and convertToPercentage():

final double num1=double.parse(number1);


⚠️ If number1 or number2 contain invalid input (e.g. multiple dots, empty, or partial values), the app will crash.

🛠️ Fix:

Wrap with try-catch or use double.tryParse()

final num1 = double.tryParse(number1);
if (num1 == null) return; // Or show error

2. 🛑 POTENTIAL RUNTIME EXCEPTIONS
⚠️ Manual substring may cause crash
number2=number2.substring(0, number2.length-1);


⚠️ If length is 0, this will crash.

🛠️ Use:

if (number2.isNotEmpty) {
  number2 = number2.substring(0, number2.length - 1);
}


(You already handle this, just a reminder for future additions.)

⚠️ throw ArgumentError(...)

In UI code, using throw is dangerous because unhandled exceptions can crash the app.

throw ArgumentError("Cannot divide by zero");


🛠️ Instead, show a Snackbar, dialog, or display the error inline.

3. ⚠️ CODE CLARITY / READABILITY
🔶 Hardcoded constants

This is hard to read:

width:value==Btn.n0 ? screenSize.width /2 :(screenSize.width/4)


✅ Use a named constant or helper method for clarity:

double getButtonWidth(String value) {
  return value == Btn.n0 ? screenSize.width / 2 : screenSize.width / 4;
}

🔶 Unclear separation of logic

Your appendValue() method is doing too much — try separating:

Operand handling

Number appending

Decimal handling

4. 🧹 BEST PRACTICES
⚠️ Using .toString() with Text widget

You use this:

"$number1$operand$number2".isEmpty ? "0" : "$number1$operand$number2"


Better:

final displayText = "$number1$operand$number2";
Text(displayText.isEmpty ? "0" : displayText)

✅ Use const where possible

Avoid unnecessary rebuilds:

Text(...)
// => If it's not dynamic, use:
const Text("0")

5. 📱 UI/UX CONCERNS
🔶 Wrap layout for buttons is good but can overflow

Depending on device size, your Wrap layout may wrap poorly or overflow.

🛠️ Consider using GridView.count for better control:

GridView.count(
  crossAxisCount: 4,
  children: Btn.buttonValues.map(...).toList(),
)

🔶 Consider showing error messages

Currently, if a user tries to divide by 0 or enter invalid values, nothing is shown — or worse, the app crashes.

🛠️ Show feedback like:

ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text("Cannot divide by zero"))
);

✅ BONUS: TYPOS & NAMING

botton_values.dart → should be button_values.dart

buildButton(value) → add type: Widget buildButton(String value)

var result = 0.0; → better as double result = 0.0;

✅ FINAL VERDICT
🔥 Your calculator works mostly, but has the following critical issues:
Type	Count
Functional Bugs	✅ 4
Runtime Risks	✅ 3
Best Practice Warnings	✅ 5+
UI/UX Improvements	✅ 3
✅ RECOMMENDATIONS

Fix the bugs in clearAll() and appendValue()

Avoid using throw in UI

Use double.tryParse() for safe parsing

Refactor large methods like appendValue() for clarity

Provide error feedback to the user

Add unit tests (if possible) for calculate() and input validation
 */

import 'package:flutter/material.dart';
import 'package:my_calculator_app2/button_values.dart'; // make sure this file is spelled correctly

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String number1 = "";
  String operand = "";
  String number2 = "";

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Output section
            Expanded(
              child: SingleChildScrollView(
                reverse: true,
                child: Container(
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "$number1$operand$number2".isEmpty ? "0" : "$number1$operand$number2",
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
            ),

            // Buttons section using GridView for better responsiveness
            SizedBox(
              height: screenSize.height * 0.6, // Allocate height for buttons
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(), // Prevent scrolling inside buttons
                crossAxisCount: 4,
                childAspectRatio: 1,
                padding: const EdgeInsets.all(8),
                children: Btn.buttonValues.map((value) {
                  return buildButton(value);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
  /*
  string destinationZone =  xyz, ABC, PQR;
  if (destinationZone==)
   */

  // ####################### Build Button
  Widget buildButton(String value) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        color: getBtnColor(value),
        clipBehavior: Clip.hardEdge,
        shape: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(100),
        ),
        child: InkWell(
          onTap: () => onBtnTap(value),
          child: Center(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ####################### Button Tap Handler
  void onBtnTap(String value) {
    if (value == Btn.del) {
      delete();
      return;
    }

    if (value == Btn.clr) {
      clearAll();
      return;
    }

    if (value == Btn.per) {
      convertToPercentage();
      return;
    }

    if (value == Btn.calculate) {
      calculate();
      return;
    }

    appendValue(value);
  }

  // ####################### Calculate Result
  void calculate() {
    if (number1.isEmpty || operand.isEmpty || number2.isEmpty) return;

    final num1 = double.tryParse(number1);
    final num2 = double.tryParse(number2);

    if (num1 == null || num2 == null) {
      return; // prevent crash due to invalid number format
    }

    double result = 0.0;

    switch (operand) {
      case Btn.add:
        result = num1 + num2;
        break;
      case Btn.subtract:
        result = num1 - num2;
        break;
      case Btn.multiply:
        result = num1 * num2;
        break;
      case Btn.divide:
        if (num2 == 0) {
          // Don't throw error, show warning in UI
          showSnackBar("Cannot divide by zero");
          return;
        }
        result = num1 / num2;
        break;
      default:
        showSnackBar("Invalid operation");
        return;
    }

    if (result.isInfinite || result.isNaN) {
      showSnackBar("Invalid result");
      return;
    }

    setState(() {
      number1 = "$result";

      if (number1.endsWith(".0")) {
        number1 = number1.substring(0, number1.length - 2); // Remove unnecessary .0
      }

      operand = "";
      number2 = "";
    });
  }

  // ####################### Convert to Percentage
  void convertToPercentage() {
    if (number1.isNotEmpty && operand.isNotEmpty && number2.isNotEmpty) {
      calculate();
    }

    if (operand.isNotEmpty) return;

    final num = double.tryParse(number1);
    if (num == null) return;

    setState(() {
      number1 = "${num / 100}";
      operand = "";
      number2 = "";
    });
  }

  // ####################### Clear All
  void clearAll() {
    setState(() {
      number1 = "";
      operand = "";
      number2 = "";
    });
  }

  // ####################### Delete Last Input
  void delete() {
    setState(() {
      if (number2.isNotEmpty) {
        number2 = number2.substring(0, number2.length - 1);
      } else if (operand.isNotEmpty) {
        operand = "";
      } else if (number1.isNotEmpty) {
        number1 = number1.substring(0, number1.length - 1);
      }
    });
  }

  // ####################### Append Value
  void appendValue(String value) {
    setState(() {
      if (value != Btn.dot && int.tryParse(value) == null) {
        // Operand
        if (operand.isNotEmpty && number2.isNotEmpty) {
          calculate();
        }
        operand = value;
      } else if (operand.isEmpty) {
        // Number 1
        if (value == Btn.dot && number1.contains(Btn.dot)) return;
        if (value == Btn.dot && (number1.isEmpty || number1 == Btn.n0)) {
          value = "0.";
        }
        number1 += value;
      } else {
        // Number 2
        if (value == Btn.dot && number2.contains(Btn.dot)) return;
        if (value == Btn.dot && (number2.isEmpty || number2 == Btn.n0)) {
          value = "0.";
        }
        number2 += value;
      }
    });
  }

  // ####################### Show SnackBar for Errors
  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ####################### Get Button Color
  Color getBtnColor(String value) {
    return [Btn.del, Btn.clr].contains(value)
        ? Colors.blueGrey
        : [Btn.per, Btn.multiply, Btn.add, Btn.subtract, Btn.divide, Btn.calculate].contains(value)
            ? Colors.orange
            : Colors.black87;
  }
}
