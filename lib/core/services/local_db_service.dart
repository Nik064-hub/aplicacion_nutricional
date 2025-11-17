// lib/core/services/local_db_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/paciente.dart';
import '../models/nutricionista.dart';
import '../models/plan_alimenticio.dart';
import '../models/dia_plan_alimenticio.dart';
import '../models/comida_planificada.dart';

class LocalDbService {
  late Database _database;

  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'nutriapp.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // PACIENTES
        await db.execute('''
          CREATE TABLE pacientes(
            id INTEGER PRIMARY KEY,
            nombre TEXT,
            correo TEXT UNIQUE,
            contrasenaHash TEXT,
            edad INTEGER,
            pesoInicial REAL,
            altura REAL,
            historialClinico TEXT
          )
        ''');

        // NUTRICIONISTAS
        await db.execute('''
          CREATE TABLE nutricionistas(
            id INTEGER PRIMARY KEY,
            nombre TEXT,
            correo TEXT UNIQUE,
            contrasenaHash TEXT,
            especialidad TEXT,
            cedulaProfesional INTEGER
          )
        ''');

        // PLAN SEMANAL
        await db.execute('''
          CREATE TABLE plan_semana(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            pacienteId INTEGER,
            fechaInicio TEXT,
            fechaFin TEXT
          )
        ''');

        // DIAS DEL PLAN
        await db.execute('''
          CREATE TABLE plan_dias(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            planId INTEGER,
            nombreDia TEXT,
            fecha TEXT,
            totalCalorias REAL
          )
        ''');

        // COMIDAS
        await db.execute('''
          CREATE TABLE plan_comidas(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            diaId INTEGER,
            recetaId INTEGER,
            titulo TEXT,
            tipoComida TEXT,
            readyInMinutes INTEGER,
            porciones INTEGER,
            sourceUrl TEXT,
            imageUrl TEXT,
            calorias REAL
          )
        ''');

