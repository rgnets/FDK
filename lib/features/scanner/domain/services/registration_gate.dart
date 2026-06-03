/// Pure decision for whether the scanner registration popup may submit, given
/// the current selection and the selected room's loaded device options.
///
/// Lives outside the widget so the gating policy — which is the riskiest part
/// of the "must bind to a pre-designed device" change — can be unit-tested
/// without pumping the full provider-backed widget tree.
class RegistrationGate {
  const RegistrationGate._();

  /// Whether the Register / Move / Assign button should be enabled.
  ///
  /// An auto-detected full match (`isExistingMatch`) already targets a real
  /// device, so it only needs a room. A brand-new scan must be deliberately
  /// bound to a device that still exists in the current room options: either a
  /// designed/assigned device that is still present (`selectedDeviceAvailable`)
  /// or, only when the room has no designed slot, an explicitly-created one
  /// (`createNewSelected && allowCreateNew`).
  static bool canRegister({
    required bool roomSelected,
    required bool isMismatch,
    required bool registrationInProgress,
    required bool isExistingMatch,
    required bool optionsReady,
    required bool selectionMade,
    required bool createNewSelected,
    required bool allowCreateNew,
    required bool selectedDeviceAvailable,
  }) {
    if (!roomSelected || isMismatch || registrationInProgress) {
      return false;
    }
    if (isExistingMatch) {
      return true;
    }
    if (!optionsReady || !selectionMade) {
      return false;
    }
    if (createNewSelected) {
      return allowCreateNew;
    }
    return selectedDeviceAvailable;
  }
}
