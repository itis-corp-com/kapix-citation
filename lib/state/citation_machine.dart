import 'package:state_machine/state_machine.dart';

/// A finite state machine that models the flow of collecting
/// information needed to create a citation. The machine starts
/// at the `start` state and guides the user through capturing
/// a driver's license, vehicle registration, optional VIN,
/// insurance, contact information, a final review and
/// submission. Transitions are named for the action that
/// triggers them and each transition is only legal from a set
/// of source states. See the README for details on how to
/// listen to state changes and execute transitions【586907375276432†L292-L355】.
class CitationMachine {
  /// The underlying state machine from the Workiva package.
  final StateMachine _machine = StateMachine('citation');

  /// Individual states in the citation workflow.
  late final State start;
  late final State licenseFront;
  late final State licenseBack;
  late final State registration;
  late final State maybeVin;
  late final State vin;
  late final State insurance;
  late final State contact;
  late final State review;
  late final State done;

  /// Transitions used to move between states. Each transition
  /// corresponds to a user action or automated decision. See
  /// [TemplatePromptService] for how these names map to chat
  /// actions.
  late final StateTransition begin;
  late final StateTransition licenseConfirm;
  late final StateTransition licenseBackNeeded;
  late final StateTransition licenseBackConfirm;
  late final StateTransition regHasVin;
  late final StateTransition regNoVin;
  late final StateTransition captureVin;
  late final StateTransition skipVin;
  late final StateTransition vinConfirm;
  late final StateTransition insConfirm;
  late final StateTransition contactConfirm;
  late final StateTransition fixLicense;
  late final StateTransition fixRegistration;
  late final StateTransition fixVin;
  late final StateTransition fixInsurance;
  late final StateTransition fixContact;
  late final StateTransition submit;

  CitationMachine() {
    // Define all states up front.
    start = _machine.newState('start');
    licenseFront = _machine.newState('licenseFront');
    licenseBack = _machine.newState('licenseBack');
    registration = _machine.newState('registration');
    maybeVin = _machine.newState('maybeVin');
    vin = _machine.newState('vin');
    insurance = _machine.newState('insurance');
    contact = _machine.newState('contact');
    review = _machine.newState('review');
    done = _machine.newState('done');

    // Define transitions with their valid source states and
    // destination state. If an invalid transition is attempted
    // the state_machine package will throw an error【586907375276432†L414-L444】.
    begin = _machine.newStateTransition('begin', [start], licenseFront);
    licenseConfirm = _machine.newStateTransition('licenseConfirm', [licenseFront], registration);
    licenseBackNeeded = _machine.newStateTransition('licenseBackNeeded', [licenseFront], licenseBack);
    licenseBackConfirm = _machine.newStateTransition('licenseBackConfirm', [licenseBack], registration);
    regHasVin = _machine.newStateTransition('regHasVin', [registration], insurance);
    regNoVin = _machine.newStateTransition('regNoVin', [registration], maybeVin);
    captureVin = _machine.newStateTransition('captureVin', [maybeVin], vin);
    skipVin = _machine.newStateTransition('skipVin', [maybeVin], insurance);
    vinConfirm = _machine.newStateTransition('vinConfirm', [vin], insurance);
    insConfirm = _machine.newStateTransition('insConfirm', [insurance], contact);
    contactConfirm = _machine.newStateTransition('contactConfirm', [contact], review);
    fixLicense = _machine.newStateTransition('fixLicense', [review], licenseFront);
    fixRegistration = _machine.newStateTransition('fixRegistration', [review], registration);
    fixVin = _machine.newStateTransition('fixVin', [review], vin);
    fixInsurance = _machine.newStateTransition('fixInsurance', [review], insurance);
    fixContact = _machine.newStateTransition('fixContact', [review], contact);
    submit = _machine.newStateTransition('submit', [review], done);
  }

  /// Start the machine in the `start` state. Must be called
  /// before executing any transitions【586907375276432†L292-L355】.
  void startMachine() {
    _machine.start(start);
  }

  /// The current active state of the machine.
  State get currentState => _machine.current;
}