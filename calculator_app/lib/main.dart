
import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator State Lab',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String currentOperand = '0';
  double? accumulator;
  String? pendingOperator;
  bool awaitingOperand = false;
  bool justEvaluated = false;
  String? errorMessage;

  void enterDigit(String digit) {
    setState(() {
      errorMessage = null;

      if (justEvaluated) {
        currentOperand = digit;
        accumulator = null;
        pendingOperator = null;
        awaitingOperand = false;
        justEvaluated = false;
        return;
      }

      if (awaitingOperand) {
        currentOperand = digit;
        awaitingOperand = false;
        return;
      }

      if (currentOperand == '0') {
        currentOperand = digit;
      } else {
        currentOperand += digit;
      }
    });
  }

  double parseOperand() {
    return double.parse(currentOperand);
  }

  String formatNumber(double value) {
    if (value.isFinite && value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  double calculate(double left, String op, double right) {
    switch (op) {
      case '+':
        return left + right;
      case '-':
        return left - right;
      case '*':
        return left * right;
      case '/':
        if (right == 0) {
          throw const FormatException(
            'Cannot divide by zero.',
          );
        }
        return left / right;
      default:
        return right;
    }
  }

  void chooseOperator(String op) {
    setState(() {
      errorMessage = null;

      if (justEvaluated) {
        accumulator = parseOperand();
        justEvaluated = false;
      } else if (awaitingOperand) {
        // Replace the pending operator if no new digit was entered.
        pendingOperator = op;
        return;
      } else if (pendingOperator != null &&
          accumulator != null) {
        try {
          accumulator = calculate(
            accumulator!,
            pendingOperator!,
            parseOperand(),
          );
          currentOperand = formatNumber(accumulator!);
        } on FormatException catch (e) {
          errorMessage = e.message;
          return;
        }
      } else {
        accumulator = parseOperand();
      }

      pendingOperator = op;
      currentOperand = formatNumber(accumulator!);
      awaitingOperand = true;
    });
  }

  void calculateResult() {
    setState(() {
      // Ignore equals when no new operand has been entered.
      if (pendingOperator == null || awaitingOperand) {
        return;
      }

      try {
        final result = calculate(
          accumulator!,
          pendingOperator!,
          parseOperand(),
        );

        currentOperand = formatNumber(result);
        accumulator = null;
        pendingOperator = null;
        awaitingOperand = false;
        justEvaluated = true;
        errorMessage = null;
      } on FormatException catch (e) {
        errorMessage = e.message;
        accumulator = null;
        pendingOperator = null;
        awaitingOperand = false;
        justEvaluated = true;
      }
    });
  }

  void clearAll() {
    setState(() {
      currentOperand = '0';
      accumulator = null;
      pendingOperator = null;
      awaitingOperand = false;
      justEvaluated = false;
      errorMessage = null;
    });
  }

  void toggleSign() {
    setState(() {
      errorMessage = null;

      if (justEvaluated) {
        justEvaluated = false;
      }

      if (awaitingOperand) {
        currentOperand = '0';
        awaitingOperand = false;
      }

      final value = parseOperand();
      currentOperand = formatNumber(-value);
    });
  }

  Widget calculatorButton(
    String label, {
    required VoidCallback onPressed,
    Color? color,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: SizedBox.expand(
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keys = <String>[
      'AC', '±', '÷', '×',
      '7', '8', '9', '−',
      '4', '5', '6', '+',
      '1', '2', '3', '=',
      '0', '00', '←', ' ',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator State Lab'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        errorMessage ??
                            (pendingOperator == null
                                ? 'Ready'
                                : 'Running total: '
                                    '${formatNumber(accumulator ?? 0)} '
                                    '$pendingOperator'),
                        style: TextStyle(
                          fontSize: 14,
                          color: errorMessage == null
                              ? Colors.grey
                              : Colors.red,
                        ),
                        textAlign: TextAlign.end,
                      ),
                      const SizedBox(height: 12),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          currentOperand,
                          key: const ValueKey('calculatorDisplay'),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                flex: 5,
                child: GridView.count(
                  crossAxisCount: 4,
                  childAspectRatio: 1.05,
                  physics: const NeverScrollableScrollPhysics(),
                  children: keys.map((key) {
                    if (key == ' ') {
                      return const SizedBox.shrink();
                    }

                    final isOperator =
                        ['÷', '×', '−', '+', '='].contains(key);
                    final isSpecial =
                        ['AC', '±', '←'].contains(key);

                    return calculatorButton(
                      key,
                      color: isOperator
                          ? Colors.indigo
                          : isSpecial
                              ? Colors.blueGrey
                              : null,
                      textColor:
                          isOperator || isSpecial
                              ? Colors.white
                              : null,
                      onPressed: () {
                        switch (key) {
                          case 'AC':
                            clearAll();
                          case '±':
                            toggleSign();
                          case '←':
                            setState(() {
                              if (currentOperand.length > 1) {
                                currentOperand =
                                    currentOperand.substring(
                                  0,
                                  currentOperand.length - 1,
                                );
                              } else {
                                currentOperand = '0';
                              }
                              errorMessage = null;
                            });
                          case '÷':
                            chooseOperator('/');
                          case '×':
                            chooseOperator('*');
                          case '−':
                            chooseOperator('-');
                          case '+':
                            chooseOperator('+');
                          case '=':
                            calculateResult();
                          default:
                            enterDigit(key);
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
