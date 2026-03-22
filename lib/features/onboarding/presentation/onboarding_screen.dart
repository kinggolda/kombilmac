import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:schedule_app/features/schedule/presentation/screens/schedule_screen.dart';
import 'package:schedule_app/features/settings/presentation/providers/settings_providers.dart';
import 'package:schedule_app/shared/localization/app_strings.dart';
import 'package:schedule_app/shared/theme/design_tokens.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  static const String routeName = 'onboarding';
  static const String routePath = '/onboarding';

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(settingsControllerProvider.notifier).completeOnboarding();
    if (mounted) {
      context.go(ScheduleScreen.routePath);
    }
  }

  void _next() {
    _pageController.nextPage(
      duration: AppDurations.normal,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final pages = [
      _OnboardingPageData(
        icon: Icons.grid_view_rounded,
        title: strings.onboardingTitleOne,
        description: strings.onboardingDescriptionOne,
      ),
      _OnboardingPageData(
        icon: Icons.bolt_rounded,
        title: strings.onboardingTitleTwo,
        description: strings.onboardingDescriptionTwo,
      ),
      _OnboardingPageData(
        icon: Icons.cloud_done_rounded,
        title: strings.onboardingTitleThree,
        description: strings.onboardingDescriptionThree,
      ),
    ];

    final isLastPage = _index == pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(strings.skip),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _index = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 124,
                          height: 124,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withOpacity(0.5),
                            borderRadius: BorderRadius.circular(AppRadii.xl),
                          ),
                          child: Icon(
                            page.icon,
                            size: 58,
                            color:
                                Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) {
                  final active = index == _index;
                  return AnimatedContainer(
                    duration: AppDurations.fast,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .outlineVariant
                              .withOpacity(0.6),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isLastPage ? _finish : _next,
                  child: Text(isLastPage ? strings.start : strings.next),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

