@echo off
cd /d %~dp0
echo Launching AQL to MongoDB Translator...

REM Activate venv if needed here

REM Install dependencies
pip install -r requirements.txt

REM Start Flask server
start http://127.0.0.1:5000
start web\basic.html
python web\server.py
