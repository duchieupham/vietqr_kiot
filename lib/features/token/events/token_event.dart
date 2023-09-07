import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class TokenEvent extends Equatable {
  const TokenEvent();

  @override
  List<Object?> get props => [];
}

class TokenEventCheckValid extends TokenEvent {
  const TokenEventCheckValid();

  @override
  List<Object?> get props => [];
}

class TokenFcmUpdateEvent extends TokenEvent {
  const TokenFcmUpdateEvent();

  @override
  List<Object?> get props => [];
}

class GetListQrEvent extends TokenEvent {}

class UploadImageEvent extends TokenEvent {
  final Map<String, dynamic> param;
  final Uint8List? imageByte;
  const UploadImageEvent(this.param, this.imageByte);

  @override
  List<Object?> get props => [param, imageByte];
}
