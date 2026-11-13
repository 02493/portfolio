import 'dart:math' as math;
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const PortfolioApp());

Future<void> _openExternal(String value) async {
  final uri = Uri.parse(value);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

const Color ink = Color(0xFF090914);
const Color panel = Color(0xFF24223D);
const Color muted = Color(0xFFB8B7CC);
const Color accent = Color(0xFF648BFF);

class PortfolioApp extends StatefulWidget {
  const PortfolioApp({super.key});

  @override
  State<PortfolioApp> createState() => _PortfolioAppState();
}

class _PortfolioAppState extends State<PortfolioApp> {
  bool _isLight = false;

  @override
  Widget build(BuildContext context) {
    final brightness = _isLight ? Brightness.light : Brightness.dark;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Andrey Tokarev | Portfolio',
      theme: ThemeData(
        brightness: brightness,
        scaffoldBackgroundColor: _isLight ? const Color(0xFFEDEEF4) : ink,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: brightness,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: LauncherHome(
        isLight: _isLight,
        onToggleTheme: () => setState(() => _isLight = !_isLight),
      ),
    );
  }
}

class PortfolioItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String description;
  final String repositoryUrl;

  const PortfolioItem(
    this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.description, {
    this.repositoryUrl = '',
  });
}

// Список проектов портфолио
const items = <PortfolioItem>[
  PortfolioItem(
    'Weather Forecast App',
    'Kotlin · Android',
    Icons.cloud_rounded,
    Color(0xFF4F83CC),
    'Мобильное приложение для Android, которое получает данные о погоде через API. '
        'Пользователь может просматривать погоду на ближайшие три часа и настраивать виджет приложения. '
        'Проект создан на Kotlin.',
    repositoryUrl: 'https://github.com/02493/weather-forecast-app',
  ),
  PortfolioItem(
    'Folder Notes',
    'Kotlin · Android',
    Icons.note_alt_rounded,
    Color(0xFF42A5F5),
    'Android-приложение для создания и организации заметок. '
        'Поддерживает папки и вложенную структуру, поиск, '
        'автосохранение, корзину и резервное копирование.',
    repositoryUrl: 'https://github.com/02493/note-app',
  ),
  PortfolioItem(
    'User Data App',
    'Kotlin · Android',
    Icons.perm_device_information_rounded,
    Color(0xFF26A69A),
    'Android-приложение для работы с пользовательскими '
        'данными и возможностями устройства. '
        'Демонстрирует взаимодействие с системными функциями Android.',
    repositoryUrl: 'https://github.com/02493/kotlin-userdata-app',
  ),
  PortfolioItem(
    'Ujin Hackathon',
    'Flutter · Team Project',
    Icons.hub_rounded,
    Color(0xFF6C5CE7),
    'Командный проект, разработанный в рамках хакатона Ujin. '
        'Решение ориентировано на автоматизацию сервисов, интеграцию компонентов умного дома и взаимодействие с платформой Ujin.',
    repositoryUrl: 'https://github.com/02493/ujin-hackathon-team/',
  ),
];

class LauncherHome extends StatelessWidget {
  final bool isLight;
  final VoidCallback onToggleTheme;

  const LauncherHome({
    super.key,
    required this.isLight,
    required this.onToggleTheme,
  });

