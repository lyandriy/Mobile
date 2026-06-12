// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MaterialApp(home: CalculatorScreen()));
// }

// class CalculatorScreen extends StatefulWidget {
//   const CalculatorScreen({super.key});

//   @override
//   State<CalculatorScreen> createState() => _CalculatorScreenState();
// }

// class _CalculatorScreenState extends State<CalculatorScreen> {
//   String _expression = '0';
//   String _result = '0';

//   void _onButtonPressed(String label) {
//     debugPrint('Button pressed: $label');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Column(
//           children: [

//             // --- DISPLAY ---
//             TextField(
//               readOnly: true,
//               textAlign: TextAlign.right,
//               decoration: InputDecoration(
//                 hintText: _expression,
//                 hintStyle: const TextStyle(color: Colors.white54, fontSize: 24),
//                 border: InputBorder.none,
//               ),
//             ),
//             TextField(
//               readOnly: true,
//               textAlign: TextAlign.right,
//               decoration: InputDecoration(
//                 hintText: _result,
//                 hintStyle: const TextStyle(color: Colors.white, fontSize: 40),
//                 border: InputBorder.none,
//               ),
//             ),

//             // --- FILA 1 ---
//             Row(
//               children: [
//                 _buildButton('AC', Colors.grey),
//                 _buildButton('C', Colors.grey),
//                 _buildButton('/', Colors.orange),
//                 _buildButton('*', Colors.orange),
//               ],
//             ),

//             // --- FILA 2 ---
//             Row(
//               children: [
//                 _buildButton('7', Colors.grey),
//                 _buildButton('8', Colors.grey),
//                 _buildButton('9', Colors.grey),
//                 _buildButton('-', Colors.orange),
//               ],
//             ),

//             // --- FILA 3 ---
//             Row(
//               children: [
//                 _buildButton('4', Colors.grey),
//                 _buildButton('5', Colors.grey),
//                 _buildButton('6', Colors.grey),
//                 _buildButton('+', Colors.orange),
//               ],
//             ),

//             // --- FILA 4 ---
//             Row(
//               children: [
//                 _buildButton('1', Colors.grey),
//                 _buildButton('2', Colors.grey),
//                 _buildButton('3', Colors.grey),
//                 _buildButton('=', Colors.green),
//               ],
//             ),

//             // --- FILA 5 ---
//             Row(
//               children: [
//                 _buildButton('0', Colors.grey),
//                 _buildButton('.', Colors.grey),
//               ],
//             ),

//           ],
//         ),
//       ),
//     );
//   }

//   // Funcion que crea un boton
//   Widget _buildButton(String label, Color color) {
//     return Expanded(
//       child: Padding(
//         padding: const EdgeInsets.all(4),
//         child: ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: color,
//             foregroundColor: Colors.white,
//           ),
//           onPressed: () => _onButtonPressed(label),
//           child: Text(label, style: const TextStyle(fontSize: 28)),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: CalculatorScreen()));
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = '0';
  String _result = '0';

  void _onButtonPressed(String label) {
    debugPrint('Button pressed: $label');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF546E7A),
      appBar: AppBar(
        title: const Text('Calculator'),
        backgroundColor: const Color(0xFF455A64),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [

          // --- DISPLAY ---
          Container(
            color: const Color(0xFF37474F),
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextField(
                  readOnly: true,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: _expression,
                    hintStyle: const TextStyle(color: Colors.white54, fontSize: 20),
                    border: InputBorder.none,
                  ),
                ),
                TextField(
                  readOnly: true,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: _result,
                    hintStyle: const TextStyle(color: Colors.white, fontSize: 32),
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),

          // --- BOTONES ---
          Expanded(
            child: Column(
              children: [

                // FILA 1
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('7'),
                      _buildButton('8'),
                      _buildButton('9'),
                      _buildButton('AC', color: Colors.red[300]!),
                    ],
                  ),
                ),

                // FILA 2
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('4'),
                      _buildButton('5'),
                      _buildButton('6'),
                      _buildButton('+', color: const Color(0xFF455A64)),
                    ],
                  ),
                ),

                // FILA 3
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('1'),
                      _buildButton('2'),
                      _buildButton('3'),
                      _buildButton('-', color: const Color(0xFF455A64)),
                    ],
                  ),
                ),

                // FILA 4
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('0'),
                      _buildButton('.'),
                      _buildButton('=', color: const Color(0xFF455A64)),
                      _buildButton('*', color: const Color(0xFF455A64)),
                    ],
                  ),
                ),

                // FILA 5
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('C', color: Colors.red[200]!),
                      _buildButton(''),
                      _buildButton(''),
                      _buildButton('/', color: const Color(0xFF455A64)),
                    ],
                  ),
                ),

              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildButton(String label, {Color color = const Color(0xFF607D8B)}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: label.isEmpty ? null : () => _onButtonPressed(label),
          child: Text(label, style: const TextStyle(fontSize: 24)),
        ),
      ),
    );
  }
}