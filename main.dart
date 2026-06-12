import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const AppCalculator());
}

class AppCalculator extends StatelessWidget {
  const AppCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Calculator());
  }
}

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String expression = "0";
  String result = "0";

  // Operators para saber si el último carácter es un operador
  static const operators = {'+', '-', 'x', '/'};

  void buttonPressed(String value) {
    setState(() {
      switch (value) {
        case 'AC':
          _clearAll();
          break;
        case 'C':
          _deleteLast();
          break;
        case '=':
          _evaluate();
          break;
        default:
          _appendValue(value);
      }
    });
  }

  void _clearAll() {
    expression = "0";
    result = "0";
  }

  void _deleteLast() {
    if (expression.length <= 1) {
      expression = "0";
    } else {
      expression = expression.substring(0, expression.length - 1);
      // Si quedó vacío o solo operador al inicio, resetea
      if (expression.isEmpty) expression = "0";
    }
  }

  void _appendValue(String value) {
    // Normalizar: si la expresión es "0" y no es decimal ni operador, reemplazar
    if (expression == "0" && value != '.' && !operators.contains(value)) {
      // Permitir "-" para número negativo
      if (value == '-') {
        expression = "-";
        return;
      }
      expression = value;
      return;
    }

    // No permitir múltiples puntos decimales en el mismo número
    if (value == '.') {
      // Buscar el último número en la expresión
      final lastNumber = _getLastNumber();
      if (lastNumber.contains('.')) return; // ya tiene punto
    }

    // No permitir operador si ya hay operador al final (excepto "-" para negativo)
    if (operators.contains(value)) {
      if (expression.isEmpty) {
        if (value == '-') {
          expression = "-";
          return;
        }
        return;
      }
      final lastChar = expression[expression.length - 1];
      // Permitir "-" después de operador para números negativos
      if (operators.contains(lastChar)) {
        if (value == '-' && lastChar != '-') {
          expression += value;
          return;
        }
        // Reemplazar operador si es otro operador
        if (value != '-') {
          expression = expression.substring(0, expression.length - 1) + value;
          return;
        }
        return; // evitar "--"
      }
    }

    // No permitir punto si la expresión está vacía o termina en operador
    if (value == '.') {
      if (expression.isEmpty) {
        expression = "0.";
        return;
      }
      final lastChar = expression[expression.length - 1];
      if (operators.contains(lastChar)) {
        expression += "0.";
        return;
      }
    }

    expression += value;
  }

  String _getLastNumber() {
    // Separar por operadores para obtener el último segmento numérico
    final parts = expression.split(RegExp(r'(?<=[0-9)])[+x/]|(?<=[0-9)]) -'));
    return parts.isNotEmpty ? parts.last : '';
  }

  void _evaluate() {
    try {
      // Reemplazar 'x' por '*' para math_expressions
      String expr = expression.replaceAll('x', '*');

      // Eliminar operador colgante al final
      while (expr.isNotEmpty && operators.map((o) => o == 'x' ? '*' : o).contains(expr[expr.length - 1])) {
        expr = expr.substring(0, expr.length - 1);
      }
      // Limpiar operadores colgantes con el set original
      while (expr.isNotEmpty && (expr.endsWith('+') || expr.endsWith('-') || expr.endsWith('*') || expr.endsWith('/'))) {
        expr = expr.substring(0, expr.length - 1);
      }

      if (expr.isEmpty || expr == '-') {
        result = "Error";
        return;
      }

      Parser parser = Parser();
      Expression parsedExpr = parser.parse(expr);
      ContextModel cm = ContextModel();
      double evalResult = parsedExpr.evaluate(EvaluationType.REAL, cm);

      // Verificar casos especiales
      if (evalResult.isNaN || evalResult.isInfinite) {
        result = evalResult.isInfinite ? "Cannot divide by 0" : "Error";
        return;
      }

      // Evitar overflow / números absurdamente grandes
      if (evalResult.abs() > 1e15) {
        result = "Number too large";
        return;
      }

      // Mostrar como entero si no tiene decimales significativos
      if (evalResult == evalResult.truncateToDouble()) {
        result = evalResult.toInt().toString();
      } else {
        // Limitar a 10 decimales y quitar ceros trailing
        result = evalResult.toStringAsFixed(10).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
      }
    } catch (e) {
      result = "Error";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Calculator'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Display de expresión
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                expression,
                textAlign: TextAlign.right,
                style: const TextStyle(color: Colors.white70, fontSize: 28),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Display de resultado
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                result,
                textAlign: TextAlign.right,
                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Divider(color: Colors.grey),
            Expanded(
              child: Row(
                children: [
                  buildButton('7'),
                  buildButton('8'),
                  buildButton('9'),
                  buildButton('C', color: Colors.orange),
                  buildButton('AC', color: Colors.red),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  buildButton('4'),
                  buildButton('5'),
                  buildButton('6'),
                  buildButton('+', color: Colors.blue),
                  buildButton('-', color: Colors.blue),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  buildButton('1'),
                  buildButton('2'),
                  buildButton('3'),
                  buildButton('x', color: Colors.blue),
                  buildButton('/', color: Colors.blue),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  buildButton('0'),
                  buildButton('.'),
                  buildButton('00'),
                  buildButton('=', color: Colors.green),
                  buildButton(' '), // placeholder vacío
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButton(String label, {Color? color}) {
    return Expanded(
      child: SizedBox(
        height: 80,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            minimumSize: Size.zero,
          ),
          onPressed: label.trim().isEmpty ? null : () => buttonPressed(label),
          child: Text(label, style: const TextStyle(fontSize: 20)),
        ),
      ),
    );
  }
}