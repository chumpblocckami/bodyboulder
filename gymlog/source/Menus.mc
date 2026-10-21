import Toybox.Lang;
import Toybox.WatchUi;

function openWorkoutMenu(workout as Workout) as Void {
    var menu = new WatchUi.Menu2({ :title => "Workout" });
    menu.addItem(new WatchUi.MenuItem("Resume", null, :resume, null));
    if (workout.state == STATE_REST) {
        menu.addItem(new WatchUi.MenuItem("Change muscle", workout.exerciseName(), :exercise, null));
    }
    menu.addItem(new WatchUi.MenuItem("Save & finish", workout.totalSets + " sets", :save, null));
    menu.addItem(new WatchUi.MenuItem("Discard", null, :discard, null));
    WatchUi.pushView(menu, new WorkoutMenuDelegate(workout), WatchUi.SLIDE_UP);
}

function openExerciseMenu(workout as Workout) as Void {
    var menu = new WatchUi.Menu2({ :title => "Muscle group" });
    for (var i = 0; i < Exercises.NAMES.size(); i++) {
        menu.addItem(new WatchUi.MenuItem(Exercises.NAMES[i], workout.setLabel(i), i, null));
    }
    menu.setFocus(workout.exerciseIndex);
    WatchUi.pushView(menu, new ExerciseMenuDelegate(workout), WatchUi.SLIDE_UP);
}

class WorkoutMenuDelegate extends WatchUi.Menu2InputDelegate {
    private var _workout as Workout;

    function initialize(workout as Workout) {
        Menu2InputDelegate.initialize();
        _workout = workout;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();
        if (id == :resume) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        } else if (id == :exercise) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            openExerciseMenu(_workout);
        } else if (id == :save) {
            _workout.save();
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        } else if (id == :discard) {
            WatchUi.pushView(new WatchUi.Confirmation("Discard workout?"),
                new DiscardDelegate(_workout), WatchUi.SLIDE_IMMEDIATE);
        }
    }
}

class DiscardDelegate extends WatchUi.ConfirmationDelegate {
    private var _workout as Workout;

    function initialize(workout as Workout) {
        ConfirmationDelegate.initialize();
        _workout = workout;
    }

    function onResponse(response as WatchUi.Confirm) as Boolean {
        if (response == WatchUi.CONFIRM_YES) {
            _workout.discard();
            // Confirmation pops itself; also close the workout menu underneath.
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
        return true;
    }
}

class ExerciseMenuDelegate extends WatchUi.Menu2InputDelegate {
    private var _workout as Workout;

    function initialize(workout as Workout) {
        Menu2InputDelegate.initialize();
        _workout = workout;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        _workout.selectExercise(item.getId() as Number);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}
