from flask import Flask
app = Flask(__name__, static_folder='/opt/defaultsite')

@app.route('/')
def root():
    return app.send_static_file('hostingstart.html')
