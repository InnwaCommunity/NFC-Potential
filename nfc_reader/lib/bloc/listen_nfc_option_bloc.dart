
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nfc_manager/nfc_manager.dart';

part 'listen_nfc_option_event.dart';
part 'listen_nfc_option_state.dart';

class ListenNfcOptionBloc extends Bloc<ListenNfcOptionEvent, ListenNfcOptionState> {
  ListenNfcOptionBloc() : super(ListenNfcOptionInitial()) {
    on<ListenNfcOptionEvent>((event, emit) {});
    on<RequestPermission>((event, emit) async{
      emit(ListenLoading());
      // Check availability
      bool isAvailable = await NfcManager.instance.isAvailable();
      if (isAvailable) {
        emit(StartNFCListen());
      } else {
        emit(NFCError());
      }
    },);
    on<ShowNFCData>((event, emit) {
       
      emit(ListenLoading());
      //  try {
      //   Uint8List? read=event.read;
      //    String decoded = utf8.decode(read!); 
      //   //  Uint8List.fromList(event.read);
      //  log('decoded: $decoded');
      //  }on Exception catch (e) {
      //    log(e.toString());
      //  }
      emit(NFCDataLoaded(result: event.result,handle: event.handle,id:event.id));
    },);
  }
}
