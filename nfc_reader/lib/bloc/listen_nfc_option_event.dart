part of 'listen_nfc_option_bloc.dart';

sealed class ListenNfcOptionEvent {}


class RequestPermission extends ListenNfcOptionEvent{}

class ShowNFCData extends ListenNfcOptionEvent{
  final String result;
  final String handle;
  final String id;
  final Uint8List? read;
  ShowNFCData({required this.result,required this.handle,required this.id, this.read});
}
