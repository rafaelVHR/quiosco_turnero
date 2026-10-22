class Config {
  static const apiUrl = String.fromEnvironment('API_URL');
  static const kioscoApiKey = String.fromEnvironment('KIOSCO_API_KEY');

  static const turnosPrioritarios = false;
  static const imprimirTicket = false;

  static const vistaPreviaTicket = true;
  static const ticketTablaCodigos = 19;
  static const ticketSinAcentos = false;
}