  Future<void> _openUrl(String value) async {
    final uri = Uri.parse(value);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openItem(BuildContext context, PortfolioItem item) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? const Color(0xFFF4F5F9)
          : const Color(0xFF151525),
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _AppIcon(icon: item.icon, color: item.color, size: 54),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w700)),
                        Text(item.subtitle,
                            style: const TextStyle(color: muted)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(item.description,
                  style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                          ? const Color(0xFF454B5A)
                          : const Color(0xFFD8E0EF),
                      height: 1.55,
                      fontSize: 15)),
              const SizedBox(height: 20),
              _ActionButton(
                label: item.repositoryUrl.isNotEmpty
                    ? 'Open GitHub repository · README'
                    : 'GitHub README · link will be added',
                icon: Icons.open_in_new_rounded,
                onTap: item.repositoryUrl.isNotEmpty
                    ? () => _openUrl(item.repositoryUrl)
                    : () => _openUrl('https://github.com/02493'),
                enabled: item.repositoryUrl.isNotEmpty,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: _AmbientBackground(isLight: isLight)),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final desktop = constraints.maxWidth >= 1120;
                final tablet = constraints.maxWidth >= 700;
                if (desktop) {
                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 20),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1320),
                        child: SizedBox(
                          height: 820,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 9,
                                child: _GlassPanel(
                                  isLight: isLight,
                                  child: const _AboutPanel(),
                                ),
                              ),
                              const SizedBox(width: 26),
                              Expanded(
                                flex: 10,
                                child: Center(
                                  child: _PhoneFrame(
                                    onOpen: (item) => _openItem(context, item),
                                    onGithub: () =>
                                        _openUrl('https://github.com/02493'),
                                    isLight: isLight,
                                    onToggleTheme: onToggleTheme,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 26),
                              Expanded(
                                flex: 9,
                                child: _GlassPanel(
                                  isLight: isLight,
                                  child: const _ContactPanel(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: tablet ? 48 : 18,
                    vertical: 24,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 430,
                            child: _GlassPanel(
                                isLight: isLight, child: const _AboutPanel()),
                          ),
                          const SizedBox(height: 28),
                          _PhoneFrame(
                            onOpen: (item) => _openItem(context, item),
                            onGithub: () =>
                                _openUrl('https://github.com/02493'),
                            isLight: isLight,
                            onToggleTheme: onToggleTheme,
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            height: 500,
                            child: _GlassPanel(
                                isLight: isLight, child: const _ContactPanel()),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Built with Flutter  ·  © Andrey Tokarev',
                            style: TextStyle(
                                color: Color(0xFF77758F), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AmbientBackground extends StatefulWidget {
  final bool isLight;
  const _AmbientBackground({required this.isLight});

  @override
  State<_AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<_AmbientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _logos = <_FloatingLogoData>[
    _FloatingLogoData(SimpleIcons.android,
        column: 0, phase: 0.000000, direction: 1),
    _FloatingLogoData(SimpleIcons.git,
        column: 0, phase: 0.166667, direction: 1),
    _FloatingLogoData(SimpleIcons.github,
        column: 0, phase: 0.333333, direction: 1),
    _FloatingLogoData(SimpleIcons.gitlab,
        column: 0, phase: 0.500000, direction: 1),
    _FloatingLogoData(SimpleIcons.apple,
        column: 0, phase: 0.666667, direction: 1),
    _FloatingLogoData(SimpleIcons.kotlin,
        column: 0, phase: 0.833333, direction: 1),
    _FloatingLogoData(SimpleIcons.android,
        column: 1, phase: 0.110000, direction: -1),
    _FloatingLogoData(SimpleIcons.git,
        column: 1, phase: 0.276667, direction: -1),
    _FloatingLogoData(SimpleIcons.github,
        column: 1, phase: 0.443333, direction: -1),
    _FloatingLogoData(SimpleIcons.gitlab,
        column: 1, phase: 0.610000, direction: -1),
    _FloatingLogoData(SimpleIcons.apple,
        column: 1, phase: 0.776667, direction: -1),
    _FloatingLogoData(SimpleIcons.kotlin,
        column: 1, phase: 0.943333, direction: -1),
    _FloatingLogoData(SimpleIcons.android,
        column: 2, phase: 0.220000, direction: 1),
    _FloatingLogoData(SimpleIcons.git,
        column: 2, phase: 0.386667, direction: 1),
    _FloatingLogoData(SimpleIcons.github,
        column: 2, phase: 0.553333, direction: 1),
    _FloatingLogoData(SimpleIcons.gitlab,
        column: 2, phase: 0.720000, direction: 1),
    _FloatingLogoData(SimpleIcons.apple,
        column: 2, phase: 0.886667, direction: 1),
    _FloatingLogoData(SimpleIcons.kotlin,
        column: 2, phase: 0.053333, direction: 1),
    _FloatingLogoData(SimpleIcons.android,
        column: 3, phase: 0.330000, direction: -1),
    _FloatingLogoData(SimpleIcons.git,
        column: 3, phase: 0.496667, direction: -1),
    _FloatingLogoData(SimpleIcons.github,
        column: 3, phase: 0.663333, direction: -1),
    _FloatingLogoData(SimpleIcons.gitlab,
        column: 3, phase: 0.830000, direction: -1),
    _FloatingLogoData(SimpleIcons.apple,
        column: 3, phase: 0.996667, direction: -1),
    _FloatingLogoData(SimpleIcons.kotlin,
        column: 3, phase: 0.163333, direction: -1),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 42),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = widget.isLight;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final logoSize = width < 700 ? 46.0 : 76.0;

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0.45, -0.1),
                        radius: 1.25,
                        colors: isLight
                            ? const [
                                Color(0xFFDCEBFA),
                                Color(0xFFE9E5F7),
                                Color(0xFFF0F1F6),
                              ]
                            : const [
                                Color(0xFF252A35),
                                Color(0xFF1A1D27),
                                Color(0xFF111319),
                              ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: -90,
                  top: height * 0.18,
                  child: _GlowCircle(
                    size: 270,
                    color: isLight
                        ? const Color(0xFF91B8EE)
                        : const Color(0xFF435A91),
                  ),
                ),
                Positioned(
                  right: -100,
                  bottom: height * 0.10,
                  child: _GlowCircle(
                    size: 320,
                    color: isLight
                        ? const Color(0xFFB9A8E8)
                        : const Color(0xFF55417F),
                  ),
                ),
                Positioned(
                  right: width * 0.28,
                  top: -145,
                  child: _GlowCircle(
                    size: 270,
                    color: isLight
                        ? const Color(0xFFB4C8E8)
                        : const Color(0xFF38466F),
                  ),
                ),
                for (final logo in _logos)
                  _buildFloatingLogo(
                    logo,
                    width: width,
                    height: height,
                    size: logoSize,
                    progress: _controller.value,
                    isLight: isLight,
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFloatingLogo(
    _FloatingLogoData logo, {
    required double width,
    required double height,
    required double size,
    required double progress,
    required bool isLight,
  }) {
    // Все элементы проходят одинаковое расстояние за один цикл.
    // phase задаёт только начальное положение, но не влияет на скорость.
    final travel = (progress + logo.phase) % 1.0;
    final trackLength = height + size * 2;
    final top = logo.direction > 0
        ? -size + travel * trackLength
        : height + size - travel * trackLength;
    final columnCenter = width * ((logo.column + 0.5) / 4);
    final color = isLight
        ? const Color(0xFF30394B).withOpacity(0.16)
        : Colors.white.withOpacity(0.17);

    return Positioned(
      left: columnCenter - size / 2,
      top: top,
      width: size,
      height: size,
      child: IgnorePointer(
        child: Icon(
          logo.icon,
          size: size,
          color: color,
        ),
      ),
    );
  }
}

class _FloatingLogoData {
  final IconData icon;
  final int column;
  final double phase;
  final int direction;

  const _FloatingLogoData(
    this.icon, {
    required this.column,
    required this.phase,
    required this.direction,
  });
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.13),
        ),
      );
}

class _GlassPanel extends StatelessWidget {
  final Widget child;
  final bool isLight;
  const _GlassPanel({required this.child, required this.isLight});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isLight
            ? Colors.white.withOpacity(0.72)
            : const Color(0xFFB7A9E8).withOpacity(0.10),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isLight
              ? const Color(0xFF737D9A).withOpacity(0.20)
              : Colors.white.withOpacity(0.11),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 35,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AboutPanel extends StatelessWidget {
  const _AboutPanel();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Привет! Меня зовут',
                style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? const Color(0xFF626A7B)
                        : muted,
                    fontSize: 14)),
            const SizedBox(height: 8),
            const Text(
              'Андрей Токарев',
              style: TextStyle(
                fontSize: 34,
                height: 1.05,
                letterSpacing: -1,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Я занимаюсь разработкой мобильных приложений, потому что мне интересно превращать идеи в реальные продукты, которыми люди пользуются каждый день. Я постоянно развиваюсь, изучаю новые инструменты и работаю над собственными проектами.\n\nМне нравится сочетать дизайн и функциональность, удобные интерфейсы. Каждый новый проект для меня возможность научиться чему-то новому и стать лучше в разработке.',
              style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? const Color(0xFF626A7B)
                      : muted,
                  height: 1.65,
                  fontSize: 13),
            ),
            const SizedBox(height: 26),
            const Text('Tech Stack',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            const Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _TechTile(label: 'Kotlin', icon: Icons.code_rounded),
                _TechTile(label: 'Android', icon: Icons.android_rounded),
                _TechTile(label: 'Flutter', icon: Icons.flutter_dash_rounded),
                _TechTile(label: 'Dart', icon: Icons.data_object_rounded),
                _TechTile(label: 'Git', icon: Icons.account_tree_rounded),
                _TechTile(label: 'UI/UX', icon: Icons.palette_outlined),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TechTile extends StatelessWidget {
  final String label;
  final IconData icon;
  const _TechTile({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? const Color(0xFFE6E8F0)
              : Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.light
                ? const Color(0xFFB9C0D1)
                : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: const Color(0xFFB7C5FF)),
            const SizedBox(width: 7),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.light
                        ? const Color(0xFF454B5A)
                        : Colors.white70)),
          ],
        ),
      );
}

