# BodyBoulder

A Connect IQ watch app for the **Garmin Forerunner 165** that times a gym session set by set.
Every set and every rest is timed, logged as a lap, and saved as a Strength Training activity
to Garmin Connect (and from there to Strava).

<img src="gymlog/resources/drawables/launcher_icon.png" width="54" alt="BodyBoulder icon">

## How a session works

1. **Start**: recording begins and a "Get ready" timer runs. Pick the exercise with UP/DOWN.
2. **START**: choose reps and kg (pre-filled with your last values for that exercise).
3. **Confirm**: a small vibration, then the set timer counts up. At **1:00** another small
   vibration tells you the minimum set time is reached.
4. **START**: the set is stored and the rest timer counts up. At **1:30** a small vibration
   tells you the minimum rest is over. The rest keeps counting until you start the next set.
5. **BACK → Save & finish**: the session is saved, with a strong vibration. A strong vibration
   also marks the start of the session.

**Cardio** is timer-only: no reps or kg are asked, useful for the warm-up.

### Controls

| Button | Action |
| --- | --- |
| START (top right) or tap | Start session, open picker, start / stop a set |
| UP / DOWN | Change exercise (during rest) |
| Hold UP | Full exercise list |
| BACK | Resume, change exercise, save & finish, discard |

## What gets saved

- One FIT lap per set and per rest. Set laps carry `exercise`, `reps` and `weight` as
  developer fields; rest laps are named "Rest".
- Session totals: number of sets and volume (reps × kg).
- Garmin Connect shows the laps and the custom fields. Connect IQ apps cannot write Garmin's
  native strength "sets", so the exercises do not appear in Connect's Sets tab.
- Strava receives the activity automatically if Garmin Connect is linked to Strava
  (Garmin Connect app → Settings → Connected Apps → Strava). Strava shows laps, time and
  heart rate, but not the exercise names, reps or weight.

## Setup (Linux)

1. Install Java 17 (`sudo apt install openjdk-17-jdk`) and Docker (for the simulator).
2. Put the [connect-iq-sdk-manager](https://github.com/lindell/connect-iq-sdk-manager-cli) CLI
   in `bin/connect-iq-sdk-manager`, then download the SDK, the device and its fonts:

   ```bash
   bin/connect-iq-sdk-manager agreement accept
   bin/connect-iq-sdk-manager login
   bin/connect-iq-sdk-manager sdk set 8.4.1
   bin/connect-iq-sdk-manager device download -d fr165 --include-fonts
   ```

3. Create a developer key in `keys/` (it is git-ignored, keep it safe: you need the same key to
   update the app later):

   ```bash
   mkdir -p keys
   openssl genrsa -out keys/developer_key.pem 4096
   openssl pkcs8 -topk8 -inform PEM -outform DER -nocrypt \
       -in keys/developer_key.pem -out keys/developer_key.der
   ```

## Build, test, install

```bash
cd gymlog
./build.sh            # build bin/GymLog.prg
./build.sh install    # build and copy it to the watch plugged in over USB
```

`install` needs the watch mounted over MTP (plug it in, wake it, and open it once in Files).
After unplugging, BodyBoulder appears in the watch's activity list.

### Simulator

The SDK simulator needs WebKitGTK 4.0, which Ubuntu 24.04 no longer ships, so it runs in an
Ubuntu 22.04 container drawing on the host display:

```bash
docker build -t ciq-sim:22.04 sim/   # once
sim/run-simulator.sh                 # terminal 1
cd gymlog && ./build.sh sim          # terminal 2
```

The simulator does not vibrate; the timer turns green when each minimum is reached.
`sim/press.py` sends clicks/keys to the simulator and takes screenshots, for scripted checks.

## Customising

Exercises, default weights and the minimum set / rest times live in
[`gymlog/source/Exercises.mc`](gymlog/source/Exercises.mc). Keep `NAMES` and `DEFAULT_KG`
the same length.

## Project layout

```
gymlog/                 the watch app
  source/Workout.mc     session state, timers, vibrations, FIT laps
  source/MainView.mc    screens
  source/MainDelegate.mc, Menus.mc, SetPicker.mc   input handling
  source/Exercises.mc   exercise list and timings
  build.sh              build / install / simulator
sim/                    Docker simulator and the press.py automation helper
run-sdkmanager.sh       optional: runs Garmin's GUI SDK manager on Ubuntu 24.04 (via compat-libs/)
```
