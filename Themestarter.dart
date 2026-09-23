
class ThemeChallengePanel extends StatefulWidget {
  const ThemeChallengePanel({super.key});

  @override
  State<ThemeChallengePanel> createState() => _ThemeChallengePanelState();
}

class FoodTruckApp extends StatefulWidget {
  const FoodTruckApp({super.key});

  @override
  State<FoodTruckApp> createState() => _FoodTruckAppState();
}

class _FoodTruckAppState extends State<FoodTruckApp> {
  bool isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Truck Order Rush,
      debugShowCheckedModeBanner: false,
      theme: isDarkMode
          ? ThemeData.dark(useMaterial3: true)
          : ThemeData.light(useMaterial3: true),
      home: ControlDeckScreen(
        isDark: isDarkMode,
        onToggleTheme: () => setState(() => isDarkMode = !isDarkMode),
      ),
    );
  }
}

class _ThemeChallengePanelState extends State<ThemeChallengePanel> {
  int score = 0;
  int actionsTaken = 0;
  bool specialModeUnlocked = false;

  void _performAction({required int points, required String actionName}) {
    setState(() {
      score += points;
      actionsTaken++;
      specialModeUnlocked = score >= 20;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: specialModeUnlocked ? Colors.green.shade100 : Colors.white,
      child: Column(
        children: [
          Text('Score: $score | Actions: $actionsTaken'),
          if (specialModeUnlocked) const Text('SPECIAL MODE UNLOCKED!'),
          ElevatedButton(
            onPressed: () => _performAction(points: 2, actionName: 'Example'),
            child: const Text('Perform Action'),
          ),
        ],
      ),
    );
  }
}