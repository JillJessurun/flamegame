import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flame_game/bloc/app_bloc.dart';
import 'package:my_flame_game/bloc/bloc_states.dart';
import 'package:my_flame_game/pages/game_page.dart';
import 'package:my_flame_game/pages/menu_page.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => AppBloc())],
      child: BlocBuilder<AppBloc, BlocStates>(
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Munchylax',
            home: state is Game ? const GamePage() : const MenuPage(),
          );
        },
      ),
    );
  }
}
