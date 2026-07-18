import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/brut_widgets.dart';

class UnitScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleDark;
  const UnitScreen(
      {super.key, required this.isDark, required this.onToggleDark});
  @override
  State<UnitScreen> createState() => _UnitScreenState();
}

class _UnitScreenState extends State<UnitScreen> {
  int _catIndex = 0;
  int _fromIndex = 0;
  int _toIndex = 1;
  final _input = TextEditingController();

  static const _categories = [
    'Length', 'Weight', 'Temperature', 'Speed', 'Area', 'Volume',
  ];

  // Each unit: (name, factor_to_base)  — base unit is first in list
  // For temperature: factor is not used directly; special handling
  static const _units = <String, List<(String, double)>>{
    'Length': [
      ('Millimeter', 0.001), ('Centimeter', 0.01), ('Meter', 1.0),
      ('Kilometer', 1000.0), ('Inch', 0.0254), ('Foot', 0.3048),
      ('Yard', 0.9144), ('Mile', 1609.344),
    ],
    'Weight': [
      ('Milligram', 0.000001), ('Gram', 0.001), ('Kilogram', 1.0),
      ('Ton', 1000.0), ('Ounce', 0.0283495), ('Pound', 0.453592),
    ],
    'Temperature': [
      ('Celsius', 1.0), ('Fahrenheit', 1.0), ('Kelvin', 1.0),
    ],
    'Speed': [
      ('m/s', 1.0), ('km/h', 0.277778), ('mph', 0.44704), ('Knot', 0.514444),
    ],
    'Area': [
      ('cm²', 0.0001), ('m²', 1.0), ('km²', 1e6),
      ('Acre', 4046.856), ('Hectare', 10000.0), ('ft²', 0.092903),
    ],
    'Volume': [
      ('Milliliter', 0.001), ('Liter', 1.0), ('m³', 1000.0),
      ('Cup', 0.24), ('Pint', 0.473176), ('Gallon', 3.78541),
    ],
  };

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  List<(String, double)> get _currentUnits =>
      _units[_categories[_catIndex]]!;

