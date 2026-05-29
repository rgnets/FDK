import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/features/scanner/domain/services/registration_gate.dart';

void main() {
  group('RegistrationGate.canRegister', () {
    // Sensible baseline: a new scan in a room with a designed slot, device
    // picked and still present. Individual tests override what they exercise.
    bool gate({
      bool roomSelected = true,
      bool isMismatch = false,
      bool registrationInProgress = false,
      bool isExistingMatch = false,
      bool optionsReady = true,
      bool selectionMade = true,
      bool createNewSelected = false,
      bool allowCreateNew = false,
      bool selectedDeviceAvailable = true,
    }) {
      return RegistrationGate.canRegister(
        roomSelected: roomSelected,
        isMismatch: isMismatch,
        registrationInProgress: registrationInProgress,
        isExistingMatch: isExistingMatch,
        optionsReady: optionsReady,
        selectionMade: selectionMade,
        createNewSelected: createNewSelected,
        allowCreateNew: allowCreateNew,
        selectedDeviceAvailable: selectedDeviceAvailable,
      );
    }

    test('allows a new scan once a present device is picked', () {
      expect(gate(), isTrue);
    });

    test('blocks until the tech makes an explicit selection', () {
      expect(gate(selectionMade: false), isFalse);
    });

    test('blocks a new scan with no room selected', () {
      expect(gate(roomSelected: false), isFalse);
    });

    test('blocks on data mismatch', () {
      expect(gate(isMismatch: true), isFalse);
    });

    test('blocks while a registration is already in progress', () {
      expect(gate(registrationInProgress: true), isFalse);
    });

    test('blocks while the room device options are still loading/errored', () {
      expect(gate(optionsReady: false), isFalse);
    });

    test('blocks when the picked device is no longer in the room options', () {
      // e.g. tech picked a device, then switched rooms / the list refreshed.
      expect(gate(selectedDeviceAvailable: false), isFalse);
    });

    test('allows create-new only when the room has no designed slot', () {
      expect(
        gate(createNewSelected: true, allowCreateNew: true, selectedDeviceAvailable: false),
        isTrue,
      );
      expect(
        gate(createNewSelected: true, allowCreateNew: false, selectedDeviceAvailable: false),
        isFalse,
      );
    });

    test('an existing full match only needs a room (move/reset path)', () {
      expect(
        gate(isExistingMatch: true, selectionMade: false, optionsReady: false),
        isTrue,
      );
      // ...but is still blocked by a mismatch or a missing room.
      expect(gate(isExistingMatch: true, isMismatch: true), isFalse);
      expect(gate(isExistingMatch: true, roomSelected: false), isFalse);
    });
  });
}
