final getIt = GetIt.instance;

Future<void> initDependencies() async {
  getIt.registerLazySingleton<AppRouter>(
    () => AppRouter(),
  );

  // Auth dependencies
  // Chat dependencies
  // Notification dependencies
  // Reports dependencies
  // Network dependencies
}