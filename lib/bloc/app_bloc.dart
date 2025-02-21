import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flame_game/bloc/bloc_events.dart';
import 'package:my_flame_game/bloc/bloc_states.dart';

class AppBloc extends Bloc<BlocEvent, BlocStates> {
  AppBloc() : super(Menu()) {
    on<GoToMenu>((event, emit) => emit(Menu()));
    on<GoToGame>((event, emit) => emit(Game()));
  }
}