  String get _result {
    final val = double.tryParse(_input.text);
    if (val == null) return '—';
    final cat = _categories[_catIndex];
    final from = _currentUnits[_fromIndex];
    final to = _currentUnits[_toIndex];

    double converted;
    if (cat == 'Temperature') {
      converted = _convertTemp(val, from.$1, to.$1);
    } else {
      final inBase = val * from.$2;
      converted = inBase / to.$2;
    }

    if (converted.abs() >= 1e9 || (converted.abs() < 0.0001 && converted != 0)) {
      return converted.toStringAsExponential(4);
    }
    if (converted == converted.truncateToDouble()) return converted.toInt().toString();
    return converted.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  double _convertTemp(double v, String from, String to) {
    // to Celsius first
    double celsius;
    switch (from) {
      case 'Fahrenheit': celsius = (v - 32) * 5 / 9;
      case 'Kelvin': celsius = v - 273.15;
      default: celsius = v;
    }
    switch (to) {
      case 'Fahrenheit': return celsius * 9 / 5 + 32;
      case 'Kelvin': return celsius + 273.15;
      default: return celsius;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? AppColors.darkBg : AppColors.lightBg;
    final surface = widget.isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = widget.isDark ? AppColors.cream : AppColors.deepest;
    final borderColor = widget.isDark ? AppColors.dark : AppColors.medium;
    final dimColor = textColor.withAlpha(140);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: surface,
                border: Border(bottom: BorderSide(color: borderColor, width: 3)),
              ),
              child: Row(
                children: [
                  HomeButton(isDark: widget.isDark),
                  const SizedBox(width: 12),
                  Text('UNIT CONVERTER',
                      style: GoogleFonts.spaceMono(
                          color: textColor, fontSize: 16,
                          fontWeight: FontWeight.bold, letterSpacing: 2)),
                ],
              ),
            ),

            // Category chips
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                itemCount: _categories.length,
                itemBuilder: (_, i) {
                  final active = i == _catIndex;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _catIndex = i;
                      _fromIndex = 0;
                      _toIndex = 1;
                    }),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: active
                            ? (widget.isDark ? AppColors.cream : AppColors.deepest)
                            : (widget.isDark ? AppColors.darkSurface : AppColors.lightSurface),
                        border: Border.all(
                            color: widget.isDark ? AppColors.darkShadow : AppColors.lightShadow,
                            width: 2),
                        boxShadow: active
                            ? [BoxShadow(
                                color: widget.isDark ? AppColors.darkShadow : AppColors.lightShadow,
                                offset: const Offset(2, 2), blurRadius: 0)]
                            : [],
                      ),
                      child: Text(_categories[i],
                          style: GoogleFonts.spaceMono(
                              color: active
                                  ? (widget.isDark ? AppColors.deepest : AppColors.cream)
                                  : dimColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // From unit
                    BrutSection(title: 'From', isDark: widget.isDark),
                    const SizedBox(height: 8),
                    _UnitDropdown(
                      units: _currentUnits.map((u) => u.$1).toList(),
                      selected: _fromIndex,
                      isDark: widget.isDark,
                      onChanged: (i) => setState(() => _fromIndex = i),
                    ),
                    const SizedBox(height: 12),
                    BrutField(
                      label: 'Value',
                      controller: _input,
                      isDark: widget.isDark,
                      hint: '1',
                      onChanged: () => setState(() {}),
                    ),

                    // Swap button
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            final tmp = _fromIndex;
                            _fromIndex = _toIndex;
                            _toIndex = tmp;
                          }),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: widget.isDark ? AppColors.darkButton : AppColors.lightButton,
                              border: Border.all(
                                  color: widget.isDark ? AppColors.darkShadow : AppColors.lightShadow,
                                  width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                    color: widget.isDark ? AppColors.darkShadow : AppColors.lightShadow,
                                    offset: const Offset(3, 3), blurRadius: 0)
                              ],
                            ),
                            child: Text('⇅',
                                style: GoogleFonts.spaceMono(
                                    color: AppColors.cream, fontSize: 20)),
                          ),
                        ),
                      ),
                    ),

                    // To unit
                    BrutSection(title: 'To', isDark: widget.isDark),
                    const SizedBox(height: 8),
                    _UnitDropdown(
                      units: _currentUnits.map((u) => u.$1).toList(),
                      selected: _toIndex,
                      isDark: widget.isDark,
                      onChanged: (i) => setState(() => _toIndex = i),
                    ),

                    const SizedBox(height: 20),
                    BrutResult(
                      label: '${_currentUnits[_fromIndex].$1} → ${_currentUnits[_toIndex].$1}',
                      value: _result,
                      isDark: widget.isDark,
                      highlight: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnitDropdown extends StatelessWidget {
  final List<String> units;
  final int selected;
  final bool isDark;
  final void Function(int) onChanged;

  const _UnitDropdown({
    required this.units,
    required this.selected,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkButton : AppColors.lightSurface;
    final textColor = isDark ? AppColors.cream : AppColors.deepest;
    final border = isDark ? AppColors.darkShadow : AppColors.lightShadow;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: 2.5),
        boxShadow: [
          BoxShadow(color: border, offset: const Offset(4, 4), blurRadius: 0)
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButton<int>(
        value: selected,
        isExpanded: true,
        dropdownColor: bg,
        underline: const SizedBox(),
        icon: Icon(Icons.expand_more, color: textColor),
        style: GoogleFonts.spaceMono(
            color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
        items: units
            .asMap()
            .entries
            .map((e) => DropdownMenuItem(
                value: e.key,
                child: Text(e.value,
                    style: GoogleFonts.spaceMono(
                        color: textColor, fontSize: 14))))
            .toList(),
        onChanged: (i) { if (i != null) onChanged(i); },
      ),
    );
  }
}
