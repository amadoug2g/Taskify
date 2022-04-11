import 'package:taskify/services/auth/auth_exceptions.dart';
import 'package:taskify/services/auth/auth_provider.dart';
import 'package:taskify/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authentication', (() {
    final provider = MockAuthProvider();

    //Testing _isInitialized variable
    test('Should not be initialized to begin with', (() {
      expect(provider.isInitialized, false);
    }));

    //Testing logOut() function
    test('Should not be able to log out', (() {
      expect(
        provider.logOut(),
        throwsA(
          const TypeMatcher<NotInitializedException>(),
        ),
      );
    }));

    //Testing initialize() function
    test(
      'Should be able to be initialized',
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
    );

    //Testing  function
    test('User should be null after initialization', (() {
      expect(provider.currentUser, null);
    }));

    test(
      'Should be able to initialize in less than 2 seconds',
      (() async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      }),
      timeout: const Timeout(Duration(seconds: 2)),
    );
    test('Create user should delegate to logIn function', () {
      final badEmailUser = provider.createUser(
        email: 'tes@ting.com',
        password: 'badTest',
      );
      expect(
          badEmailUser,
          throwsA(
            const TypeMatcher<UserNotFoundAuthException>(),
          ));
    });
    test('Should not allow a wrong password', () async {
      final badPasswordUser = provider.createUser(
        email: 'bad@email.com',
        password: 'testing',
      );
      expect(
        badPasswordUser,
        throwsA(
          const TypeMatcher<WrongPasswordAuthException>(),
        ),
      );

      final user = await provider.createUser(
        email: 'test',
        password: 'ing',
      );
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test('Logged in user should be able to be verified', () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('Should be able to log out and back in again', () async {
      await provider.logOut();
      await provider.logIn(
        email: 'email',
        password: 'password',
      );
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  }));
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 2));
    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'tes@ting.com') throw UserNotFoundAuthException();
    if (password == 'testing') throw WrongPasswordAuthException();
    // if (_user == null) throw UserDisabledAuthException();
    const user =
        AuthUser(id: 'id', isEmailVerified: false, email: 'tes@ting.com');
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser =
        AuthUser(id: 'id', isEmailVerified: true, email: 'tes@ting.com');
    _user = newUser;
  }
}
