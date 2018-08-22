import os
import pathlib
import subprocess


HOME_SITE="/home/site/wwwroot"
DEFAULT_SITE="/opt/defaultsite"
STARTUP_COMMAND_FILE="/opt/startup/startupCommand"
APPSVC_VIRTUAL_ENV="antenv"


def subprocess_cmd(command):
    print('executing:')
    print(command)
    result = subprocess.run(command, shell=True, stdout=subprocess.PIPE, encoding="utf-8")
    print(result.stdout)


def custom_check(_, command_file=STARTUP_COMMAND_FILE):
    """Check for a custom startup command."""
    with open(command_file, "r", encoding="utf-8") as file:
          startup_script = file.read()
    return startup_script or None


def check_django(home_site, *, app_service_venv=APPSVC_VIRTUAL_ENV):
    """Check if a 'wsgi.py' file exists for Django."""
    with os.scandir(home_site) as site_root:
        for entry in site_root:
            if not entry.name.startswith(app_service_venv) and entry.is_dir():
                print(entry.name)
                with os.scandir(home_site / entry.name) as sub_folder:
                    for sub_entry in sub_folder:
                        if sub_entry.name == 'wsgi.py' and sub_entry.is_file():
                            return f"{entry.name}.wsgi"


def check_flask(home_site):
    """Check for an 'application.py' file for Flask."""
    with os.scandir(home_site) as site_root:
        if any("appication.py" == entry.name for entry in site_root if entry.is_file()):
            print("found flask app")
            return "application:app"


def start_server(home_site, *, app_service_venv=APPSVC_VIRTUAL_ENV):
    # Temp patch. Remove when Kudu script is available.
    os.environ["PYTHONPATH"] = (home_site / app_service_venv / "lib" / "python3.6"
                                / "site-packages")
    for check in (custom_check, check_django, check_flask):
        cmd = check(home_site)
        if cmd is not None:
            subprocess_cmd(". antenv/bin/activate")
            subprocess_cmd(f'GUNICORN_CMD_ARGS="--bind=0.0.0.0" gunicorn {cmd}')
            break
    else:
        print("starting default app")
        subprocess_cmd('GUNICORN_CMD_ARGS="--bind=0.0.0.0 --chdir /opt/defaultsite"'
                       ' gunicorn application:app')


if __name__ == "__main__":
    subprocess_cmd("python --version")
    subprocess_cmd("pip --version")
    start_server(pathlib.Path(HOME_SITE))
