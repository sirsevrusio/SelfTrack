# SelfTrack

SelfTrack is a simple yet powerful self-tracking and session recording tool. It helps users log their activity sessions, track the number of questions/tasks completed, and review detailed performance reports. Built with Flask and SQLite, it provides a lightweight web interface to manage and visualize your productivity sessions.

---

## Project Details

- **Project Name:** SelfTrack
- **Author:** [SirSevrus](https://github.com/SirSevrus)
- **Repository URL:** [https://github.com/SirSevrus/SelfTrack](https://github.com/SirSevrus/SelfTrack)
- **Supported OS:** Ubuntu (tested)
- **Not Tested On:** Windows, macOS

---

## Features

- Start, pause, resume, and stop productivity sessions.
- Record the time taken for each question/task.
- Generate reports after each session.
- Visualize historical performance (questions completed, total time, average speed).
- Automatic logging with timestamped logs.
- Bundled as a standalone executable using PyInstaller.
- Ubuntu desktop integration with launcher entry.

---

## Folder Structure

| Folder | Purpose |
|:-------|:--------|
| `templates/` | HTML templates for Flask web pages |
| `static/` | Static CSS/JS files |
| `data/` | SQLite database files |
| `logs/` | Runtime logs of the application |

---

## Installation Guide (Ubuntu Only)

### 1. Clone the Repository
```bash
git clone https://github.com/SirSevrus/SelfTrack.git
cd SelfTrack
```

### 2. Run the Installer Script
```bash
chmod +x install.sh
./install.sh
```
The installer will:
- Check for Python installation.
- Install Python if missing.
- Create a virtual environment.
- Install all required dependencies (Flask, etc.).
- Install PyInstaller.
- Build the standalone executable.
- Install the application to `/opt/SelfTrack/`.
- Create a desktop shortcut.

### 3. Launching the App
- Search for **SelfTrack** in your Applications menu.
- Or run manually:
```bash
/opt/SelfTrack/SelfTrack
```

---

## Installation Windows
<mark>NOTE</mark> : Currently the python based installer is in development, You can use it freely, after installation it will tell you where the application is installed you can run it from there.

**You will find the installer at** [SelfTrackInstaller](https://github.com/sirsevrusio/selftrackinstaller)

## 1. INSTALLATION
- Downloading the installer, you can download the installer from the repository directly [HERE](https://github.com/sirsevrusio/SelfTrack/raw/refs/heads/main/installer/installer.py) and run it via python installer.py. Also it requires python to be installed, you can download a python from [python.org](python.org).
- The Installer Will -
   - Installs the required libraries automatically.
   - Builds the executable on client's device to be free from architecture dependency.
   - Copies the executable to the directory provided at the end.
- The Installer Will NOT -
   - Collect any data regarding you.
   - Doesn't requires manual installation of libraries, it will handle them itself.
   - Cleans the source files, SRRY I will fix it soon.
   - Doesn't creates the shortcut or launcher for the application to be used via application menu directly. [WORKING ON IT CURRENTLY]

### 2. Launching the App
- Run the app from the windows app menu by searching 'SelfTrack'. or manually from the path basically
```bash
 C:\\Users\\{username}\\.SelfTrack\\SelfTrack.exe
```

## Usage

1. Open SelfTrack from the Ubuntu Applications menu or Windows app menu or launch manually.
2. Start a new session.
3. As you work on questions/tasks, log each one.
4. Pause or resume the session anytime.
5. When finished, save the session.
6. View detailed session reports and historical performance.

---

## Known Limitations

- Works fine on debian based linux operating systems and windows that supports python3.
- Windows Installation Scripts are added but not finished. Sadly no compatibility for linux(Arch, RedHat, Opensuse, etc) and macOs.
- No multi-user or authentication system (single local user only).

---

## Future Improvements (v2 Goals)

- Add cross-platform compatibility.
- Improve UI/UX styling.
- Introduce session tagging or categorization.
- Export session data to CSV.

---

## License

This project is licensed under the GNU GPL License - [Check here](https://github.com/sirsevrusio/SelfTrack/blob/windows/LICENSE)

---

## Contributions

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## Wanna See Projects I am working on?
You can see my website where i showcase my all projects which I am working on, [Check Here](https://sirsevrusio.github.io)

Happy tracking! ✨

