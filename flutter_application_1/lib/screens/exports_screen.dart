import 'package:flutter/material.dart';

class ExportsScreen extends StatefulWidget {
  const ExportsScreen({super.key});

  @override
  State<ExportsScreen> createState() => _ExportsScreenState();
}

class _ExportsScreenState extends State<ExportsScreen> {
  bool _isCertificateSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF243047)),
        ),
        title: const Text(
          'Exportações',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF243047),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE5E7EB), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _exportTypeButton(
                      label: 'Badges',
                      selected: !_isCertificateSelected,
                      onTap: () {
                        setState(() {
                          _isCertificateSelected = false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _exportTypeButton(
                      label: 'Certificado',
                      selected: _isCertificateSelected,
                      onTap: () {
                        setState(() {
                          _isCertificateSelected = true;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 64,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE0E6F0),
                        ),
                        color: const Color(0xFFF8FAFC),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, size: 28, color: Colors.grey[400]),
                          const SizedBox(width: 10),
                          Text(
                            'Pesquisar badge',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _toolButton(Icons.filter_alt_outlined),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: const [
                  Expanded(
                    child: Text(
                      'Selecionar Badge',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_left,
                    size: 28,
                    color: Color(0xFF64748B),
                  ),
                  SizedBox(width: 2),
                  Text(
                    '1/3',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1F2937),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right,
                    size: 28,
                    color: Color(0xFF64748B),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _badgeItem(
                iconShape: _BadgeShape.circle,
                color: const Color(0xFFD67F45),
                title: 'LowCode (Outsystems)',
                level: 'Junior',
              ),
              const SizedBox(height: 12),
              _badgeItem(
                iconShape: _BadgeShape.shield,
                color: const Color(0xFFA3AAB5),
                title: 'LowCode (Outsystems)',
                level: 'Intermédio',
              ),
              const SizedBox(height: 12),
              _badgeItem(
                iconShape: _BadgeShape.pentagon,
                color: const Color(0xFFF0C64A),
                title: 'LowCode (Outsystems)',
                level: 'Sénior',
              ),
              const SizedBox(height: 12),
              _badgeItem(
                iconShape: _BadgeShape.hexagon,
                color: const Color(0xFF9B6CF2),
                title: 'LowCode (Outsystems)',
                level: 'Especialista',
                highlighted: true,
              ),
              const SizedBox(height: 12),
              _badgeItem(
                iconShape: _BadgeShape.star,
                color: const Color(0xFF39C65A),
                title: 'LowCode (Outsystems)',
                level: 'Líder de Conhecimento',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toolButton(IconData icon) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E6F0)),
        color: Colors.white,
      ),
      child: Icon(icon, size: 28, color: const Color(0xFF64748B)),
    );
  }

  Widget _exportTypeButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF1A90F0) : const Color(0xFFE2E8F0),
            width: selected ? 2 : 1.5,
          ),
          color: selected ? const Color(0xFFF0F7FF) : Colors.white,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: selected ? const Color(0xFF1A90F0) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _badgeItem({
    required _BadgeShape iconShape,
    required Color color,
    required String title,
    required String level,
    bool highlighted = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFF0F7FF) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: highlighted ? const Color(0xFF1A90F0) : const Color(0xFFE2E8F0),
          width: highlighted ? 2 : 1.5,
        ),
      ),
      child: Row(
        children: [
          _shapeIcon(iconShape, color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  level,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shapeIcon(_BadgeShape shape, Color color) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: shape == _BadgeShape.circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: shape == _BadgeShape.circle ? null : BorderRadius.circular(12),
        border: Border.all(color: color, width: 4),
      ),
      child: Center(
        child: Icon(Icons.workspace_premium, color: color, size: 24),
      ),
    );
  }
}

enum _BadgeShape { circle, shield, pentagon, hexagon, star }
