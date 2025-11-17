import 'package:flutter/material.dart';
import 'core/services/local_db_service.dart';
import 'core/services/session_manager.dart';
import 'core/services/notification_service.dart';
import 'core/services/spoonacular_api.dart';
import 'core/services/plan_alimenticio_service.dart';
import 'core/services/pdf_plan_service.dart';

import 'features/auth/login_screen.dart';
import 'features/auth/root_screen.dart';
import 'features/auth/signup_selector_screen.dart';
import 'features/auth/signup_paciente_screen.dart';
import 'features/auth/signup_nutricionista_screen.dart';

import 'features/nutrition/home_screen.dart';
import 'features/nutrition/weekly_plan_screen.dart';
import 'features/nutrition/patient_progress_screen.dart';
import 'features/nutrition/nutritionist_dashboard_screen.dart';
import 'features/nutrition/edit_weekly_plan_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = LocalDbService();
  await db.init();

  final sessionManager = SessionManager();
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    NutriApp(
      db: db,
      sessionManager: sessionManager,
      notificationService: notificationService,
    ),
  );
}

class NutriApp extends StatelessWidget {
  final LocalDbService db;
  final SessionManager sessionManager;
  final NotificationService notificationService;

  NutriApp({
    super.key,
    required this.db,
    required this.sessionManager,
    required this.notificationService,
  });

  final SpoonacularApi api = SpoonacularApi("// aqui va la apikei");
  final PdfPlanService pdfService = PdfPlanService();

  @override
  Widget build(BuildContext context) {
    final planService = PlanAlimenticioService(api: api);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NutriApp',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      routes: {
        '/': (context) => RootScreen(sessionManager: sessionManager, db: db),

        '/login': (context) =>
            LoginScreen(db: db, sessionManager: sessionManager),

        '/signupSelector': (context) => const SignUpSelectorScreen(),
        '/signupPaciente': (context) => SignUpPacienteScreen(db: db),
        '/signupNutricionista': (context) => SignUpNutricionistaScreen(db: db),

        '/home': (context) {
          final id = ModalRoute.of(context)!.settings.arguments as int;
          return FutureBuilder(
            future: db.obtenerPacientePorId(id),
            builder: (_, snap) {
              if (!snap.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return HomeScreen(
                paciente: snap.data!,
                planService: planService,
                db: db,
              );
            },
          );
        },

        '/weeklyPlan': (context) {
          final id = ModalRoute.of(context)!.settings.arguments as int;
          return FutureBuilder(
            future: db.obtenerPacientePorId(id),
            builder: (_, snap) {
              if (!snap.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return WeeklyPlanScreen(
                paciente: snap.data!,
                planService: planService,
                db: db,
                notificationService: notificationService,
                pdfService: pdfService,
              );
            },
          );
        },

        '/patientProgress': (context) {
          final id = ModalRoute.of(context)!.settings.arguments as int;
          return FutureBuilder(
            future: db.obtenerPacientePorId(id),
            builder: (_, snap) {
              if (!snap.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return PatientProgressScreen(paciente: snap.data!, db: db);
            },
          );
        },

        '/nutriDashboard': (context) {
          final id = ModalRoute.of(context)!.settings.arguments as int;
          return FutureBuilder(
            future: Future.wait([
              db.obtenerNutricionistaPorId(id),
              db.obtenerTodosLosPacientes(),
            ]),
            builder: (_, snap) {
              if (!snap.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return NutritionistDashboardScreen(
                nutricionista: snap.data![0],
                pacientes: snap.data![1],
                db: db,
              );
            },
          );
        },
      },
    );
  }
}
