import 'package:flutter/material.dart';

class CertificationInput extends StatefulWidget {
  final List<String> certifications;
  final ValueChanged<List<String>> onChanged;

  const CertificationInput({
    super.key,
    required this.certifications,
    required this.onChanged,
  });

  @override
  State<CertificationInput> createState() => _CertificationInputState();
}

class _CertificationInputState extends State<CertificationInput> {
  final _controller = TextEditingController();

  void _addCertification() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !widget.certifications.contains(text)) {
      widget.onChanged([...widget.certifications, text]);
      _controller.clear();
    }
  }

  void _removeCertification(String certification) {
    widget.onChanged(
      widget.certifications.where((c) => c != certification).toList(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Гэрчилгээ, сертификат',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Таны мэргэжлийн гэрчилгээнүүдийг нэмнэ үү',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Жишээ: NASM CPT, ACE Certified',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _addCertification(),
              ),
            ),
            const SizedBox(width: 12),
            IconButton.filled(
              onPressed: _addCertification,
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFF72928),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.certifications.map((cert) {
            return Chip(
              label: Text(cert),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () => _removeCertification(cert),
              backgroundColor: Colors.grey[100],
              deleteIconColor: Colors.grey[600],
              labelStyle: TextStyle(color: Colors.grey[800]),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
