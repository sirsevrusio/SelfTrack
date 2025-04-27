from flask import Flask, request, jsonify, render_template, redirect, abort
from datetime import datetime
import threading
import webbrowser
import os
import sqlite3
import time
import signal
import logging
import sys

app = Flask(__name__)

# --- PyInstaller Support ---
def resource_path(relative_path):
    """ Get absolute path to resource, works for dev and PyInstaller """
    if getattr(sys, 'frozen', False):
        # Running in PyInstaller bundle
        base_path = os.path.dirname(sys.executable)
    else:
        base_path = os.path.abspath(".")
    return os.path.join(base_path, relative_path)

# --- Setup Folders ---
for folder in [resource_path('logs'), resource_path('data')]:
    if not os.path.exists(folder):
        os.makedirs(folder, exist_ok=True)

# --- Setup Logging ---
LOG_FOLDER = resource_path('logs')
logging.basicConfig(
    filename=os.path.join(LOG_FOLDER, 'app.log'),
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s]: %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)

# --- Session Control ---
session_active = False
paused = False

# --- Database Setup ---
DB_FOLDER = resource_path('data')
DB_PATH = os.path.join(DB_FOLDER, 'data.db')

def init_db():
    if not os.path.exists(DB_FOLDER):
        os.makedirs(DB_FOLDER, exist_ok=True)
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT UNIQUE,
            total_questions INTEGER,
            total_time_seconds INTEGER
        )
    ''')
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS questions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_id INTEGER,
            question_number INTEGER,
            time_taken_seconds INTEGER,
            FOREIGN KEY(session_id) REFERENCES sessions(id)
        )
    ''')
    conn.commit()
    conn.close()
    logging.info("Database initialized")

init_db()

# --- Routes ---

@app.route('/session_status', methods=['POST'])
def session_status():
    global session_active, paused
    data = request.get_json()
    status = data.get('status')

    if status == "start":
        session_active = True
        paused = False
        logging.info("[Session] Started")
    elif status == "pause":
        paused = True
        logging.info("[Session] Paused")
    elif status == "resume":
        paused = False
        logging.info("[Session] Resumed")
    elif status == "stop":
        session_active = False
        paused = False
        logging.info("[Session] Stopped")

    return jsonify({"message": "Status updated"}), 200

@app.route('/submit_question', methods=['POST'])
def submit_question():
    global session_active, paused
    if not session_active or paused:
        logging.warning("[Submit Blocked] Session inactive or paused")
        return jsonify({"error": "Session inactive or paused. Data not accepted."}), 403

    data = request.get_json()
    logging.info(f"[Question Received] {data}")

    return jsonify({"message": "Question recorded"}), 200

@app.route('/save_session', methods=['POST'])
def save_session():
    data = request.get_json()
    timestamp = data['timestamp']
    total_questions = data['total_questions']
    total_time_seconds = data['total_time_seconds']
    questions = data['questions']

    if total_questions == 0:
        logging.warning("[Save Skipped] No questions were completed.")
        return jsonify({'success': False, 'message': 'No questions completed. Session not saved.'}), 400

    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    # Save session
    cursor.execute('INSERT INTO sessions (timestamp, total_questions, total_time_seconds) VALUES (?, ?, ?)',
                   (timestamp, total_questions, total_time_seconds))
    session_id = cursor.lastrowid

    # Save questions
    for q in questions:
        cursor.execute('INSERT INTO questions (session_id, question_number, time_taken_seconds) VALUES (?, ?, ?)',
                       (session_id, q['question_number'], q['time_taken_seconds']))
    conn.commit()
    conn.close()

    logging.info(f"[Session Saved] Timestamp: {timestamp}, Questions: {total_questions}, Total Time: {total_time_seconds}s")

    return jsonify({'success': True, 'redirect_url': f'/report/{timestamp}'})

@app.route('/report/<timestamp>')
def report(timestamp):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    cursor.execute('SELECT id, total_questions, total_time_seconds FROM sessions WHERE timestamp = ?', (timestamp,))
    session = cursor.fetchone()

    if not session:
        logging.warning(f"[Report] No session found for timestamp: {timestamp}")
        return render_template('report.html', empty_session=True)

    session_id, total_questions, total_time_seconds = session

    cursor.execute('SELECT question_number, time_taken_seconds FROM questions WHERE session_id = ? ORDER BY question_number', (session_id,))
    questions = cursor.fetchall()

    conn.close()

    if total_time_seconds == 0:
        avg_speed = 0
    else:
        avg_speed = (total_questions / total_time_seconds) * 60
        avg_speed = round(avg_speed, 2)

    return render_template('report.html', 
                           timestamp=timestamp, 
                           total_questions=total_questions, 
                           total_time_seconds=total_time_seconds,
                           avg_speed=avg_speed,
                           questions=questions,
                           empty_session=False)

@app.route("/start_session")
def main():
    return render_template('session.html')

@app.route('/results')
def results():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    cursor.execute('SELECT timestamp, total_questions, total_time_seconds FROM sessions ORDER BY timestamp')
    sessions = cursor.fetchall()
    conn.close()

    labels = []
    times = []
    speeds = []
    total_questions_list = []

    for timestamp, total_questions, total_time_seconds in sessions:
        try:
            ts_int = int(timestamp)
            dt = datetime.fromtimestamp(ts_int / 1000)
            readable_date = dt.strftime('%d %b %Y')
        except Exception as e:
            readable_date = str(timestamp)

        labels.append(readable_date)
        times.append(total_time_seconds)
        total_questions_list.append(total_questions)
        if total_time_seconds == 0:
            speed = 0
        else:
            speed = (total_questions / total_time_seconds) * 60
        speeds.append(round(speed, 2))

    return render_template('results.html', labels=labels, times=times, speeds=speeds, total_questions_list=total_questions_list, on_results_page=True)

@app.route("/")
def home():
    return render_template('home.html')

SERVER_SECRET_KEY = "5509"

@app.route('/stop', methods=['POST'])
def stop_server():
    key = request.form.get('key')

    if key != SERVER_SECRET_KEY:
        logging.warning("[Stop Attempt] Forbidden: wrong key")
        abort(403)

    pid = os.getpid()
    logging.info(f"[Server] Shutting down... (PID: {pid})")

    os.kill(pid, signal.SIGINT)
    return "Server shutting down..."

def open_browser_when_ready(url):
    """ Wait a bit for server to be ready, then open browser """
    time.sleep(1)  # Wait 1 second (you can adjust if needed)
    webbrowser.open(url)

# --- Main App Run ---
if __name__ == "__main__":
    port = 8081
    url = f"http://127.0.0.1:{port}/"
    threading.Thread(target=open_browser_when_ready, args=(url,)).start()
    app.run(host="127.0.0.1", port=port)
