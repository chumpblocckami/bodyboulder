import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class MainDelegate extends WatchUi.BehaviorDelegate {
    private var _workout as Workout;

    function initialize(workout as Workout) {
        BehaviorDelegate.initialize();
        _workout = workout;
    }

    // START button.
    function onSelect() as Boolean {
        switch (_workout.state) {
            case STATE_READY:
                _workout.start();
                break;
            case STATE_LIFT:
                _workout.endSet();
                break;
            case STATE_REST:
                if (_workout.isCardio()) {
                    _workout.beginSet(0, 0.0);
                } else {
                    openSetPicker(_workout);
                }
                break;
            case STATE_DONE:
                System.exit();
        }
        WatchUi.requestUpdate();
        return true;
    }

    // Consuming taps keeps them from becoming onSelect, so only START drives the workout.
    function onTap(clickEvent as WatchUi.ClickEvent) as Boolean {
        return true;
    }

    function onBack() as Boolean {
        if (_workout.state == STATE_LIFT || _workout.state == STATE_REST) {
            openWorkoutMenu(_workout);
            return true;
        }
        return false;
    }

    function onMenu() as Boolean {
        if (!canChangeExercise()) {
            return false;
        }
        openExerciseMenu(_workout);
        return true;
    }

    function onNextPage() as Boolean {
        return shift(1);
    }

    function onPreviousPage() as Boolean {
        return shift(-1);
    }

    private function shift(delta as Number) as Boolean {
        if (!canChangeExercise()) {
            return false;
        }
        _workout.shiftExercise(delta);
        WatchUi.requestUpdate();
        return true;
    }

    private function canChangeExercise() as Boolean {
        return _workout.state == STATE_READY || _workout.state == STATE_REST;
    }
}
