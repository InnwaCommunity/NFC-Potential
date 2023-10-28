part of 'listen_nfc_option_bloc.dart';

// sealed class ListenNfcOptionState {}

abstract class ListenNfcOptionState extends Equatable {
  const ListenNfcOptionState();
  @override
  List<Object> get props => [];
}

final class ListenNfcOptionInitial extends ListenNfcOptionState {}

class StartNFCListen extends ListenNfcOptionState{}

class NFCError extends ListenNfcOptionState{}

class ListenLoading extends ListenNfcOptionState{}

class NFCDataLoaded extends ListenNfcOptionState {
  final String result;
  final String handle;
  final String id;
  const NFCDataLoaded({required this.result, required this.handle,required this.id});
  @override
  List<Object> get props => [result, handle];
}
