import 'package:app_rawg/database/repository/review_repository.dart';
import 'package:flutter/material.dart';
import 'package:app_rawg/database/model/review_model.dart';

Future<Review?> showReviewEditingModal(
  BuildContext context, {
  required Map<String, dynamic> game,
  Review? review,
}) async {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.blueGrey.shade900,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => ReviewModalContent(game: game, review: review),
  );
}

class ReviewModalContent extends StatefulWidget {
  final Map<String, dynamic> game;
  final Review? review;

  const ReviewModalContent({super.key, required this.game, this.review});

  @override
  State<ReviewModalContent> createState() => _ReviewModalContentState();
}

class _ReviewModalContentState extends State<ReviewModalContent> {
  final ReviewRepository _repo = ReviewRepository();

  late TextEditingController hoursController;
  late TextEditingController commentController;

  int? selectedPlatformId;
  GameProgress? selectedProgress;
  bool recommends = false;

  int audiovisual = 5;
  int gameplay = 5;
  int immersion = 5;

  String? _errorMsg;

  @override
  void initState() {
    super.initState();

    hoursController = TextEditingController(
      text: widget.review?.hoursPlayed.toString() ?? "0",
    );

    commentController = TextEditingController(
      text: widget.review?.comment ?? "",
    );

    selectedPlatformId = widget.review?.playedPlatform;
    selectedProgress = widget.review?.progressStatus;

    recommends = widget.review?.recommended ?? false;
    audiovisual = widget.review?.scoreVisual ?? 5;
    gameplay = widget.review?.scoreGameplay ?? 5;
    immersion = widget.review?.scoreNarrative ?? 5;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final platforms = widget.game["platforms"] ?? [];

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Avaliação do Jogo",
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            _dropdownInt(
              label: "Plataforma",
              value: selectedPlatformId,
              items: [
                for (var p in platforms)
                  DropdownMenuItem(
                    value: p["platform"]["id"],
                    child: Text(p["platform"]["name"]),
                  ),
              ],
              onChanged: (v) => setState(() => selectedPlatformId = v),
            ),

            _dropdownProgress(
              label: "Status de Progresso",
              value: selectedProgress,
              items: GameProgress.values,
              onChanged: (v) => setState(() => selectedProgress = v),
            ),

            TextField(
              controller: hoursController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Horas jogadas"),
            ),

            const SizedBox(height: 16),

            _scoreSlider(
              "Audiovisual",
              audiovisual,
              (v) => setState(() => audiovisual = v),
            ),
            _scoreSlider(
              "Jogabilidade",
              gameplay,
              (v) => setState(() => gameplay = v),
            ),
            _scoreSlider(
              "Imersão/Narrativa",
              immersion,
              (v) => setState(() => immersion = v),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: commentController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Comentário"),
            ),

            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text(
                "Recomenda?",
                style: TextStyle(color: Colors.white),
              ),
              value: recommends,
              onChanged: (v) => setState(() => recommends = v),
            ),

            const SizedBox(height: 24),

            if (_errorMsg != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: Text(
                    _errorMsg!,
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            Center(
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                ),
                child: Text(widget.review == null ? "Salvar" : "Atualizar"),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _save() async {
    if (selectedPlatformId == null || selectedProgress == null) {
      setState(() {
        _errorMsg = "Selecione plataforma e progresso!";
      });
      return;
    }

    if (double.tryParse(hoursController.text) == null ||
        double.tryParse(hoursController.text)!.isNegative) {
      setState(() {
        _errorMsg = "Entrada de números inválida, utilize apenas números e '.'";
      });
      return;
    }

    final review = Review(
      id: widget.review?.id,
      gameId: widget.game["id"],
      playedPlatform: selectedPlatformId!,
      progressStatus: selectedProgress!,
      hoursPlayed: double.tryParse(hoursController.text) ?? 0,
      recommended: recommends,
      scoreVisual: audiovisual,
      scoreGameplay: gameplay,
      scoreNarrative: immersion,
      comment: commentController.text.trim(),
    );

    if (widget.review == null) {
      await _repo.saveReview(review);
    } else {
      await _repo.updateReview(review);
    }

    if (!mounted) return;
    Navigator.pop(context, review);
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white38),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.amber),
      ),
    );
  }

  Widget _dropdownInt({
    required String label,
    required int? value,
    required List<DropdownMenuItem<int>> items,
    required Function(int?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 6),
        DropdownButtonFormField<int>(
          initialValue: value,
          dropdownColor: Colors.blueGrey.shade800,
          style: const TextStyle(color: Colors.white),
          items: items,
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _dropdownProgress({
    required String label,
    required GameProgress? value,
    required List<GameProgress> items,
    required Function(GameProgress?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 6),
        DropdownButtonFormField<GameProgress>(
          initialValue: value,
          dropdownColor: Colors.blueGrey.shade800,
          style: const TextStyle(color: Colors.white),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e.label)))
              .toList(),
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _scoreSlider(String label, int value, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: $value", style: const TextStyle(color: Colors.white)),
        Slider(
          value: value.toDouble(),
          min: 0,
          max: 10,
          divisions: 10,
          label: value.toString(),
          onChanged: (v) => onChanged(v.toInt()),
        ),
      ],
    );
  }
}
