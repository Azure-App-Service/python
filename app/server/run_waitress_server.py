import os
from waitress import serve
from server import app

serve(app, host="127.0.0.1", port=8080)
