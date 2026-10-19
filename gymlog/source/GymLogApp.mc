import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class GymLogApp extends Application.AppBase {
    private var _workout as Workout;

    function initialize() {
        AppBase.initialize();
        _workout = new Workout();
    }

    function onStop(state as Dictionary?) as Void {
        // Closing the app mid-workout must not lose the sets already logged.
        _workout.saveIfRecording();
    }

    function getInitialView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
        var view = new MainView(_workout);
        return [view, new MainDelegate(_workout)];
    }
}
