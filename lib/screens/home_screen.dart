import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../age_logic.dart';
import '../jokes.dart';
import '../widgets/stat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  DateTime? _picked;
  AgeResult? _result;
  Timer? _ticker;
  late final AnimationController _bounce;

  @override
  void initState() {
    super.initState();
    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _bounce.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _picked ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'When did you arrive on Earth?',
    );
    if (d != null) {
      setState(() {
        _picked = d;
        _result = null;
      });
      _ticker?.cancel();
    }
  }

  void _calculate() {
    final picked = _picked;
    if (picked == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick your birthday first, time traveller! 🕰️')),
      );
      return;
    }
    final r = calculateAge(picked);
    _ticker?.cancel();
    // Re-render every second so the "seconds lived" counter is live.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    setState(() => _result = r);
  }

  Future<void> _copyBrag(AgeResult r) async {
    await Clipboard.setData(ClipboardData(
      text: shareText(
        years: r.years,
        months: r.months,
        days: r.days,
        totalDays: r.totalDays,
        daysToBirthday: r.daysToNextBirthday,
      ),
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied! Paste it in your group chat to brag 📋')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final r = _result;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primaryContainer,
              const Color(0xFFFFF3C4),
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _header(textTheme, scheme),
              const SizedBox(height: 20),
              _inputCard(scheme, textTheme),
              if (r != null) ..._results(r, scheme, textTheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(TextTheme textTheme, ColorScheme scheme) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _bounce,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, -12 * Curves.easeInOut.transform(_bounce.value)),
            child: child,
          ),
          child: const Text('🎂', style: TextStyle(fontSize: 64)),
        ),
        const SizedBox(height: 8),
        Text(
          'How Old Are You\n(Really)?',
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: scheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Enter your birthday. Prepare to be roasted.',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: scheme.onPrimaryContainer.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _inputCard(ColorScheme scheme, TextTheme textTheme) {
    final picked = _picked;
    return Card(
      elevation: 0,
      color: scheme.surface.withOpacity(0.92),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.cake_outlined),
              label: Text(
                picked == null ? 'Tap to pick your birthday' : formatDate(picked),
                style: textTheme.titleMedium,
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _calculate,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Calculate my age'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _results(AgeResult r, ColorScheme scheme, TextTheme textTheme) {
    final secondsLived = DateTime.now().difference(r.birthDate).inSeconds;
    final k = r.birthDate.toIso8601String();

    final cards = <StatCard>[
      StatCard(
        key: ValueKey('days-$k'),
        emoji: '📅',
        label: 'DAYS ON EARTH',
        value: formatInt(r.totalDays),
        joke: 'And you still forget where you put your keys.',
      ),
      StatCard(
        key: ValueKey('secs-$k'),
        emoji: '⏱️',
        label: 'SECONDS LIVED (LIVE)',
        value: formatInt(secondsLived),
        joke: secondsJoke(),
      ),
      StatCard(
        key: ValueKey('birthday-$k'),
        emoji: '🎁',
        label: r.isBirthdayToday ? 'TODAY IS THE DAY' : 'NEXT BIRTHDAY IN',
        value: r.isBirthdayToday
            ? 'It\'s your birthday!'
            : '${formatInt(r.daysToNextBirthday)} days',
        joke: birthdayCountdownJoke(r.daysToNextBirthday, r.isBirthdayToday),
      ),
      StatCard(
        key: ValueKey('heart-$k'),
        emoji: '❤️',
        label: 'HEARTBEATS (APPROX.)',
        value: formatInt(r.heartbeats),
        joke: heartbeatJoke(),
      ),
      StatCard(
        key: ValueKey('breath-$k'),
        emoji: '🌬️',
        label: 'BREATHS TAKEN (APPROX.)',
        value: formatInt(r.breaths),
        joke: breathJoke(),
      ),
      StatCard(
        key: ValueKey('sleep-$k'),
        emoji: '😴',
        label: 'DAYS SPENT ASLEEP (APPROX.)',
        value: formatInt(r.sleepDays),
        joke: sleepJoke(r.sleepDays),
      ),
      StatCard(
        key: ValueKey('moon-$k'),
        emoji: '🌕',
        label: 'FULL MOONS SEEN',
        value: formatInt(r.fullMoons),
        joke: moonJoke(),
      ),
      StatCard(
        key: ValueKey('sun-$k'),
        emoji: '🌍',
        label: 'KM TRAVELLED AROUND THE SUN',
        value: formatInt(r.kmAroundSun),
        joke: sunJoke(),
      ),
      StatCard(
        key: ValueKey('weekday-$k'),
        emoji: '🗓️',
        label: 'YOU WERE BORN ON A',
        value: r.weekdayBorn,
        joke: weekdayJoke(r.weekdayBorn),
      ),
      StatCard(
        key: ValueKey('zodiac-$k'),
        emoji: '🔮',
        label: 'YOUR STAR SIGN',
        value: r.zodiac,
        joke: zodiacJoke(r.zodiac),
      ),
    ];

    // Give each card its stagger index without recreating keys.
    final staggered = [
      for (var i = 0; i < cards.length; i++)
        StatCard(
          key: cards[i].key,
          emoji: cards[i].emoji,
          label: cards[i].label,
          value: cards[i].value,
          joke: cards[i].joke,
          index: i,
        ),
    ];

    return [
      const SizedBox(height: 20),
      Card(
        elevation: 0,
        color: scheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'YOU ARE',
                style: textTheme.labelLarge?.copyWith(
                  color: scheme.onPrimary.withOpacity(0.8),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${r.years} years, ${r.months} months\nand ${r.days} days old',
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                roastForAge(r.years),
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onPrimary.withOpacity(0.92),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      ...staggered,
      const SizedBox(height: 4),
      OutlinedButton.icon(
        onPressed: () => _copyBrag(r),
        icon: const Icon(Icons.copy_rounded),
        label: const Text('Copy my stats to brag'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: scheme.surface.withOpacity(0.9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      const SizedBox(height: 12),
      Text(
        'Numbers marked approx. use average heart rate and breathing rate. '
        'No actual doctors were consulted.',
        textAlign: TextAlign.center,
        style: textTheme.bodySmall?.copyWith(
          color: scheme.onSurface.withOpacity(0.6),
        ),
      ),
    ];
  }
}
