class Config {
  static const apiUrl = String.fromEnvironment('API_URL');
  static const kioscoApiKey = String.fromEnvironment('KIOSCO_API_KEY');

  // Turnos prioritarios: oculto por decisión de la empresa
  static const turnosPrioritarios = false;
}