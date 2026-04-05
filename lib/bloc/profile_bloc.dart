
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:savewise/data/data_sourcse.dart';




abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

class UpdateUserName extends ProfileEvent {
  final String name;
  const UpdateUserName(this.name);
  @override
  List<Object?> get props => [name];
}

class ToggleDarkMode extends ProfileEvent {
  final bool isDark;
  const ToggleDarkMode(this.isDark);
  @override
  List<Object?> get props => [isDark];
}


class ClearFinancialData extends ProfileEvent {
  const ClearFinancialData();
}


class LogoutAndClearAll extends ProfileEvent {
  const LogoutAndClearAll();
}



enum ProfileStatus { initial, loading, success, failure, cleared, loggedOut }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final String userName;
  final bool isDarkMode;
  final String? message; 

  const ProfileState({
    this.status   = ProfileStatus.initial,
    this.userName = 'My Account',
    this.isDarkMode = false,
    this.message,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    String? userName,
    bool? isDarkMode,
    String? message,
  }) {
    return ProfileState(
      status:     status     ?? this.status,
      userName:   userName   ?? this.userName,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      message:    message,
    );
  }

  @override
  List<Object?> get props => [status, userName, isDarkMode, message];
}



class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final LocalDataSource _dataSource;

  
  LocalDataSource get dataSource => _dataSource;

  ProfileBloc(this._dataSource) : super(const ProfileState()) {
    on<LoadProfile>(_onLoad);
    on<UpdateUserName>(_onUpdateName);
    on<ToggleDarkMode>(_onToggleDark);
    on<ClearFinancialData>(_onClearFinancial);
    on<LogoutAndClearAll>(_onLogout);
  }

  Future<void> _onLoad(LoadProfile event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final name    = await _dataSource.loadUserName();
      final isDark  = await _dataSource.loadDarkMode();
      emit(state.copyWith(
        status:     ProfileStatus.success,
        userName:   name,
        isDarkMode: isDark,
      ));
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.failure, message: e.toString()));
    }
  }

  Future<void> _onUpdateName(
      UpdateUserName event, Emitter<ProfileState> emit) async {
    final trimmed = event.name.trim();
    if (trimmed.isEmpty) return;
    await _dataSource.saveUserName(trimmed);
    emit(state.copyWith(
      status:   ProfileStatus.success,
      userName: trimmed,
      message:  'Name updated',
    ));
  }

  Future<void> _onToggleDark(
      ToggleDarkMode event, Emitter<ProfileState> emit) async {
    await _dataSource.saveDarkMode(event.isDark);
    emit(state.copyWith(isDarkMode: event.isDark));
  }

  Future<void> _onClearFinancial(
      ClearFinancialData event, Emitter<ProfileState> emit) async {
    
    
    
    
    await _dataSource.clearFinancialData();
    emit(state.copyWith(
      status:  ProfileStatus.cleared,
      message: 'All data cleared',
    ));
  }

  Future<void> _onLogout(
      LogoutAndClearAll event, Emitter<ProfileState> emit) async {
    await _dataSource.clearAll();
    emit(state.copyWith(status: ProfileStatus.loggedOut));
  }
}