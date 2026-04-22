import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _nameController = TextEditingController();
  bool _showError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff7f7f7),
      body: Stack(
        children: [
          Opacity(
            opacity: 0.7,
            child: Image.asset(
              'assets/images/background.png',
              scale: 0.5,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'INFORME SEU NOME',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  _buildTextField(),
                  SizedBox(height: 40),
                  _buildButton('Iniciar', () {
                    if (_nameController.text.trim().isEmpty) {
                      setState(() => _showError = true);
                    } else {
                      Navigator.of(
                        context,
                      ).pushReplacementNamed('/game');
                    }
                  }),
                  SizedBox(height: 20),
                  _buildButton('Ranking', () => Navigator.of(context).pushReplacementNamed('/rank')),
                  SizedBox(height: 40,),
                  if (_showError) _buildErrorAlert()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xff333333)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        textAlign: TextAlign.center,
        controller: _nameController,
        decoration: InputDecoration(
          hintText: 'ex: JOGADOR1',
          contentPadding: EdgeInsets.symmetric(vertical: 15),
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (_showError && value.trim().isNotEmpty) {
            setState(() => _showError = false);
          }
        },
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Color(0xff333333),
          backgroundColor: Color(0xffededed),
          side: BorderSide(color: Color(0xff333333), width: 2),
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(12),
          ),
          elevation: 4,
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildErrorAlert() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Color(0xfff7f7f7),
        border: Border.all(color: Color(0xff333333), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, color: Color(0xff333333)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'O NOME DEVE SER PREENCHIDO',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _showError = false),
            icon: Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}
