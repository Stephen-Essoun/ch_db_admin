import 'package:ch_db_admin/src/login/data/data_source/remote_s.dart';
import 'package:ch_db_admin/src/login/data/repository/auth_repo_impl.dart';
import 'package:ch_db_admin/src/login/domain/repository/auth_repo.dart';
import 'package:ch_db_admin/src/login/domain/usecase/log_out.dart';
import 'package:ch_db_admin/src/login/domain/usecase/sign_in.dart';
import 'package:ch_db_admin/src/login/presentation/controller/auth_controller.dart';
import 'package:get_it/get_it.dart';

void initAuthDep() {
  locator.registerLazySingleton<LoginRemoteS>(() => LoginRemoteS());
  locator.registerLazySingleton<AuthRepo>(() => AuthRepoImpl(locator.get()));
  locator.registerLazySingleton<SignIn>(() => SignIn(locator.get()));
  locator.registerLazySingleton<SignOut>(() => SignOut(locator.get()));
}

final authController =
    AuthController(signIn: locator.get(), signOut: locator.get());

final locator = GetIt.instance;