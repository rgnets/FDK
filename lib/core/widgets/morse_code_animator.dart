/// Morse code animator for "control communication cognizance"
class MorseCodeAnimator {
  // Morse code mappings
  static const Map<String, String> _morseCode = {
    'a': '.-',
    'b': '-...',
    'c': '-.-.',
    'd': '-..',
    'e': '.',
    'f': '..-.',
    'g': '--.',
    'h': '....',
    'i': '..',
    'j': '.---',
    'k': '-.-',
    'l': '.-..',
    'm': '--',
    'n': '-.',
    'o': '---',
    'p': '.--.',
    'q': '--.-',
    'r': '.-.',
    's': '...',
    't': '-',
    'u': '..-',
    'v': '...-',
    'w': '.--',
    'x': '-..-',
    'y': '-.--',
    'z': '--..',
    ' ': '/',
  };

  // Timing constants (in units, will be multiplied by base duration)
  static const int _dotDuration = 1;
  static const int _dashDuration = 3;
  static const int _symbolGap = 1;
  static const int _letterGap = 3;
  static const int _wordGap = 7;

  /// Convert text to morse code pattern with timing
  static List<MorseSignal> textToMorsePattern(String text) {
    final pattern = <MorseSignal>[];
    final lowerText = text.toLowerCase();

    for (var i = 0; i < lowerText.length; i++) {
      final char = lowerText[i];
      final morse = _morseCode[char];

      if (morse == null) {
        continue;
      }

      if (morse == '/') {
        // Word gap
        pattern.add(const MorseSignal(isOn: false, duration: _wordGap));
      } else {
        // Add morse symbols for this letter
        for (var j = 0; j < morse.length; j++) {
          final symbol = morse[j];

          // Add the symbol (dot or dash)
          if (symbol == '.') {
            pattern.add(const MorseSignal(isOn: true, duration: _dotDuration));
          } else if (symbol == '-') {
            pattern.add(const MorseSignal(isOn: true, duration: _dashDuration));
          }

          // Add gap after symbol (except for last symbol in letter)
          if (j < morse.length - 1) {
            pattern.add(const MorseSignal(isOn: false, duration: _symbolGap));
          }
        }

        // Add letter gap (except after last letter)
        if (i < lowerText.length - 1) {
          pattern.add(const MorseSignal(isOn: false, duration: _letterGap));
        }
      }
    }

    // Add a long pause at the end before repeating
    pattern.add(const MorseSignal(isOn: false, duration: _wordGap * 2));

    return pattern;
  }

  /// Calculate total duration for the pattern
  static int calculateTotalDuration(List<MorseSignal> pattern) {
    return pattern.fold(0, (sum, signal) => sum + signal.duration);
  }

  /// Get current signal state based on animation value
  static bool getCurrentState(List<MorseSignal> pattern, double animationValue) {
    final totalDuration = calculateTotalDuration(pattern);
    final currentPosition = (animationValue * totalDuration).floor();

    var accumulatedDuration = 0;
    for (final signal in pattern) {
      accumulatedDuration += signal.duration;
      if (currentPosition < accumulatedDuration) {
        return signal.isOn;
      }
    }

    return false;
  }

  /// Get the full morse pattern for "control communication cognizance"
  static List<MorseSignal> getControlCommunicationCognizancePattern() {
    return textToMorsePattern('control communication cognizance');
  }
}

/// Represents a morse code signal
class MorseSignal {
  const MorseSignal({required this.isOn, required this.duration});
  
  final bool isOn;
  final int duration;
}