class _PhoneFrame extends StatelessWidget {
  final ValueChanged<PortfolioItem> onOpen;
  final VoidCallback onGithub;
  final bool isLight;
  final VoidCallback onToggleTheme;

  const _PhoneFrame({
    required this.onOpen,
    required this.onGithub,
    required this.isLight,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 330,
      height: 690,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFE4E6ED) : const Color(0xFF090A0F),
        borderRadius: BorderRadius.circular(43),
        border: Border.all(color: const Color(0xFF777783), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D5DFB).withOpacity(0.20),
            blurRadius: 42,
            spreadRadius: 2,
          ),
          const BoxShadow(
            color: Colors.black54,
            blurRadius: 35,
            offset: Offset(0, 22),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: Container(
          color: isLight ? const Color(0xFFF0F1F5) : const Color(0xFF101116),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(13, 13, 13, 12),
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    _PhoneStatusBar(isLight: isLight),
                    const SizedBox(height: 18),
                    _SearchBar(isLight: isLight),
                    const SizedBox(height: 14),
                    _NowPlayingCard(isLight: isLight),
                    const SizedBox(height: 18),
                    Expanded(
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: items.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 13,
                          crossAxisSpacing: 8,
                          childAspectRatio: 0.88,
                        ),
                        itemBuilder: (context, index) => _PhoneApp(
                          item: items[index],
                          onTap: () => onOpen(items[index]),
                        ),
                      ),
                    ),
                    _PhoneDock(
                      isLight: isLight,
                      onGithub: onGithub,
                      onTelegram: () => _openExternal('https://t.me/tec9shi'),
                      onToggleTheme: onToggleTheme,
                      onRuStore: () => _openExternal('https://www.rustore.ru/'),
                      onPlayStore: () =>
                          _openExternal('https://play.google.com/store'),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 92,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isLight
                            ? Colors.black.withOpacity(0.35)
                            : Colors.white.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 5,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 82,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhoneStatusBar extends StatelessWidget {
  final bool isLight;
  const _PhoneStatusBar({required this.isLight});

  @override
  Widget build(BuildContext context) {
    final color = isLight ? const Color(0xFF252A36) : Colors.white;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('9:41',
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        Row(children: [
          Icon(Icons.signal_cellular_alt_rounded, size: 14, color: color),
          const SizedBox(width: 5),
          Icon(Icons.wifi_rounded, size: 14, color: color),
          const SizedBox(width: 5),
          Icon(Icons.battery_full_rounded, size: 16, color: color),
        ]),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final bool isLight;
  const _SearchBar({required this.isLight});

  @override
  Widget build(BuildContext context) => Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          color: isLight ? const Color(0xFFE0E2E9) : const Color(0xFF292C39),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded,
                color: isLight ? const Color(0xFF707789) : Colors.white60,
                size: 19),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Search projects...',
                  style: TextStyle(
                      color: isLight ? const Color(0xFF707789) : Colors.white60,
                      fontSize: 12)),
            ),
            Icon(Icons.mic_none_rounded,
                color: isLight ? const Color(0xFF707789) : Colors.white60,
                size: 18),
          ],
        ),
      );
}

