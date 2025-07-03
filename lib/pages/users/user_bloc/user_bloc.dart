import 'dart:async';
import 'dart:math';
import 'package:flareline/repositories/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flareline/core/models/user_model.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;

  UserBloc({required this.userRepository}) : super(UserInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<AddUser>(_onAddUser);
    on<DeleteUser>(_onDeleteUser);
    on<FilterUsers>(_onFilterUsers);
    on<SearchUsers>(_onSearchUsers);
    on<SortUsers>(_onSortUsers);
    on<GetUserById>(_onGetUserById);
    on<UpdateUser>(_onUpdateUser);
  }

  List<UserModel> _users = [];
  String _searchQuery = '';
  String _roleFilter = "All";
  String? _sortColumn;
  bool _sortAscending = true;
  String _sectorFilter = "All";

  String get sectorFilter => _sectorFilter;
  List<UserModel> get allUsers => _users;
  String get roleFilter => _roleFilter;
  String get searchQuery => _searchQuery;
  String? get sortColumn => _sortColumn;
  bool get sortAscending => _sortAscending;

  Future<void> _onUpdateUser(
    UpdateUser event,
    Emitter<UserState> emit,
  ) async {
    emit(UsersLoading());

    try {
      final updatedUser = await userRepository.updateUser(event.user);

      print('event.user');
      print(event.user);

      final index = _users.indexWhere((u) => u.id == updatedUser.id);
      if (index != -1) {
        _users[index] = updatedUser;
      }

      emit(UserUpdated(updatedUser, passwordChanged: event.passwordChanged));
      emit(UserLoaded(updatedUser));
    } catch (e) {
      emit(UsersError(e.toString()));
    }
  }

  Future<void> _onGetUserById(
    GetUserById event,
    Emitter<UserState> emit,
  ) async {
    emit(UsersLoading());

    try {
      final user = await userRepository.getUserById(event.id);
      emit(UserLoaded(user));
    } catch (e) {
      emit(UsersError(e.toString()));
    }
  }

  Future<void> _onLoadUsers(
    LoadUsers event,
    Emitter<UserState> emit,
  ) async {
    emit(UsersLoading());

    try {
      _users = await userRepository.fetchUsers();
      emit(UsersLoaded(_applyFilters()));
    } catch (e) {
      emit(UsersError(e.toString()));
    }
  }

  Future<void> _onAddUser(
    AddUser event,
    Emitter<UserState> emit,
  ) async {
    emit(UsersLoading());
    try {
      final newUser = UserModel(
          id: 0, // Let server assign ID
          email: event.email,
          name: event.name,
          role: event.role,
          password: event.password,
          sector: event.sector,
          fname: event.fname,
          lname: event.lname,
          barangay: event.barangay,
          photoUrl: event.photoUrl,
          idToken: event.idToken,
          farmerId: event.farmerId);

      await userRepository.addUser(newUser);
      _users = await userRepository.fetchUsers();
      emit(UsersLoaded([..._applyFilters()],
          message: 'User added successfully!'));
    } catch (e) {
      emit(UsersError('Failed to add user: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteUser(
    DeleteUser event,
    Emitter<UserState> emit,
  ) async {
    emit(UsersLoading());
    try {
      await userRepository.deleteUser(event.id);
      _users = _users.where((user) => user.id != event.id).toList();
      emit(UsersLoaded(_applyFilters(), message: 'User deleted successfully!'));
    } catch (e) {
      emit(UsersError('Failed to delete user: ${e.toString()}'));
    }
  }

  Future<void> _onFilterUsers(
      FilterUsers event, Emitter<UserState> emit) async {
    _roleFilter =
        (event.role == null || event.role!.isEmpty) ? "All" : event.role!;
    _sectorFilter =
        (event.sectorId == null) ? "All" : event.sectorId.toString();

    emit(UsersLoaded(_applyFilters()));
  }

  Future<void> _onSearchUsers(
      SearchUsers event, Emitter<UserState> emit) async {
    _searchQuery = event.query.trim().toLowerCase();
    emit(UsersLoaded(_applyFilters()));
  }

  Future<void> _onSortUsers(SortUsers event, Emitter<UserState> emit) async {
    if (_sortColumn == event.columnName) {
      _sortAscending = !_sortAscending;
    } else {
      _sortColumn = event.columnName;
      _sortAscending = true;
    }
    emit(UsersLoaded(_applyFilters()));
  }

  List<UserModel> _applyFilters() {
    List<UserModel> filteredUsers = _users.where((user) {
      // Role filter
      final matchesRole = _roleFilter == "All" ||
          _roleFilter.isEmpty ||
          (user.role != null && user.role == _roleFilter);

      if (!matchesRole) return false;

      // Sector filter
      // final matchesSector = _sectorFilter == "All" ||
      //     _sectorFilter.isEmpty ||
      //     user.sectorId.toString() == _sectorFilter;

      // if (!matchesSector) return false;

      // Search filter
      if (_searchQuery.isEmpty) return true;

      return user.name.toLowerCase().contains(_searchQuery) ||
          user.email.toLowerCase().contains(_searchQuery) ||
          (user.role?.toLowerCase().contains(_searchQuery) ?? false) ||
          (user.fname?.toLowerCase().contains(_searchQuery) ?? false) ||
          (user.lname?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();

    // Sorting
    if (_sortColumn != null) {
      filteredUsers.sort((a, b) {
        int compareResult;
        switch (_sortColumn) {
          case 'Name':
            compareResult = a.name.compareTo(b.name);
            break;
          case 'Email':
            compareResult = a.email.compareTo(b.email);
            break;
          case 'Role':
            compareResult = a.role.compareTo(b.role);
            break;
          default:
            compareResult = 0;
        }
        return _sortAscending ? compareResult : -compareResult;
      });
    }

    return filteredUsers;
  }
}
