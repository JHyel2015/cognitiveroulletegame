import 'package:cognitiveroulletegame/constans.dart';
import 'package:cognitiveroulletegame/pages/auth_page.dart';
import 'package:cognitiveroulletegame/services/speaker_service.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();
  final SpeakerService speakerService = SpeakerService();

  final List<String> _bodies = [
    '¡Hola! Estamos emocionados de tenerte con nosotros. En Cognitive Game, te embarcarás en un emocionante viaje para mejorar tus habilidades cognitivas mientras exploras el fascinante mundo de los colores.',
    'Nuestra aplicación ofrece una variedad de juegos diseñados para enseñarte los colores de manera divertida, hay mucho por descubrir.',
    'La aplicación realiza un seguimiento de tu progreso a medida que avanzas en los juegos.',
    'Personaliza tu experiencia de juego ajustando la configuración según tus preferencias.',
  ];

  Future<void> _speak(String textToSpeak) async {
    await speakerService.speak(textToSpeak);
  }

  @override
  void initState() {
    super.initState();
    _speak(_bodies[0]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      // pageColor: theme.backgroundColor,
      imagePadding: EdgeInsets.zero,
    );

    List<PageViewModel> onBoardingList = [
      PageViewModel(
        title: 'Bienvenido',
        body: _bodies[0],
        image: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                Image.asset('assets/splash.gif', height: 150, width: 150),
                const SizedBox(height: 20),
                const Text(
                  'Cognitive Game',
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
        decoration: pageDecoration,
      ),
      PageViewModel(
        title: 'Explora los Niveles',
        body: _bodies[1],
        image: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset('assets/onboarding_1_explore.gif'),
          ),
        ),
        decoration: pageDecoration,
      ),
      PageViewModel(
        title: 'Seguimiento de Progreso',
        body: _bodies[2],
        image: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset('assets/onboarding_2_progress.gif'),
          ),
        ),
        decoration: pageDecoration,
      ),
      PageViewModel(
        title: 'Configuración Personalizada',
        body: _bodies[3],
        image: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset('assets/onboarding_3_customize.gif'),
          ),
        ),
        decoration: pageDecoration,
      ),
    ];

    return Container(
      color: kColorSecondary,
      child: SafeArea(
        child: Center(
          child: IntroductionScreen(
            key: introKey,
            pages: onBoardingList,
            onDone: () {
              speakerService.stop();
              _onIntroEnd(context);
            },
            onChange: (page) {
              speakerService.stop();
              speakerService.speak(_bodies[page]);
            },
            showSkipButton: true,
            skip: const Text('Saltar'),
            next: const Icon(Icons.arrow_forward_ios),
            done: const Text('Hecho'),
            dotsDecorator: DotsDecorator(
              size: const Size(10.0, 10.0),
              // color: theme.primaryColor,
              activeSize: const Size(22.0, 10.0),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              activeColor: theme.primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  _onIntroEnd(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AuthPage(),
      ),
    );
  }
}
