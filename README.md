# SelfTrack

SelfTrack is a simple yet powerful self-tracking and session recording tool. It helps users log their activity sessions, track the number of questions/tasks completed, and review detailed performance reports. Built with Flask and SQLite, it provides a lightweight web interface to manage and visualize your productivity sessions.

---

## Project Details

- **Project Name:** SelfTrack
- **Author:** [SirSevrus](https://github.com/SirSevrus)
- **Repository URL:** [https://github.com/SirSevrus/SelfTrack](https://github.com/SirSevrus/SelfTrack)
- **Supported OS:** Currently in Development to support windows

---

## Features

- Start, pause, resume, and stop productivity sessions.
- Record the time taken for each question/task.
- Generate reports after each session.
- Visualize historical performance (questions completed, total time, average speed).
- Automatic logging with timestamped logs.
- Bundled as a standalone executable using PyInstaller.

---

## Folder Structure

| Folder | Purpose |
|:-------|:--------|
| `templates/` | HTML templates for Flask web pages |
| `static/` | Static CSS/JS files |
| `data/` | SQLite database files |
| `logs/` | Runtime logs of the application |

---

## Installation Windows
<mark> We are currently developing the installer for the windows, Luckily there is an installer available for windows, Its unfinished currently but it is cross platform compatible and also builds the application perfectly, just lacks some finishes. Check the installer directory for installer.</mark>

### Requirements
- 3.13 >= Python >= 3.10, it is not necessary to use the versions i said, if you want to use a newer version you are free to do that, Download python from [python.org](https://www.python.org/downloads/)
- No dependency on the system's architecture.

### 1. Clone the Repository
```bash
git clone https://github.com/SirSevrus/SelfTrack.git
cd SelfTrack
```
### 2. Install the requirements
```bash
pip install -r requirements.txt
```

### 3. Run the application
```python
python app.py
```

### 4. Launching the App
- you can run it directly via command - (Make sure to execute it in the directory where app.py is located)
```python
python app.py
```

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

Happy tracking! ✨

