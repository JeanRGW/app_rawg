import 'package:app_rawg/database/model/review_model.dart';
import 'package:app_rawg/database/repository/review_repository.dart';
import 'package:app_rawg/view/components/review_editing_modal.dart';
import 'package:flutter/material.dart';

class ReviewWidget extends StatefulWidget {
  final Map<String, dynamic> game;
  const ReviewWidget({super.key, required this.game});

  @override
  State<ReviewWidget> createState() => _ReviewWidgetState();
}

class _ReviewWidgetState extends State<ReviewWidget> {
  final ReviewRepository _repo = ReviewRepository();
  Review? review;

  @override
  void initState() {
    super.initState();

    loadReview();
  }

  void loadReview() async {
    Review? review = await _repo.getReviewByGameId(widget.game["id"]);

    setState(() {
      this.review = review;
    });
  }

  @override
  Widget build(BuildContext context) {
    Review? review = this.review;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              "Avaliação",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (review == null)
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.rate_review, color: Colors.black),
                label: Text("Avaliar", style: TextStyle(color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  foregroundColor: Colors.black,
                  elevation: 4,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final changed = await showReviewEditingModal(
                    context,
                    game: widget.game,
                  );
                  if (changed != null) {
                    setState(() {
                      this.review = changed;
                    });
                  }
                },
              ),
            )
          else
            Card(
              color: Colors.blueGrey[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.videogame_asset,
                          color: Colors.amber,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getPlatformName(review.playedPlatform) ??
                              "Plataforma desconhecida",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Spacer(),
                        Chip(
                          label: Text(
                            review.progressStatus.label,
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.blueGrey[900],
                        ),
                      ],
                    ),
                    const Divider(
                      color: Colors.white54,
                      height: 20,
                      thickness: 1,
                    ),
                    Wrap(
                      spacing: 18,
                      runSpacing: 6,
                      children: [
                        _scoreChip(
                          "Horas",
                          review.hoursPlayed.toStringAsFixed(1),
                          Icons.schedule,
                        ),
                        _scoreChip(
                          "Audiovisual",
                          "${review.scoreVisual}/10",
                          Icons.palette,
                        ),
                        _scoreChip(
                          "Jogabilidade",
                          "${review.scoreGameplay}/10",
                          Icons.gamepad,
                        ),
                        _scoreChip(
                          "Imersão",
                          "${review.scoreNarrative}/10",
                          Icons.psychology,
                        ),
                        _scoreChip(
                          "Recomenda",
                          review.recommended ? "Sim" : "Não",
                          Icons.thumb_up_alt,
                        ),
                      ],
                    ),
                    if (review.comment?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 12),
                      Text(
                        "\"${review.comment!}\"",
                        style: TextStyle(
                          color: Colors.amber[100],
                          fontStyle: FontStyle.italic,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(Icons.edit, color: Colors.white),
                          label: Text("Editar"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () async {
                            final changed = await showReviewEditingModal(
                              context,
                              game: widget.game,
                              review: review,
                            );
                            if (changed != null) {
                              setState(() {
                                this.review = changed;
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          icon: Icon(Icons.delete, color: Colors.white),
                          label: Text("Excluir"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent[700],
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: Colors.blueGrey[900],
                                title: Text(
                                  "Confirmar exclusão",
                                  style: TextStyle(color: Colors.white),
                                ),
                                content: Text(
                                  "Tem certeza que deseja excluir sua avaliação?",
                                  style: TextStyle(color: Colors.white),
                                ),
                                actions: [
                                  TextButton(
                                    child: Text(
                                      "Cancelar",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () => Navigator.pop(ctx, false),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent[700],
                                    ),
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: Text(
                                      "Excluir",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              await _repo.deleteReview(review.id!);

                              if (!mounted) return;

                              setState(() {
                                this.review = null;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Avaliação excluída.")),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _scoreChip(String label, String value, IconData icon) {
    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 18),
      label: Text("$label: $value", style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.blueGrey[900],
      padding: EdgeInsets.symmetric(horizontal: 8),
    );
  }

  String? _getPlatformName(int platformId) {
    final platforms = widget.game["platforms"] as List? ?? [];
    final match = platforms.firstWhere(
      (p) => p["platform"]["id"] == platformId,
      orElse: () => null,
    );
    return match != null ? match["platform"]["name"] as String : null;
  }
}
