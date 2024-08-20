import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:samadhan_chat/Auth/Bloc/auth_bloc.dart';
// import 'package:samadhan_chat/Auth/Bloc/auth_event.dart';
import 'package:samadhan_chat/auth/Bloc/auth_bloc.dart';
import 'package:samadhan_chat/auth/Bloc/auth_event.dart';
import 'package:samadhan_chat/utilities/Visuals/page_indicator.dart';

class OnboardingScreenView extends StatefulWidget {
  const OnboardingScreenView({super.key});

  @override
  State<OnboardingScreenView> createState() => _OnboardingScreenViewState();
}


class _OnboardingScreenViewState extends State<OnboardingScreenView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      quote: "",
      info: "",
      image: "assets/images/AnimeShrine.jpg",
    ),
    OnboardingPage(
      quote: "",
      info: "",
      image: "assets/images/blackhole (1).png",
    ),
    OnboardingPage(
      quote: "Are you ready to redefine your limits?",
      info: "Start your journey to extraordinary success",
      image: "assets/images/DarkPath.jpeg",
      isLast: true,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return _buildPage(_pages[index], context: context);
            },
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (_currentPage != _pages.length - 1)
                PageIndicator(
                  currentPage: _currentPage,
                  pageCount: _pages.length,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white.withOpacity(0.3),
                  dotWidth: 10,
                  activeDotWidth: 30,
                  dotHeight: 10,
                  spacing: 8,
                ),
                const SizedBox(height: 20),
                if (_currentPage != _pages.length - 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          _pageController.jumpToPage(_pages.length - 1);
                        },
                        child: const Text('Skip',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 610),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Next',
                            style: TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildPage(OnboardingPage page, {required BuildContext context}) {
  return Container(
    decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(page.image),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                page.quote,
                style:  TextStyle(
                  color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width * 0.081,
                    fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                page.info,
                style: TextStyle(
                  color: Colors.white,
                  fontSize:
                    MediaQuery.of(context).size.width * 0.055,
                ),
              ),
            ),
            const Spacer(),
            if (page.isLast)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: () {
                     context.read<AuthBloc>().add(const AuthEventNavigateToSignIn());                               
                      },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Get Started',
                        style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
            const SizedBox(height: 40),
          ]
        ),
      ),
  );
}

class OnboardingPage {
  final String quote;
  final String info;
  final String image;
  final bool isLast;

  OnboardingPage({
    required this.quote,
    required this.info,
    required this.image,
    this.isLast = false,
  });
}
