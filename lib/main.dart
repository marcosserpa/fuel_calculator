import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fuel Consumption Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const InputScreen(),
    );
  }
}

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  Future<void> _calculate() async {
    final prefs = await SharedPreferences.getInstance();
    final String? etanolStr = prefs.getString('etanol');
    final String? gasolineStr = prefs.getString('gasoline');

    if (etanolStr == null || gasolineStr == null || etanolStr.isEmpty || gasolineStr.isEmpty) {
      _showAlert('Please enter Etanol and Gasoline values through the "Consumo" button.');
      return;
    }

    final double etanol = double.tryParse(etanolStr) ?? 0.0;
    final double gasoline = double.tryParse(gasolineStr) ?? 0.0;

    if (etanol == 0.0 || gasoline == 0.0) {
      _showAlert('Etanol and Gasoline values must be greater than 0.');
      return;
    }

    final double result = etanol * gasoline;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(result: result),
      ),
    );
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invalid Input'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showConsumoScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ConsumoScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fuel Consumption Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculate,
              child: const Text('Calculate'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showConsumoScreen,
              child: const Text('Consumo'),
            ),
          ],
        ),
      ),
    );
  }
}

class ConsumoScreen extends StatefulWidget {
  const ConsumoScreen({super.key});

  @override
  _ConsumoScreenState createState() => _ConsumoScreenState();
}

class _ConsumoScreenState extends State<ConsumoScreen> {
  final TextEditingController _etanolController = TextEditingController();
  final TextEditingController _gasolineController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLastValues();
  }

  Future<void> _loadLastValues() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _etanolController.text = prefs.getString('etanol') ?? '';
      _gasolineController.text = prefs.getString('gasoline') ?? '';
    });
  }

  Future<void> _saveValues() async {
    final String etanolStr = _etanolController.text;
    final String gasolineStr = _gasolineController.text;

    if (etanolStr.isEmpty || gasolineStr.isEmpty) {
      _showAlert('Etanol and Gasoline values cannot be empty.');
      return;
    }

    final double etanol = double.tryParse(etanolStr) ?? 0.0;
    final double gasoline = double.tryParse(gasolineStr) ?? 0.0;

    if (etanol == 0.0 || gasoline == 0.0) {
      _showAlert('Etanol and Gasoline values must be greater than 0.');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('etanol', etanolStr);
    await prefs.setString('gasoline', gasolineStr);

    Navigator.pop(context);
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invalid Input'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consumo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _etanolController,
              decoration: const InputDecoration(
                labelText: 'Etanol Consumption',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              controller: _gasolineController,
              decoration: const InputDecoration(
                labelText: 'Gasoline Consumption',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveValues,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final double result;

  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Result: $result'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}