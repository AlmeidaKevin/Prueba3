class AppConstants {
  //TODO: Reemplazar con tus credenciales de Supabase
  
  static const String supabaseUrl = 'https://jnzjugbzzyzgyuxswdoj.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Impuemp1Z2J6enl6Z3l1eHN3ZG9qIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI1MDA5MzMsImV4cCI6MjA5ODA3NjkzM30.2kRJua6RJGMOIcqaZtce0bxtyTCbIJyypD77Wsxk50A';

  static const String passwordInicial = 'Ecuador2026';

  static const List<String> sectoresQuito = [
    'La Mariscal', 'El Ejido', 'La Floresta', 'Iñaquito',
    'Cotocollao', 'Calderón', 'Quitumbe', 'Solanda',
    'El Condado', 'Guamaní', 'Turubamba', 'La Magdalena',
    'Centro Histórico', 'La Vicentina', 'Chillogallo',
  ];

  static const List<String> vacunas = [
    'Antirrábica',
    'Polivalente (Distemper, Parvovirus, Hepatitis)',
    'Bordetella',
    'Leptospirosis',
    'Rabia + Polivalente',
  ];
}

class AppRoutes {
  static const String login = '/login';
  static const String cambiarPassword = '/cambiar-password';
  static const String recuperarPassword = '/recuperar-password';
  static const String dashboard = '/dashboard';
  static const String sectores = '/sectores';
  static const String crearSector = '/sectores/crear';
  static const String coordinadores = '/coordinadores';
  static const String crearCoordinador = '/coordinadores/crear';
  static const String vacunadores = '/vacunadores';
  static const String crearVacunador = '/vacunadores/crear';
  static const String registrarVacunacion = '/vacunacion/registrar';
  static const String editarVacunacion = '/vacunacion/editar';
  static const String listaVacunaciones = '/vacunaciones';
}

class Roles {
  static const String coordinadorCampania = 'coordinador_campania';
  static const String coordinadorBrigada = 'coordinador_brigada';
  static const String vacunador = 'vacunador';
}
