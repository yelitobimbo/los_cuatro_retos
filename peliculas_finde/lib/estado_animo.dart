/// Cada estado de ánimo se relaciona con un género de TMDB.
enum EstadoAnimo {
  feliz('😄', 'Feliz', 35), // Comedia
  aventurero('🤠', 'Aventurero', 28), // Acción
  romantico('😍', 'Romántico', 10749), // Romance
  miedo('😱', 'Con ganas de miedo', 27), // Terror
  pensativo('🤔', 'Pensativo', 18); // Drama

  final String emoji;
  final String texto;
  final int generoId;
  const EstadoAnimo(this.emoji, this.texto, this.generoId);
}
