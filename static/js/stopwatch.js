let timerDisplay = document.getElementById('timerDisplay');
let startBtn = document.getElementById('startBtn');
let pauseResumeBtn = document.getElementById('pauseResumeBtn');
let stopBtn = document.getElementById('stopBtn');
let questionCompleteBtn = document.getElementById('questionCompleteBtn');

let intervalId = null;
let elapsedTime = 0;
let totalElapsedTime = 0;
let isPaused = false;
let isStopped = true;
let questionCount = 0;
let questionsData = [];

function formatTime(seconds) {
  if (seconds < 60) {
    return `${seconds} seconds`;
  } else if (seconds < 3600) {
    let mins = Math.floor(seconds / 60);
    let secs = seconds % 60;
    return `${mins} minutes${secs > 0 ? ` ${secs} seconds` : ''}`;
  } else {
    let hours = Math.floor(seconds / 3600);
    let mins = Math.floor((seconds % 3600) / 60);
    return `${hours} hours${mins > 0 ? ` ${mins} minutes` : ''}`;
  }
}

function updateDisplay() {
  timerDisplay.textContent = formatTime(elapsedTime);
}

function startTimer() {
  if (!intervalId) {
    intervalId = setInterval(() => {
      if (!isPaused) {
        elapsedTime++;
        updateDisplay();
      }
    }, 1000);
  }
  isPaused = false;
  isStopped = false;
  pauseResumeBtn.textContent = "Pause";
  questionCompleteBtn.disabled = false;
  sendStatus("start");
}

function resetTimer() {
  clearInterval(intervalId);
  intervalId = null;
  elapsedTime = 0;
  totalElapsedTime = 0;
  questionCount = 0;
  questionsData = [];
  isPaused = false;
  isStopped = false;
  timerDisplay.textContent = "0 seconds";
  pauseResumeBtn.textContent = "Pause";
  questionCompleteBtn.disabled = false;
  startTimer();
}

function pauseResumeTimer() {
  if (isStopped) return;
  if (isPaused) {
    isPaused = false;
    pauseResumeBtn.textContent = 'Pause';
    questionCompleteBtn.disabled = false;
    sendStatus("resume");
  } else {
    isPaused = true;
    pauseResumeBtn.textContent = 'Resume';
    questionCompleteBtn.disabled = true;
    sendStatus("pause");
  }
}

function stopTimer() {
  if (!isStopped) {
    clearInterval(intervalId);
    intervalId = null;
    isPaused = true;
    isStopped = true;
    totalElapsedTime += elapsedTime;
    timerDisplay.textContent = `Total Time: ${formatTime(totalElapsedTime)}`;
    questionCompleteBtn.disabled = true;
    sendStatus("stop");

    if (questionCount === 0) {
      // No questions completed - show flash message
      showFlashMessage("⚠️ No questions completed. Session not saved.", 5000);

      // Reset stopwatch UI
      timerDisplay.style.display = "none";
      pauseResumeBtn.style.display = "none";
      stopBtn.style.display = "none";
      questionCompleteBtn.style.display = "none";
      startBtn.style.display = "inline-block";

      return; // DO NOT send save_session request
    }

    // Save the session
    const timestamp = Date.now();

    fetch('/save_session', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        timestamp: timestamp,
        total_questions: questionCount,
        total_time_seconds: totalElapsedTime,
        questions: questionsData
      })
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        window.location.href = data.redirect_url;
      }
    });

    // Hide stopwatch and controls again
    timerDisplay.style.display = "none";
    pauseResumeBtn.style.display = "none";
    stopBtn.style.display = "none";
    questionCompleteBtn.style.display = "none";
    startBtn.style.display = "inline-block";
  }
}

function questionComplete() {
  if (isStopped || isPaused) return;
  questionCount++;
  totalElapsedTime += elapsedTime;

  const questionEntry = {
    question_number: questionCount,
    time_taken_seconds: elapsedTime,
    time_taken_formatted: formatTime(elapsedTime)
  };
  questionsData.push(questionEntry);

  sendQuestion(questionEntry);

  elapsedTime = 0;
  updateDisplay();
}

function sendQuestion(questionData) {
  fetch('/submit_question', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(questionData)
  });
}

function sendStatus(status) {
  fetch('/session_status', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ status: status })
  });
}

// Show temporary flash message
function showFlashMessage(message, duration) {
  let flash = document.createElement('div');
  flash.textContent = message;
  flash.style.position = 'fixed';
  flash.style.top = '20px';
  flash.style.left = '50%';
  flash.style.transform = 'translateX(-50%)';
  flash.style.background = '#ffc107'; // Yellow alert color
  flash.style.color = '#000';
  flash.style.padding = '10px 20px';
  flash.style.borderRadius = '8px';
  flash.style.boxShadow = '0 2px 10px rgba(0,0,0,0.2)';
  flash.style.zIndex = 9999;
  flash.style.fontSize = '18px';
  flash.style.fontWeight = 'bold';
  flash.style.opacity = '1';
  flash.style.transition = 'opacity 1s ease';

  document.body.appendChild(flash);

  setTimeout(() => {
    flash.style.opacity = '0';
  }, duration - 1000); // start fading out 1s before removal

  setTimeout(() => {
    flash.remove();
  }, duration);
}

// Button Listeners
startBtn.addEventListener('click', function() {
  timerDisplay.style.display = "block";
  pauseResumeBtn.style.display = "inline-block";
  stopBtn.style.display = "inline-block";
  questionCompleteBtn.style.display = "inline-block";
  startBtn.style.display = "none";

  resetTimer();
});

pauseResumeBtn.addEventListener('click', pauseResumeTimer);
stopBtn.addEventListener('click', stopTimer);
questionCompleteBtn.addEventListener('click', questionComplete);

document.addEventListener('keydown', function(event) {
  if (event.key === 'Enter' && !questionCompleteBtn.disabled) {
    event.preventDefault(); // prevent form submit if any

    // Play sound
    let sound = document.getElementById('enterSound');
    sound.currentTime = 0;
    sound.play();

    // Add active animation
    questionCompleteBtn.classList.add('active');
    setTimeout(() => {
      questionCompleteBtn.classList.remove('active');
    }, 200); // match CSS animation

    questionComplete(); // Complete the question
  }
});
