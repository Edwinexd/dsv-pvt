import 'package:flutter/foundation.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:health/health.dart';

Future<bool> configureHealth(List<HealthDataType> types) async {
  try {
    Health().configure(useHealthConnectIfAvailable: true);
    // Checking against false and not falsy intentionally as null and false are handled differently
    if (await Health().hasPermissions(types) == false) {
      bool requested = await Health().requestAuthorization(types);
      return requested;
    }
    return true;
  } catch (e) {
    // Unsupported Device
    return false;
  }
}

Future<int> getSteps(DateTime startDate, DateTime endDate) async {
  if (!await configureHealth([HealthDataType.STEPS])) {
    return 0;
  }
  int? steps = await Health().getTotalStepsInInterval(startDate, endDate);
  return steps ?? 0;
}

Future<int> getMaxHeartrate(DateTime startDate, DateTime endDate) async {
  if (!await configureHealth([HealthDataType.HEART_RATE])) {
    return 0;
  }
  List<HealthDataPoint> heartrateData = await Health().getHealthDataFromTypes(
      types: [HealthDataType.HEART_RATE],
      startTime: startDate,
      endTime: endDate);
  if (heartrateData.isNotEmpty) {
    // type sasting that it is of NumericHealthValue type
    return heartrateData
        .map((e) => (e.value as NumericHealthValue).numericValue.round())
        .reduce((value, element) => value > element ? value : element);
  }
  return 0;
}

Future<int> getWaterLiters(DateTime startDate, DateTime endDate) async {
  if (!await configureHealth([HealthDataType.WATER])) {
    return 0;
  }
  List<HealthDataPoint> waterData = await Health().getHealthDataFromTypes(
      types: [HealthDataType.WATER], startTime: startDate, endTime: endDate);
  if (waterData.isNotEmpty) {
    return waterData
        .map((e) => (e.value as NumericHealthValue).numericValue.round())
        .reduce((value, element) => value + element);
  }
  return 0;
}

Future<int> getHeadacheTotal(DateTime startDate, DateTime endDate) async {
  if (!await configureHealth([HealthDataType.HEADACHE_MILD, HealthDataType.HEADACHE_MODERATE, HealthDataType.HEADACHE_SEVERE])) {
    return 0;
  }
  List<HealthDataPoint> headacheData = await Health().getHealthDataFromTypes(
      types: [HealthDataType.HEADACHE_MILD, HealthDataType.HEADACHE_MODERATE, HealthDataType.HEADACHE_SEVERE],
      startTime: startDate,
      endTime: endDate);
  if (headacheData.isNotEmpty) {
    return headacheData
        .map((e) => (e.value as NumericHealthValue).numericValue.round())
        .reduce((value, element) => value + element);
  }
  return 0;
}

Future<int> getSleep(DateTime startDate, DateTime endDate) async {
  if (!await configureHealth([HealthDataType.SLEEP_IN_BED, HealthDataType.SLEEP_ASLEEP, HealthDataType.SLEEP_AWAKE, HealthDataType.SLEEP_DEEP, HealthDataType.SLEEP_LIGHT, HealthDataType.SLEEP_REM, HealthDataType.SLEEP_OUT_OF_BED])) {
    return 0;
  }
  List<HealthDataPoint> sleepData = await Health().getHealthDataFromTypes(
      types: [HealthDataType.SLEEP_IN_BED, HealthDataType.SLEEP_ASLEEP, HealthDataType.SLEEP_AWAKE, HealthDataType.SLEEP_DEEP, HealthDataType.SLEEP_LIGHT, HealthDataType.SLEEP_REM, HealthDataType.SLEEP_OUT_OF_BED],
      startTime: startDate,
      endTime: endDate);
  if (sleepData.isNotEmpty) {
    return sleepData
        .map((e) => (e.value as NumericHealthValue).numericValue.round())
        .reduce((value, element) => value + element);
  }
  return 0;
}

Future<List<Map<String, dynamic>>> getLast30DaysData() async {
  List<Map<String, dynamic>> data = [];
  DateTime now = DateTime.now();

  for (int i = 0; i < 30; i++) {
    DateTime startDate = now.subtract(Duration(days: i + 1));
    DateTime endDate = now.subtract(Duration(days: i));

    int steps = await getSteps(startDate, endDate);
    int maxHeartrate = await getMaxHeartrate(startDate, endDate);
    int waterLiters = await getWaterLiters(startDate, endDate);
    int headacheTotal = await getHeadacheTotal(startDate, endDate);
    int sleep = await getSleep(startDate, endDate);

    data.add({
      'date': startDate.toIso8601String(),
      'steps': steps,
      'maxHeartrate': maxHeartrate,
      'waterLiters': waterLiters,
      'headacheTotal': headacheTotal,
      'sleep': sleep,
    });
  }

  return data;
}


/// Collects the health data for the last 30 days and sends it to the backend
/// Note: This is extremely against GDPR and is only for demonstration purposes within the scope of this course
Future<void> collectAndSendData() async {
  if (kIsWeb || kIsWasm) {
    return; // For some reason the health plugin doesn't even throw an catchable error on web...
  }
  try {
    List<Map<String, dynamic>> data = await getLast30DaysData();
    await BackendService().uploadHealthData(data).then((value) => null).catchError((e) => null);
  } catch (e) {
    print(e);
  }
}
