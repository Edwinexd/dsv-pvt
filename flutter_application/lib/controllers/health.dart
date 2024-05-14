
import 'package:health/health.dart';

Future<int> getSteps() async {
  // configure the health plugin before use.
  Health().configure(useHealthConnectIfAvailable: true);
  
  // define the types to get
  var types = [
    HealthDataType.STEPS,
  ];

  // requesting access to the data types before reading them
  bool requested = await Health().requestAuthorization(types);

  if (!requested) {
    return 0;
  }

  int? steps = await Health().getTotalStepsInInterval(
    DateTime.now().subtract(const Duration(days: 1)),
    DateTime.now(),
  );

  return steps ?? 0;
}