class _NowPlayingCard extends StatelessWidget {
  final bool isLight;
  const _NowPlayingCard({required this.isLight});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: isLight ? Colors.white : const Color(0xFF202330),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isLight
                  ? const Color(0xFFD5D9E4)
                  : Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: const Color(0xFF536B9D),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(Icons.person_rounded, size: 27),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('♫  NOW PLAYING',
                          style: TextStyle(
                              color: Color(0xFF8B91FF),
                              fontSize: 9,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text('Andrey Tokarev',
                          style: TextStyle(
                              color: isLight
                                  ? const Color(0xFF252A36)
                                  : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                      Text('Portfolio · Digital space',
                          style: TextStyle(
                              color: isLight
                                  ? const Color(0xFF72798A)
                                  : Colors.white54,
                              fontSize: 9)),
                    ],
                  ),
                ),
                Icon(Icons.skip_previous_rounded,
                    color: isLight ? const Color(0xFF626A7B) : Colors.white70,
                    size: 18),
                const SizedBox(width: 4),
                const Icon(Icons.pause_circle_filled_rounded,
                    color: Color(0xFF8587FF), size: 31),
                const SizedBox(width: 4),
                Icon(Icons.skip_next_rounded,
                    color: isLight ? const Color(0xFF626A7B) : Colors.white70,
                    size: 18),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 0.58,
                minHeight: 3,
                backgroundColor:
                    isLight ? const Color(0xFFDDE1EA) : const Color(0xFF3B4056),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF8587FF)),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0:58',
                    style: TextStyle(
                        color:
                            isLight ? const Color(0xFF72798A) : Colors.white54,
                        fontSize: 8)),
                Text('2:40',
                    style: TextStyle(
                        color:
                            isLight ? const Color(0xFF72798A) : Colors.white54,
                        fontSize: 8)),
              ],
            ),
          ],
        ),
      );
}

