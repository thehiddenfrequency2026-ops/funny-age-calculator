/// All the humour lives here so it is easy to add or edit jokes.

String roastForAge(int years) {
  if (years < 1) return 'Under one year old. Congratulations, you can read. Suspicious.';
  if (years < 5) return 'You are basically a toddler with a smartphone. Nap time!';
  if (years < 13) return 'Peak snack-negotiation years. Enjoy the unlimited energy.';
  if (years < 18) return 'Teenager detected. Everything is embarrassing, especially this app.';
  if (years < 25) return 'Young, broke, and fuelled by instant noodles. Classic.';
  if (years < 30) return 'Your knees just made their first weird noise. Welcome.';
  if (years < 40) return 'Officially at the age where "early night" is a lifestyle goal.';
  if (years < 50) return 'You now say "back in my day" and actually mean it.';
  if (years < 60) return 'Fine like wine. Wine also gives you a headache, so… same.';
  if (years < 75) return 'Legend status unlocked. You have seen things. Many things.';
  if (years < 100) return 'You have survived more updates than any phone ever could.';
  return 'You are a living museum exhibit. Please do not touch. Or do. Wow.';
}

String birthdayCountdownJoke(int daysToGo, bool isToday) {
  if (isToday) return '🎂 HAPPY BIRTHDAY! Cake is legally required today.';
  if (daysToGo == 1) return 'Tomorrow! Start clearing space in your stomach.';
  if (daysToGo <= 7) return 'Less than a week. Time to hint loudly to everyone.';
  if (daysToGo <= 30) return 'Within a month. Begin your "I don\'t want a fuss" performance.';
  if (daysToGo <= 100) return 'Still a while. Plenty of time to pretend you are not counting.';
  if (daysToGo <= 200) return 'Long wait. Maybe celebrate a half-birthday in the meantime?';
  return 'Ugh, almost a whole year away. Eat cake anyway. No rules.';
}

String sleepJoke(int sleepDays) {
  if (sleepDays < 365) return 'A whole lot of snoozing so far.';
  final years = (sleepDays / 365).toStringAsFixed(1);
  return 'That is about $years years of your life spent drooling on a pillow.';
}

String heartbeatJoke() => 'Your heart never took a day off. Rude not to thank it.';

String breathJoke() => 'And not one "thank you" to your lungs. Ungrateful.';

String moonJoke() => 'Full moons you have mostly ignored while scrolling.';

String sunJoke() => 'Frequent-flyer miles around the Sun. Zero airline points, sadly.';

String weekdayJoke(String weekday) {
  switch (weekday) {
    case 'Monday':
      return 'Born on a Monday. You were doomed to be tired from day one.';
    case 'Friday':
      return 'Born on a Friday. You arrived right on time for the weekend.';
    case 'Saturday':
    case 'Sunday':
      return 'Born on a weekend. Even your birth skipped work.';
    default:
      return 'Midweek baby. Balanced, dependable, and slightly confused.';
  }
}

String zodiacJoke(String zodiac) =>
    '$zodiac says you will have a "surprisingly productive" day. Probably not.';

String secondsJoke() => 'This counter ticks live. Yes, you just wasted a few of them reading this.';

String shareText({
  required int years,
  required int months,
  required int days,
  required int totalDays,
  required int daysToBirthday,
}) {
  return "I am $years years, $months months and $days days old "
      "(that's $totalDays days on Earth!). "
      "$daysToBirthday days until my next birthday cake 🎂 "
      "— via Funny Age Calculator";
}
