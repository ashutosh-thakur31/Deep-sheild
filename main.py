"""
DeepShield - Root Application Entry Point
Enables running `python main.py` directly from the project root.
"""
import os
import sys

# Add backend directory to sys.path
backend_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "backend")
if backend_dir not in sys.path:
    sys.path.insert(0, backend_dir)

from app import create_app

app = create_app()

if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  DeepShield Backend API Server")
    print("  Listening on http://localhost:5000")
    print("=" * 60 + "\n")
    app.run(host="0.0.0.0", port=5000, debug=False)

