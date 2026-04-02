import re

def update_file():
    with open('lib/main.dart', 'r') as f:
        content = f.read()

    # Replace BrutalCard with ThemedCard
    content = content.replace('BrutalCard(', 'ThemedCard(')

    # Replace BrutalTimerPainter with ThemedTimerPainter
    content = content.replace('BrutalTimerPainter(seconds: _seconds)', 'ThemedTimerPainter(seconds: _seconds, style: appThemeNotifier.value)')

    # Replace GoogleFonts.spaceMono to getThemeTextStyle
    content = re.sub(r'GoogleFonts\.spaceMono\((.*?)\)', r'getThemeTextStyle(\1)', content)

    # _buildBrutalButton renaming and implementation
    # It starts around: Widget _buildBrutalButton(
    btn_start = content.find("Widget _buildBrutalButton(")
    btn_end = content.find("void dispose() {")
    if btn_start != -1 and btn_end != -1:
        new_btn = """Widget _buildThemedButton(
    String title,
    Color color,
    VoidCallback onTap, {
    double width = 140,
    Color textColor = Colors.black,
  }) {
    final style = appThemeNotifier.value;
    
    if (style == AveroThemeStyle.calming) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color == Colors.white ? const Color(0xFFE8EFEA) : color.withOpacity(0.8),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              title,
              style: getThemeTextStyle(
                color: color == Colors.white ? const Color(0xFF4A6B5D) : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      );
    } else if (style == AveroThemeStyle.oled) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              title,
              style: getThemeTextStyle(
                color: Colors.white,
                fontWeight: FontWeight.normal,
                fontSize: 18,
              ),
            ),
          ),
        ),
      );
    } else if (style == AveroThemeStyle.retro) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: const Color(0xFF39FF14), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF39FF14).withOpacity(0.3),
                blurRadius: 8,
              ),
            ],
          ),
          child: Center(
            child: Text(
              title,
              style: getThemeTextStyle(
                color: const Color(0xFF39FF14),
                fontWeight: FontWeight.normal,
                fontSize: 18,
              ),
            ),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.black, width: 4),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(6, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              title,
              style: getThemeTextStyle(
                color: textColor,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
        ),
      );
    }
  }

  void _showThemePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('SELECT THEME', style: getThemeTextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: AveroThemeStyle.values.map((style) {
                  return GestureDetector(
                    onTap: () async {
                      appThemeNotifier.value = style;
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setInt('saved_theme_style', style.index);
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: appThemeNotifier.value == style ? Colors.blue : Colors.transparent, width: 2)
                      ),
                      child: ThemedCard(
                        backgroundColor: appThemeNotifier.value == style ? Colors.blue.withOpacity(0.1) : Theme.of(context).cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            style.name.toUpperCase(),
                            style: getThemeTextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  """
        content = content[:btn_start] + new_btn + content[btn_end:]

    # Call replacements in the rest of widget tree
    content = content.replace('_buildBrutalButton(', '_buildThemedButton(')

    # Add the theme picker action to the AppBar
    search_appbar = "icon: const Icon(Icons.history_toggle_off, size: 28),\n          ),\n        ],"
    replace_appbar = "icon: const Icon(Icons.history_toggle_off, size: 28),\n          ),\n          IconButton(icon: const Icon(Icons.palette, size: 28), onPressed: () => _showThemePicker(context)),\n        ],"
    content = content.replace(search_appbar, replace_appbar)

    # Some hardcoded Colors in Missions section
    content = content.replace('color: mission.completed ? Colors.black : Colors.white', 'color: mission.completed ? Theme.of(context).textTheme.bodyLarge?.color : Colors.transparent')
    content = content.replace('color: mission.completed ? Colors.white : Colors.black', 'color: mission.completed ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black')
    content = content.replace('border: Border.all(color: Colors.black, width: 2)', 'border: Border.all(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black, width: 2)')
    
    with open('lib/main.dart', 'w') as f:
        f.write(content)

if __name__ == '__main__':
    update_file()
