class Config {
  static const apiUrl = String.fromEnvironment('API_URL');
  static const kioscoApiKey = String.fromEnvironment('KIOSCO_API_KEY');

  static const turnosPrioritarios = false;
  static const imprimirTicket = true;

  static const vistaPreviaTicket = true;
  static const ticketTablaCodigos = 19;
  static const ticketSinAcentos = false;

  static const ticketLogo = true;
  static const logoTicketAsset = 'assets/images/icono_app.png';
  static const logoTicketAnchoPuntos = 160;
  static const anchoPapelPuntos = 576;
}