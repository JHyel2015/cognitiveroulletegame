import 'package:cognitiveroulletegame/constans.dart';
import 'package:cognitiveroulletegame/pages/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({Key? key}) : super(key: key);

  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var _pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      // pageColor: theme.backgroundColor,
      imagePadding: EdgeInsets.zero,
    );

    List<PageViewModel> _onBoardingList = [
      PageViewModel(
        title: 'Bienvenido',
        body:
            '¡Hola! Estamos emocionados de tenerte con nosotros. En Cognitive Game, te embarcarás en un emocionante viaje para mejorar tus habilidades cognitivas mientras exploras el fascinante mundo de los colores.',
        image: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              children: [
                Image.asset('assets/splash.gif', height: 200, width: 200),
                const SizedBox(height: 25),
                Text(
                  'Cognitive Game',
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
        decoration: _pageDecoration,
      ),
      PageViewModel(
        title: 'Explora los Niveles',
        body:
            'Nuestra aplicación ofrece una variedad de juegos diseñados para enseñarte los colores de manera divertida, hay mucho por descubrir.',
        image: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset('assets/onboarding_1_explore.gif'),
          ),
        ),
        decoration: _pageDecoration,
      ),
      PageViewModel(
        title: 'Seguimiento de Progreso',
        body:
            'La aplicación realiza un seguimiento de tu progreso a medida que avanzas en los juegos.',
        image: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset('assets/onboarding_2_progress.gif'),
          ),
        ),
        decoration: _pageDecoration,
      ),
      PageViewModel(
        title: 'Configuración Personalizada',
        body:
            'Personaliza tu experiencia de juego ajustando la configuración según tus preferencias.',
        image: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset('assets/onboarding_3_customize.gif'),
          ),
        ),
        decoration: _pageDecoration,
      ),
    ];

    return Container(
      color: kColorSecondary,
      child: SafeArea(
        child: IntroductionScreen(
          key: introKey,
          pages: _onBoardingList,
          onDone: () => _onIntroEnd(context),
          showSkipButton: true,
          skip: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AuthPage(),
                ),
              );
            },
            child: Text('Saltar'),
          ),
          next: Container(
            padding: EdgeInsets.all(10),
            child: Icon(
              Icons.arrow_forward_ios,
              color: kColorSecondary,
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25), color: kColorPrimary),
          ),
          done: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AuthPage(),
                ),
              );
            },
            child: Text('Hecho'),
          ),
          dotsDecorator: DotsDecorator(
            size: Size(10.0, 10.0),
            // color: theme.primaryColor,
            activeSize: Size(22.0, 10.0),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
            activeColor: theme.primaryColor,
          ),
        ),
      ),
    );
  }

  _onIntroEnd(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AuthPage(),
      ),
    );
  }
}
