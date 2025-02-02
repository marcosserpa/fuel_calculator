import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

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
  String? _defaultText;
  String? _resultText;

  @override
  void initState() {
    super.initState();
    _loadDefaultText();
  }

  Future<void> _loadDefaultText() async {
    final prefs = await SharedPreferences.getInstance();
    final String? etanolStr = prefs.getString('etanol');
    final String? gasolineStr = prefs.getString('gasoline');

    if (etanolStr != null && gasolineStr != null && etanolStr.isNotEmpty && gasolineStr.isNotEmpty) {
      final double etanol = double.tryParse(etanolStr.replaceAll(',', '.')) ?? 0.0;
      final double gasoline = double.tryParse(gasolineStr.replaceAll(',', '.')) ?? 0.0;

      if (etanol > 0.0 && gasoline > 0.0) {
        final bool isEtanolCheaper = etanol < gasoline;
        final double ratio = isEtanolCheaper ? etanol / gasoline : gasoline / etanol;
        final String cheaperFuel = isEtanolCheaper ? 'Etanol' : 'Gasolina';

        setState(() {
          _defaultText =
              'Baseado na última vez que você atualizou o consumo com Etanol (${_formatText(formatNumber(etanol), Colors.red)}) e Gasolina (${_formatText(formatNumber(gasoline), Colors.red)}), é mais vantajoso abastecer com ${_formatText(cheaperFuel, Colors.green)} se o ${_formatText(cheaperFuel, Colors.green)} estiver abaixo de R\$ ${formatNumber(ratio)}.\n\nClique abaixo para calcular baseado no custo ${isEtanolCheaper ? 'do Etanol' : 'da Gasolina'}:';
        });
      }
    }
  }

  String formatNumber(double number) {
    return number.toStringAsFixed(2).replaceAll('.', ',');
  }

  TextSpan _formatText(String text, Color color) {
    return TextSpan(
      text: text,
      style: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }

  Future<void> _calculate() async {
    final prefs = await SharedPreferences.getInstance();
    final String? etanolStr = prefs.getString('etanol');
    final String? gasolineStr = prefs.getString('gasoline');

    if (etanolStr == null || gasolineStr == null || etanolStr.isEmpty || gasolineStr.isEmpty) {
      _showAlert('Please enter Etanol and Gasoline values through the "Consumo" button.');
      return;
    }

    final double etanol = double.tryParse(etanolStr.replaceAll(',', '.')) ?? 0.0;
    final double gasoline = double.tryParse(gasolineStr.replaceAll(',', '.')) ?? 0.0;

    if (etanol == 0.0 || gasoline == 0.0) {
      _showAlert('Etanol and Gasoline values must be greater than 0.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalculateScreen(etanol: etanol, gasoline: gasoline),
      ),
    ).then((resultText) {
      if (resultText != null) {
        setState(() {
          _resultText = resultText;
          _defaultText = null; // Clear the default text
        });
      }
    });
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
    ).then((_) {
      _loadDefaultText(); // Reload the default text after returning from ConsumoScreen
    });
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
            if (_resultText != null) ...[
              Text(
                _resultText!,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
            ] else if (_defaultText != null) ...[
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    TextSpan(text: 'Baseado na última vez que você atualizou o consumo com Etanol '),
                    _formatText('etanol', Colors.red),
                    TextSpan(text: ' e Gasolina '),
                    _formatText('gasolina', Colors.red),
                    TextSpan(text: ', é mais vantajoso abastecer com '),
                    _formatText('cheaperFuel', Colors.green),
                    TextSpan(text: ' se o '),
                    _formatText('cheaperFuel', Colors.green),
                    TextSpan(text: ' estiver abaixo de R\$ '),
                    _formatText('ratio', Colors.black),
                    TextSpan(text: '.\n\nClique abaixo para calcular baseado no custo '),
                    TextSpan(text: 'isEtanolCheaper ? "do Etanol" : "da Gasolina"'),
                    TextSpan(text: ':'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
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
  final MoneyMaskedTextController _etanolController = MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '');
  final MoneyMaskedTextController _gasolineController = MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '');

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

    final double etanol = double.tryParse(etanolStr.replaceAll(',', '.')) ?? 0.0;
    final double gasoline = double.tryParse(gasolineStr.replaceAll(',', '.')) ?? 0.0;

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

class CalculateScreen extends StatefulWidget {
  final double etanol;
  final double gasoline;

  const CalculateScreen({super.key, required this.etanol, required this.gasoline});

  @override
  _CalculateScreenState createState() => _CalculateScreenState();
}

class _CalculateScreenState extends State<CalculateScreen> {
  final MoneyMaskedTextController _fuelValueController = MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '');

  void _calculateCheaper() {
    final String fuelValueStr = _fuelValueController.text;
    if (fuelValueStr.isEmpty) {
      _showAlert('Please enter a fuel value.');
      return;
    }

    final double fuelValue = double.tryParse(fuelValueStr.replaceAll(',', '.')) ?? 0.0;
    if (fuelValue == 0.0) {
      _showAlert('Fuel value must be greater than 0.');
      return;
    }

    final bool isEtanolCheaper = widget.etanol < widget.gasoline;
    final double ratio = isEtanolCheaper ? widget.etanol / widget.gasoline : widget.gasoline / widget.etanol;
    final double result = (ratio * fuelValue) + 0.01;

    final String cheaperFuel = isEtanolCheaper ? 'Etanol' : 'Gasolina';
    final String resultText = '$cheaperFuel sai mais em conta se custar menos que R\$ ${formatNumber(result)}';

    Navigator.pop(context, resultText);
  }

  String formatNumber(double number) {
    return number.toStringAsFixed(2).replaceAll('.', ',');
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
        title: const Text('Calculate Cheaper Fuel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _fuelValueController,
              decoration: const InputDecoration(
                labelText: 'Fuel Value',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateCheaper,
              child: const Text('Calcular Mais Barato'),
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
            Text('Result: ${formatNumber(result)}'),
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

  String formatNumber(double number) {
    return number.toStringAsFixed(2).replaceAll('.', ',');
  }
}