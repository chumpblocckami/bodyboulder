import Toybox.Lang;

// Sets are tracked per muscle group, not per exercise.
// DEFAULT_KG[i] is the starting weight for NAMES[i]; keep both arrays the same length.
// Names must stay short (about 14 characters) to fit the round screen with the set number.
module Exercises {
    // Timed only: no reps or weight are asked for or logged.
    const CARDIO = "Cardio";

    const NAMES = [
        CARDIO,
        "Chest",
        "Back",
        "Shoulders",
        "Biceps",
        "Triceps",
        "Legs",
        "Abs",
    ] as Array<String>;

    const DEFAULT_KG = [0.0, 30.0, 40.0, 15.0, 10.0, 20.0, 50.0, 0.0] as Array<Float>;

    const DEFAULT_REPS = 10;
    const MIN_SET_SECONDS = 60;
    const MIN_REST_SECONDS = 90;
}