class _PhoneApp extends StatelessWidget {
  final PortfolioItem item;
  final VoidCallback onTap;
  const _PhoneApp({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _AppIcon(icon: item.icon, color: item.color, size: 48),
            const SizedBox(height: 7),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 9,
                  color: Theme.of(context).brightness == Brightness.light
                      ? const Color(0xFF303442)
                      : Colors.white,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
}

class _PhoneDock extends StatelessWidget {
  final bool isLight;
  final VoidCallback onGithub;
  final VoidCallback onTelegram;
  final VoidCallback onToggleTheme;
  final VoidCallback onRuStore;
  final VoidCallback onPlayStore;

  const _PhoneDock({
    required this.isLight,
    required this.onGithub,
    required this.onTelegram,
    required this.onToggleTheme,
    required this.onRuStore,
    required this.onPlayStore,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isLight ? const Color(0xFFE1E3EA) : const Color(0xFF202330),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isLight ? const Color(0xFFD1D5DF) : Colors.white10,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _DockIcon(
              icon: Icons.code_rounded,
              assetPath: 'icon/github.png',
              tooltip: 'GitHub',
              onTap: onGithub,
              isLight: isLight,
            ),
            _DockIcon(
              icon: Icons.send_rounded,
              assetPath: 'icon/telegram.png',
              tooltip: 'Telegram',
              onTap: onTelegram,
              isLight: isLight,
              tintAssetInDark: true,
            ),
            _DockIcon(
              icon: isLight ? Icons.dark_mode_rounded : Icons.wb_sunny_rounded,
              tooltip: 'Theme',
              onTap: onToggleTheme,
              isLight: isLight,
              highlighted: true,
            ),
            _DockIcon(
              icon: Icons.store_rounded,
              assetPath: 'icon/rustore.png',
              tooltip: 'RuStore',
              onTap: onRuStore,
              isLight: isLight,
              tintAssetInDark: true,
            ),
            _DockIcon(
              icon: Icons.play_arrow_rounded,
              assetPath: 'icon/googleplay.png',
              tooltip: 'Google Play',
              onTap: onPlayStore,
              isLight: isLight,
              tintAssetInDark: true,
            ),
          ],
        ),
      );
}

class _DockIcon extends StatelessWidget {
  final IconData icon;
  final String? assetPath;
  final String tooltip;
  final VoidCallback onTap;
  final bool isLight;
  final bool highlighted;
  final bool tintAssetInDark;

