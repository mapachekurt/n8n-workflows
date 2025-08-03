#!/bin/sh
set -e

# If persistent volume mounted at /data, ensure the DB lives there
if [ -d /data ]; then
  if [ ! -f /data/workflows.db ]; then
    echo "Indexing workflows (first run)..."
    python workflow_db.py --index
    mv workflows.db /data/
  else
    echo "Using existing indexed DB from /data"
  fi
  # Symlink so code that expects workflows.db in cwd still works
  ln -sf /data/workflows.db workflows.db
else
  # No external volume: ensure index exists locally
  if [ ! -f workflows.db ]; then
    echo "Indexing workflows (no volume)..."
    python workflow_db.py --index
  fi
fi

# Start the application
exec python run.py --host 0.0.0.0 --port 8000
