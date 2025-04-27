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

## Usage

1. Open SelfTrack from the Ubuntu Applications menu.
2. Start a new session.
3. As you work on questions/tasks, log each one.
4. Pause or resume the session anytime.
5. When finished, save the session.
6. View detailed session reports and historical performance.

---

## Known Limitations

- Only tested and verified on Ubuntu 20.04+.
- Not cross-platform yet (no Windows/macOS support currently).
- No multi-user or authentication system (single local user only).

---

## Future Improvements (v2 Goals)

- Add cross-platform compatibility.
- Improve UI/UX styling.
- Introduce session tagging or categorization.
- Export session data to CSV.

---

## License

This project is licensed under the MIT License.

---

## Contributions

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

Happy tracking! ✨