  const _DockIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.isLight,
    this.assetPath,
    this.highlighted = false,
    this.tintAssetInDark = true,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: 43,
        height: 43,
        decoration: BoxDecoration(
          gradient: highlighted
              ? const LinearGradient(
                  colors: [Color(0xFF7778F6), Color(0xFF6756C9)],
                )
              : null,
          color: highlighted
              ? null
              : (isLight ? const Color(0xFFD0D3DC) : const Color(0xFF303341)),
          borderRadius: BorderRadius.circular(15),
        ),
        child: IconButton(
          onPressed: onTap,
          padding: EdgeInsets.zero,
          icon: assetPath != null
              ? Padding(
                  padding: const EdgeInsets.all(9),
                  child: Image.asset(
                    assetPath!,
                    fit: BoxFit.contain,
                    color: !isLight && tintAssetInDark ? Colors.white : null,
                    colorBlendMode: BlendMode.srcIn,
                    errorBuilder: (_, __, ___) => Icon(
                      icon,
                      size: 21,
                      color: highlighted
                          ? Colors.white
                          : (isLight
                              ? const Color(0xFF252936)
                              : Colors.white70),
                    ),
                  ),
                )
              : Icon(
                  icon,
                  size: 21,
                  color: highlighted
                      ? Colors.white
                      : (isLight ? const Color(0xFF252936) : Colors.white70),
                ),
          tooltip: tooltip,
        ),
      );
}

class _AppIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  const _AppIcon({required this.icon, required this.color, this.size = 58});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.29),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.95), color.withOpacity(0.58)],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.22),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.48),
      );
}

class _ContactPanel extends StatefulWidget {
  const _ContactPanel();

  @override
  State<_ContactPanel> createState() => _ContactPanelState();
}

class _ContactPanelState extends State<_ContactPanel> {
  int? _captchaWidgetId;
  late final String _recaptchaViewType;
  String? _captchaMessage;
  String? _formNotice;
  bool _formNoticeSuccess = false;

  static const String _recaptchaSiteKey =
      '6LcWAx8uAAAAADayGT-5winXS8PHT7h5ZuvYYKG-';

  @override
  void initState() {
    super.initState();

    // Регистрируем HTML-поле Google reCAPTCHA как Flutter Web platform view.
    // У каждого экземпляра формы собственный viewType.
    _recaptchaViewType = 'portfolio-recaptcha-${identityHashCode(this)}';
    ui_web.platformViewRegistry.registerViewFactory(
      _recaptchaViewType,
      (int viewId) {
        final element = html.DivElement()
          ..style.width = '304px'
          ..style.height = '78px';

        void showCaptchaMessage(String message) {
          if (!mounted) return;
          setState(() => _captchaMessage = message);
        }

        void renderCaptcha() {
          if (!mounted || _captchaWidgetId != null) return;

          final grecaptchaValue = js.context['grecaptcha'];
          if (grecaptchaValue == null) {
            showCaptchaMessage(
              'Не удалось загрузить Google reCAPTCHA. Обнови страницу.',
            );
            return;
          }

          try {
            final grecaptcha = grecaptchaValue as js.JsObject;
            final options = js.JsObject.jsify({
              'sitekey': _recaptchaSiteKey,
              'theme': 'light',
              'callback': js.allowInterop((dynamic token) {
                if (!mounted) return;
                setState(() => _captchaMessage = null);
              }),
              'expired-callback': js.allowInterop(() {
                showCaptchaMessage(
                  'Проверка истекла. Поставь галочку ещё раз.',
                );
              }),
              'error-callback': js.allowInterop(() {
                showCaptchaMessage(
                  'Ошибка загрузки CAPTCHA. Проверь подключение к интернету.',
                );
              }),
            });

            final id = grecaptcha.callMethod('render', [element, options]);
            _captchaWidgetId = (id as num).toInt();
            if (mounted) {
              setState(() => _captchaMessage = null);
            }
          } catch (_) {
            showCaptchaMessage(
              'Не удалось отобразить CAPTCHA. Обнови страницу.',
            );
          }
        }

        // Даём Flutter завершить добавление HTML-элемента в DOM
        // до вызова grecaptcha.render().
        final existingGrecaptcha = js.context['grecaptcha'];
        if (existingGrecaptcha != null) {
          Future<void>.delayed(Duration.zero, renderCaptcha);
        } else {
          final script = html.ScriptElement()
            ..src =
                'https://www.google.com/recaptcha/api.js?render=explicit&hl=ru'
            ..setAttribute('async', '')
            ..setAttribute('defer', '');
          script.onLoad.listen((_) {
            Future<void>.delayed(Duration.zero, renderCaptcha);
          });
          script.onError.listen((_) {
            showCaptchaMessage(
              'Google reCAPTCHA недоступна. Проверь подключение к интернету.',
            );
          });
          html.document.head!.append(script);
        }

        return element;
      },
    );
  }

