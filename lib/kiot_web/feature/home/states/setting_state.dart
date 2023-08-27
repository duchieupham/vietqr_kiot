import 'package:equatable/equatable.dart';

class SettingState extends Equatable {
  const SettingState();

  @override
  List<Object?> get props => [];
}

class SettingInitialState extends SettingState {}

class SettingLoadingState extends SettingState {}

class SettingGetTokenPlusSuccessState extends SettingState {
  final String tokenPlus;

  const SettingGetTokenPlusSuccessState({required this.tokenPlus});

  @override
  List<Object?> get props => [tokenPlus];
}

class SettingGetTokenPlusFailedState extends SettingState {}
