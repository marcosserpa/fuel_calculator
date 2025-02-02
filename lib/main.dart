import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

// Reference calculation:
// 100 km - 23L gasolina | 32L etanol

// gasol: 100/22 = 4.54 km/l
// etanl: 100/32 = 3.12 km/l


// 3.12 / 4.54 = 0.687

// gasolina: 6.43
// etanol: 6.43 * 0.687 (< ou <=)? 4.41

// GAS (13000KM) => 13000/4.54 => 2863.44 L => 2863.44 * 6.43 => 18.411,92
// ETA (13000KM) => 13000/3.12 => 4166.67 L => 4166.67 * 4.41 => 18.375,01


// GAS (1000KM) => 1000/4.54 => 220.26 L => 220.26 * 6.43 => 1.416,27
// ETA (1000KM) => 1000/3.12 => 320.51 L => 320.51 * 4.41 => 1.413,44


// GAS (450KM) => 450/4.54 => 99.12 L => 99.12 * 6.43 => 637.34
// ETA (450KM) => 450/3.12 => 144.23 L => 144.23 * 4.41 => 636.05


// GAS (87KM) => 87/4.54 => 19.16 L => 19.16 * 6.43 => 123.20
// ETA (87KM) => 87/3.12 => 27.88 L => 27.88 * 4.41 => 122.95


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Viabilidade de Combustível',
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
  String? _etanolFormatted;
  String? _gasolineFormatted;
  String? _cheaperFuel;
  String? _ratioFormatted;

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
          _etanolFormatted = formatNumber(etanol);
          _gasolineFormatted = formatNumber(gasoline);
          _cheaperFuel = cheaperFuel;
          _ratioFormatted = formatNumber(ratio);
          _defaultText =
              'Baseado na última vez que você atualizou o consumo com Etanol (${_etanolFormatted}) Km/l e Gasolina (${_gasolineFormatted}) Km/l, é mais vantajoso abastecer com ${_cheaperFuel} se o ${_cheaperFuel} estiver abaixo de R\$ ${_ratioFormatted} o valor do litro.\n\nClique abaixo para calcular informando o custo ${isEtanolCheaper ? 'do Etanol' : 'da Gasolina'}:';
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
      _showAlert('Por favor insira os valores de Etanol e Gasolina através do botão "Consumo".');
      return;
    }

    final double etanol = double.tryParse(etanolStr.replaceAll(',', '.')) ?? 0.0;
    final double gasoline = double.tryParse(gasolineStr.replaceAll(',', '.')) ?? 0.0;

    if (etanol == 0.0 || gasoline == 0.0) {
      _showAlert('Etanol e Gasolina devem ser maiores que 0.');
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
          title: const Text('Valor Inválido'),
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
        title: const Text('Calculadora de Combustível'),
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
                    _formatText(_etanolFormatted!, Colors.red),
                    TextSpan(text: ' Km/l e Gasolina '),
                    _formatText(_gasolineFormatted!, Colors.red),
                    TextSpan(text: ' Km/l, é mais vantajoso abastecer com '),
                    _formatText(_cheaperFuel!, Colors.green),
                    TextSpan(text: ' se o valor do(a) '),
                    _formatText(_cheaperFuel!, Colors.green),
                    TextSpan(text: ' estiver abaixo de R\$ '),
                    _formatText(_ratioFormatted!, Colors.black),
                    TextSpan(text: ' o valor do litro'),
                    TextSpan(text: '.\n\nClique abaixo para calcular informando o custo '),
                    TextSpan(text: _cheaperFuel == 'Etanol' ? 'do Etanol' : 'da Gasolina'),
                    TextSpan(text: ':'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            ElevatedButton(
              onPressed: _calculate,
              child: const Text('Calcular'),
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
      _showAlert('Etanol e Gasolina não podem ser vazios.');
      return;
    }

    final double etanol = double.tryParse(etanolStr.replaceAll(',', '.')) ?? 0.0;
    final double gasoline = double.tryParse(gasolineStr.replaceAll(',', '.')) ?? 0.0;

    if (etanol == 0.0 || gasoline == 0.0) {
      _showAlert('Etanol e Gasolina devem ser maiores que 0.');
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
          title: const Text('Valor Inválido'),
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
                labelText: 'Consumo de Etanol em Km/l',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              controller: _gasolineController,
              decoration: const InputDecoration(
                labelText: 'Consumo de Gasolina em Km/l',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveValues,
              child: const Text('Salvar'),
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

  String get _fuelValueLabel {
    return widget.gasoline > widget.etanol ? 'Valor do Litro da Gasolina' : 'Valor do Litro do Etanol';
  }

  void _calculateCheaper() {
    final String fuelValueStr = _fuelValueController.text;
    if (fuelValueStr.isEmpty) {
      _showAlert('Por favor insira um valor para o combustível.');
      return;
    }

    final double fuelValue = double.tryParse(fuelValueStr.replaceAll(',', '.')) ?? 0.0;
    if (fuelValue == 0.0) {
      _showAlert('O valor do combustível deve ser maior que 0.');
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
          title: const Text('Valor Inválido'),
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
        title: const Text('Comparar Combustíveis'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _fuelValueController,
              decoration: InputDecoration(
                labelText: _fuelValueLabel,
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
        title: const Text('Resultado'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Resultado: ${formatNumber(result)}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Voltar'),
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