  String? _getCaptchaToken() {
    try {
      final grecaptchaValue = js.context['grecaptcha'];
      if (grecaptchaValue == null || _captchaWidgetId == null) return null;

      final grecaptcha = grecaptchaValue as js.JsObject;
      final token = grecaptcha.callMethod('getResponse', [_captchaWidgetId]);

      if (token == null || token.toString().isEmpty) return null;
      return token.toString();
    } catch (_) {
      return null;
    }
  }

  void _resetCaptcha() {
    try {
      final grecaptchaValue = js.context['grecaptcha'];
      if (grecaptchaValue != null && _captchaWidgetId != null) {
        (grecaptchaValue as js.JsObject)
            .callMethod('reset', [_captchaWidgetId]);
      }
    } catch (_) {
      // Не мешаем очистке формы, если CAPTCHA ещё не инициализирована.
    }
  }

  // Заполни эти значения из EmailJS Dashboard.
  static const String _serviceId = 'service_qcxsvzs';
  static const String _templateId = 'template_muxr50w';
  static const String _publicKey = 'LO_CbWC893lIBnhal';

  static const String _emailJsEndpoint =
      'https://api.emailjs.com/api/v1.0/email/send';

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _message = TextEditingController();
  final _website = TextEditingController(); // Honeypot против простых ботов.

  bool _isSending = false;
  DateTime? _lastSuccessfulSend;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _message.dispose();
    _website.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Укажи своё имя.';
    if (text.length > 30) return 'Имя должно содержать не более 30 символов.';
    if (text.runes.any((r) => r < 32 && r != 9)) {
      return 'Имя содержит недопустимые символы.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Укажи адрес электронной почты.';
    if (text.length > 254) return 'Слишком длинный адрес электронной почты.';
    final emailPattern = RegExp(
      r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+$",
    );
    if (!emailPattern.hasMatch(text)) {
      return 'Введи корректный адрес, например name@example.com.';
    }
    return null;
  }

  String? _validateMessage(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Напиши сообщение.';
    if (text.length < 10)
      return 'Сообщение должно содержать минимум 10 символов.';
    if (text.length > 2000)
      return 'Сообщение не должно превышать 2000 символов.';
    return null;
  }

  void _showNotice(String message, {bool success = false}) {
    if (!mounted) return;
    setState(() {
      _formNotice = message;
      _formNoticeSuccess = success;
    });
  }

