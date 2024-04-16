import 'package:flutter/material.dart';
import 'package:habit_tracker_app/models/app_settings.dart';
import 'package:habit_tracker_app/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabse extends ChangeNotifier {
  static late Isar isar;

  /*

  S E T U P 

  */

  // I N I T I A L I Z E
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [HabitSchema, AppSettingSchema],
      directory: dir.path,
    );
  }

  //  save first date of app startup (for heatmapp)
  Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();
    if (existingSettings == null) {
      final settings = AppSetting()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(
        () => isar.appSettings.put(settings),
      );
    }
  }

  // get first date of app startup (foe heatmap)
  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }

  /*

  C R U D X O P E R A T I O N S

  */

  // LIST OF HABITS
  final List<Habit> currentHabits = [];

  // C R E A T E - add a new habit
  Future<void> addHabit(String habitName) async {
    // create a new habit
    final newHabit = Habit()..name = habitName;

    // save to db
    await isar.writeTxn(() => isar.habits.put(newHabit));

    // re-read from database
    readHabits();
  }

  // R E A D - read saved habits from db
  Future<void> readHabits() async {
    // fetch all habit ffrom database
    List<Habit> fetchedHabits = await isar.habits.where().findAll();

    // give to current habits
    currentHabits.clear();
    currentHabits.addAll(fetchedHabits);

    // update UI
    notifyListeners();
  }

  // U P D A T E - check habit on add off
  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    // find the specific habits
    final habit = await isar.habits.get(id);

    // update completion status
    if (habit != null) {
      await isar.writeTxn(
        () async {
          // if habit is completed-> add the current date to the completed dayslist
          if (isCompleted && !habit.completedDays.contains(DateTime.now())) {
            // today
            final today = DateTime.now();

            // if habit is not completed -> remove the current date from the list
            habit.completedDays.add(
              DateTime(
                today.year,
                today.month,
                today.day,
              ),
            );
          } else {
            // remove the current date if the habit is marked as not completed
            habit.completedDays.removeWhere(
              (date) =>
                  date.year == DateTime.now().year &&
                  date.month == DateTime.now().month &&
                  date.day == DateTime.now().day,
            );
          }
          // save the updated habits back to the db
          await isar.habits.put(habit);
        },
      );
    }

    // re-read from db
    readHabits();
  }

  // U P D A T E - edit habit name
  Future<void> updateHabitName(int id, String newName) async {
    // find the specific habit
    final habit = await isar.habits.get(id);

    // update habit name
    if (habit != null) {
      // update name
      await isar.writeTxn(
        () async {
          // save updated habit back to the db
          await isar.habits.put(habit);
        },
      );
    }
    // re-read from db
    readHabits();
  }

  // D E L E T E - delete habit
  Future<void> deleteHabit(int id) async {
    // perform the delete
    await isar.writeTxn(
      () async {
        await isar.habits.delete(id);
      },
    );
    // re-read habits
    readHabits();
  }
}
