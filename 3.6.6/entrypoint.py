import subprocess
import glob
import os

HOME_SITE="/home/site/wwwroot"
DEFAULT_SITE="/opt/defaultsite"

# Temp patch. Remove when Kudu script is available.
os.environ["PYTHONPATH"] = HOME_SITE + "/antenv3.6/lib/python3.6/site-packages"

def subprocess_cmd(command):
    print ('executing:')
    print (command)

    process = subprocess.Popen(command,stdout=subprocess.PIPE, shell=True)
    proc_stdout = process.communicate()[0].strip()
    print (proc_stdout.decode("utf-8"))

## Check for custom startup command
def custom_check():
    return None

## Django check: If 'wsgi.py' is provided, identify as Django. 
def check_django():
    wsgi_modules = glob.glob(HOME_SITE+'/**/wsgi.py', recursive=True)
    if len(wsgi_modules)==0:
        return None
    else:
        return wsgi_modules[0][1:-3].replace('/','.')
    return None

## Flask check: If 'application.py' is provided or a .py module is present, identify as Flask.
def check_flask():
    
    py_modules = glob.glob(HOME_SITE+'/*.py')
    if len(py_modules) == 0:
        return None
    for module in py_modules: 
        if module[-14:] == 'application.py':
            print ('found flask app')
            return 'application:app'

    return py_modules[0][len(HOME_SITE)+1:-3].replace('/','.')+':app'

def start_server():
    
    cmd = custom_check()
    if cmd is not None: 
        subprocess_cmd('. antenv3.6/bin/activate')
        subprocess_cmd(
                'GUNICORN_CMD_ARGS="--bind=0.0.0.0" ' + cmd
               )

    cmd = check_django()
    if cmd is not None:
        subprocess_cmd('. antenv3.6/bin/activate')
        subprocess_cmd(
                'GUNICORN_CMD_ARGS="--bind=0.0.0.0" gunicorn mysite.wsgi:application'
               )

    cmd = check_flask()
    if cmd is not None:
        subprocess_cmd('. antenv3.6/bin/activate')
        subprocess_cmd(
                'GUNICORN_CMD_ARGS="--bind=0.0.0.0" gunicorn ' + cmd
               )
    else:          
        print(' starting default app')
        subprocess_cmd(
              'GUNICORN_CMD_ARGS="--bind=0.0.0.0 --chdir /opt/defaultsite" gunicorn application:app'
              )    

subprocess_cmd('python --version')
subprocess_cmd('pip --version')
start_server()