  Future<void> _send() async {
    if (_isSending) return;
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    // Поле-ловушка: обычные посетители его не видят и не заполняют.
    // Если бот его заполнил, ничего не отправляем.
    if (_website.text.trim().isNotEmpty) return;

    final lastSent = _lastSuccessfulSend;
    if (lastSent != null &&
        DateTime.now().difference(lastSent) < const Duration(seconds: 30)) {
      _showNotice('Подожди немного перед следующей отправкой.');
      return;
    }

    if (_serviceId == 'YOUR_SERVICE_ID' ||
        _templateId == 'YOUR_TEMPLATE_ID' ||
        _publicKey == 'YOUR_PUBLIC_KEY') {
      _showNotice(
          'Сначала настрой EmailJS: Service ID, Template ID и Public Key.');
      return;
    }

    final captchaToken = _getCaptchaToken();
    if (captchaToken == null) {
      setState(() {
        _captchaMessage =
            'Сначала отметь «Я не робот» и дождись подтверждения Google.';
        _formNotice = null;
      });
      return;
    }

    setState(() {
      _isSending = true;
      _formNotice = null;
      _captchaMessage = null;
    });

    try {
      final response = await http
          .post(
            Uri.parse(_emailJsEndpoint),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'service_id': _serviceId,
              'template_id': _templateId,
              'user_id': _publicKey,
              'template_params': {
                'from_name': _name.text.trim(),
                'reply_to': _email.text.trim(),
                'message': _message.text.trim(),
                'g-recaptcha-response': captchaToken,
              },
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        _lastSuccessfulSend = DateTime.now();
        _formKey.currentState!.reset();
        _name.clear();
        _email.clear();
        _message.clear();
        _showNotice('Сообщение отправлено! Спасибо за обращение.',
            success: true);
      } else {
        debugPrint('EmailJS status: ${response.statusCode}');
        debugPrint('EmailJS response: ${response.body}');

        _showNotice(
          'Ошибка EmailJS (${response.statusCode}): ${response.body}',
        );
      }
    } catch (_) {
      _showNotice('Ошибка соединения. Проверь интернет и попробуй снова.');
    } finally {
      _resetCaptcha();
      if (mounted) {
        setState(() {
          _isSending = false;
          _captchaMessage = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Contact me',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
          const SizedBox(height: 22),
          _ContactField(
            controller: _name,
            hint: 'Your name',
            validator: _validateName,
            maxLength: 30,
            inputFormatters: [LengthLimitingTextInputFormatter(30)],
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 11),
          _ContactField(
            controller: _email,
            hint: 'Your email',
            validator: _validateEmail,
            maxLength: 254,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 11),
          Expanded(
            child: _ContactField(
              controller: _message,
              hint: 'Your message',
              expands: true,
              validator: _validateMessage,
              maxLength: 2000,
              keyboardType: TextInputType.multiline,
            ),
          ),
          // Honeypot скрыт от посетителей, но оставлен в дереве виджетов.
          Offstage(
            offstage: true,
            child: TextField(
              controller: _website,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(labelText: 'Website'),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            alignment: Alignment.centerLeft,
            child: SizedBox(
              height: 78,
              child: HtmlElementView(
                viewType: _recaptchaViewType,
              ),
            ),
          ),
          if (_captchaMessage != null) ...[
            const SizedBox(height: 3),
            Text(
              _captchaMessage!,
              style: const TextStyle(
                color: Color(0xFFE57373),
                fontSize: 11,
                height: 1.3,
              ),
            ),
          ],
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSending ? null : _send,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF5D83FF),
                disabledBackgroundColor:
                    const Color(0xFF5D83FF).withOpacity(0.55),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
              child: _isSending
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text('Sending...'),
                      ],
                    )
                  : const Text('Send',
                      style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          if (_formNotice != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: _formNoticeSuccess
                    ? const Color(0xFF23865A).withOpacity(0.14)
                    : const Color(0xFFE57373).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _formNoticeSuccess
                      ? const Color(0xFF23865A).withOpacity(0.45)
                      : const Color(0xFFE57373).withOpacity(0.4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _formNoticeSuccess
                        ? Icons.check_circle_outline_rounded
                        : Icons.error_outline_rounded,
                    size: 17,
                    color: _formNoticeSuccess
                        ? const Color(0xFF36A875)
                        : const Color(0xFFE57373),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _formNotice!,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.35,
                        color: Theme.of(context).brightness == Brightness.light
                            ? const Color(0xFF454B5A)
                            : Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ContactField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool expands;
  final String? Function(String?)? validator;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  const _ContactField({
    required this.controller,
    required this.hint,
    this.expands = false,
    this.validator,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        expands: expands,
        minLines: expands ? null : 1,
        maxLines: expands ? null : 1,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        validator: validator,
        textCapitalization: textCapitalization,
        textAlignVertical: expands ? TextAlignVertical.top : null,
        keyboardType: keyboardType ?? TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          counterText: '',
          errorMaxLines: 2,
          errorStyle: const TextStyle(fontSize: 10, height: 1.15),
          filled: true,
          fillColor: Colors.white.withOpacity(0.045),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF6F8FFF)),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE57373)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE57373)),
          ),
        ),
      );
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: enabled ? onTap : null,
          icon: Icon(icon, size: 18),
          label: Text(label),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: const Color(0xFF31496C),
            foregroundColor: Colors.white,
          ),
        ),
      );
}

class _ProjectPreview extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ProjectPreview({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF202B40),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              const _AppIcon(
                  icon: Icons.cloud_rounded,
                  color: Color(0xFF5E9DCE),
                  size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(subtitle,
                        style: const TextStyle(color: muted, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: muted),
            ],
          ),
        ),
      );
}
