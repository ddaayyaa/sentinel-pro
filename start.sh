#!/bin/bash
echo "=========================================="
echo " SENTINEL PRO v2.0.0 - Starting Server"
echo "=========================================="
cd "$(dirname "$0")/backend"
if [ ! -d "venv" ]; then
    echo "[1/3] Creating virtual environment..."
    python3 -m venv venv
fi
echo "[2/3] Installing dependencies..."
source venv/bin/activate
pip install -r requirements.txt --quiet
echo "[3/3] Starting Flask server..."
echo ""
echo " Server: http://localhost:5000"
echo " Admin:  admin / admin123"
echo ""
python app.py