        // SEGUIMIENTOS (peso del paciente)
        await db.execute('''
          CREATE TABLE seguimientos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            pacienteId INTEGER,
            fecha TEXT,
            peso REAL,
            notas TEXT
          )
        ''');
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 📌 Registro de Paciente
  // ---------------------------------------------------------------------------
  Future<void> registrarPaciente(Paciente p, String passHash) async {
    await _database.insert('pacientes', {
      'id': p.numUsuario,
      'nombre': p.nombre,
      'correo': p.correo,
      'contrasenaHash': passHash,
      'edad': p.edad,
      'pesoInicial': p.pesoInicial,
      'altura': p.altura,
      'historialClinico': p.historialClinico,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ---------------------------------------------------------------------------
  // 📌 Registro de Nutricionista
  // ---------------------------------------------------------------------------
  Future<void> registrarNutricionista(Nutricionista n, String passHash) async {
    await _database.insert('nutricionistas', {
      'id': n.numUsuario,
      'nombre': n.nombre,
      'correo': n.correo,
      'contrasenaHash': passHash,
      'especialidad': n.especialidad,
      'cedulaProfesional': n.cedulaProfesional,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ---------------------------------------------------------------------------
  // 📌 Login
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>?> login(String correo) async {
    final paciente = await _database.query(
      'pacientes',
      where: 'correo = ?',
      whereArgs: [correo],
    );

    if (paciente.isNotEmpty) {
      return {'tipo': 'paciente', 'data': paciente.first};
    }

    final nutri = await _database.query(
      'nutricionistas',
      where: 'correo = ?',
      whereArgs: [correo],
    );

    if (nutri.isNotEmpty) {
      return {'tipo': 'nutricionista', 'data': nutri.first};
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // 📌 Obtener Paciente por ID
  // ---------------------------------------------------------------------------
  Future<Paciente?> obtenerPacientePorId(int id) async {
    final rows = await _database.query(
      'pacientes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (rows.isEmpty) return null;

    final r = rows.first;

    return Paciente(
      numUsuario: r['id'] as int,
      nombre: r['nombre'] as String,
      correo: r['correo'] as String,
      contrasena: '',
      edad: r['edad'] as int,
      pesoInicial: r['pesoInicial'] as double,
      altura: r['altura'] as double,
      historialClinico: r['historialClinico'] as String,
    );
  }

  // ---------------------------------------------------------------------------
  // 📌 Obtener Nutricionista por ID
  // ---------------------------------------------------------------------------
  Future<Nutricionista?> obtenerNutricionistaPorId(int id) async {
    final rows = await _database.query(
      'nutricionistas',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (rows.isEmpty) return null;

    final r = rows.first;

    return Nutricionista(
      numUsuario: r['id'] as int,
      nombre: r['nombre'] as String,
      correo: r['correo'] as String,
      contrasena: '',
      especialidad: r['especialidad'] as String,
      cedulaProfesional: r['cedulaProfesional'] as int,
    );
  }

  // ---------------------------------------------------------------------------
  // 📌 Obtener todos los pacientes
  // ---------------------------------------------------------------------------
  Future<List<Paciente>> obtenerTodosLosPacientes() async {
    final rows = await _database.query('pacientes');

    return rows
        .map(
          (r) => Paciente(
            numUsuario: r['id'] as int,
            nombre: r['nombre'] as String,
            correo: r['correo'] as String,
            contrasena: '',
            edad: r['edad'] as int,
            pesoInicial: r['pesoInicial'] as double,
            altura: r['altura'] as double,
            historialClinico: r['historialClinico'] as String,
          ),
        )
        .toList();
  }

  // ---------------------------------------------------------------------------
  // 📌 Guardar seguimiento (peso)
  // ---------------------------------------------------------------------------
  Future<void> guardarSeguimiento(
    int pacienteId,
    double peso,
    String notas,
  ) async {
    await _database.insert('seguimientos', {
      'pacienteId': pacienteId,
      'fecha': DateTime.now().toIso8601String(),
      'peso': peso,
      'notas': notas,
    });
  }

  // ---------------------------------------------------------------------------
  // 📌 Obtener seguimientos del paciente
  // ---------------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> obtenerSeguimientos(int pacienteId) async {
    return await _database.query(
      'seguimientos',
      where: 'pacienteId = ?',
      whereArgs: [pacienteId],
      orderBy: 'fecha DESC',
    );
  }

  // ---------------------------------------------------------------------------
  // 📌 Guardar Plan Semanal COMPLETO
  // ---------------------------------------------------------------------------
  Future<void> guardarPlanSemanal(int pacienteId, PlanAlimenticio plan) async {
    final db = _database;

    await db.transaction((txn) async {
      final planId = await txn.insert('plan_semana', {
        'pacienteId': pacienteId,
        'fechaInicio': plan.fechaInicio.toIso8601String(),
        'fechaFin': plan.fechaFin.toIso8601String(),
      });

      for (final dia in plan.dias) {
        final diaId = await txn.insert('plan_dias', {
          'planId': planId,
          'nombreDia': dia.nombreDia,
          'fecha': dia.fecha.toIso8601String(),
          'totalCalorias': dia.totalCalorias,
        });

        for (final comida in dia.comidas) {
          await txn.insert('plan_comidas', {
            'diaId': diaId,
            'recetaId': comida.recetaId,
            'titulo': comida.titulo,
            'tipoComida': comida.tipoComida,
            'readyInMinutes': comida.readyInMinutes,
            'porciones': comida.porciones,
            'sourceUrl': comida.sourceUrl,
            'imageUrl': comida.imageUrl,
            'calorias': comida.calorias,
          });
        }
      }
    });
  }

  // ---------------------------------------------------------------------------
  // 📌 Obtener Plan Semanal del Paciente
  // ---------------------------------------------------------------------------
  Future<PlanAlimenticio?> obtenerPlanSemanal(int pacienteId) async {
    final planRows = await _database.query(
      'plan_semana',
      where: 'pacienteId = ?',
      whereArgs: [pacienteId],
      orderBy: 'id DESC',
      limit: 1,
    );

    if (planRows.isEmpty) return null;

    final planId = planRows.first['id'] as int;
    final fechaInicio = DateTime.parse(planRows.first['fechaInicio']);
    final fechaFin = DateTime.parse(planRows.first['fechaFin']);

    final diasRows = await _database.query(
      'plan_dias',
      where: 'planId = ?',
      whereArgs: [planId],
    );

    final List<DiaPlanAlimenticio> dias = [];

    for (final d in diasRows) {
      final diaId = d['id'] as int;

      final comidasRows = await _database.query(
        'plan_comidas',
        where: 'diaId = ?',
        whereArgs: [diaId],
      );

      final comidas = comidasRows
          .map(
            (c) => ComidaPlanificada(
              recetaId: c['recetaId'],
              titulo: c['titulo'],
              tipoComida: c['tipoComida'],
              readyInMinutes: c['readyInMinutes'],
              porciones: c['porciones'],
              sourceUrl: c['sourceUrl'],
              imageUrl: c['imageUrl'],
              calorias: c['calorias'],
            ),
          )
          .toList();

      dias.add(
        DiaPlanAlimenticio(
          nombreDia: d['nombreDia'],
          fecha: DateTime.parse(d['fecha']),
          totalCalorias: d['totalCalorias'],
          comidas: comidas,
        ),
      );
    }

    return PlanAlimenticio(
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      dias: dias,
    );
  }

  // ---------------------------------------------------------------------------
  // 📌 Reemplazar plan semanal (para edición)
  // ---------------------------------------------------------------------------
  Future<void> reemplazarPlanSemanal(
    int pacienteId,
    PlanAlimenticio plan,
  ) async {
    final db = _database;

    await db.transaction((txn) async {
      final oldPlans = await txn.query(
        'plan_semana',
        where: 'pacienteId = ?',
        whereArgs: [pacienteId],
      );

      for (final p in oldPlans) {
        final pId = p['id'] as int;

        final diasRows = await txn.query(
          'plan_dias',
          where: 'planId = ?',
          whereArgs: [pId],
        );

        for (final d in diasRows) {
          final dId = d['id'] as int;
          await txn.delete(
            'plan_comidas',
            where: 'diaId = ?',
            whereArgs: [dId],
          );
        }

        await txn.delete('plan_dias', where: 'planId = ?', whereArgs: [pId]);

        await txn.delete('plan_semana', where: 'id = ?', whereArgs: [pId]);
      }

      await guardarPlanSemanal(pacienteId, plan);
    });
  }
}
