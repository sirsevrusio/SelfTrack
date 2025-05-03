from importlib import metadata
from importlib.metadata import PackageNotFoundError
import subprocess
import importlib
import time
import getpass
import shutil
import platform
import pkgutil
import os
import sys

dependencies = {
    "flask": None,
    "requests": None,
    "pyinstaller": None,
    "dulwich": "dulwich"
}

def is_installed(lib_name):
    """
    Function to check that a library is installed or not.

    Arguments: (
        - lib_name --> str
    )

    Output : (
        - status --> Boolean
        - version --> None OR str
    )
    """
    try:
        lib_version = metadata.version(lib_name)
        return True, lib_version
    except PackageNotFoundError:
        return False, None
    
def resolv_deps(lib_name):
    found, version = is_installed(lib_name)
    if found:
        print(f"{lib_name}::{version} INSTALLED ALREADY ✅")
        return True
    else:
        print(f"{lib_name} NOT INSTALLED, Installing it")
        command = [sys.executable, "-m", "pip", "install", lib_name]
        install = subprocess.run(command, text=True, stderr=subprocess.PIPE, stdout=subprocess.PIPE)
        if install.returncode == 0:
            check, version = is_installed(lib_name)
            if check:
                print(f"{lib_name}::{version} INSTALLED ✅")
                return True
            else:
                print(f"{lib_name} Not Installed ❌\nMESSAGE : This is the situation where you have installed the library but it is not detected or found by python. You have to solve it manually, srry.")
                return False
        else:
            err_output = install.stderr.split('\n')
            if any("No matching distribution found".lower() in line.lower() for line in err_output):
                print(f"{lib_name} INVALID LIBRARY ❌\nMESSAGE : {lib_name} is an invalid library, please report this to the developer at github's repository!")
                return False
            error_path = os.path.abspath("error.txt")
            print(f"{lib_name} INSTALLATION FAILED ❌\nMESSAGE : An error occured during installtion, I am dumping the output at your screen and also at {error_path}, check it!")
            with open(error_path, "w") as file:
                print(install.stderr)
                file.write(install.stderr)
            return False

def Import(library):
    try:
        lib = importlib.import_module(library)
        globals()[library] = lib
        if hasattr(lib, '__path__'):
            for loader, module_name, is_pkg in pkgutil.walk_packages(lib.__path__, library + '.'):
                globals()[module_name] = __import__(module_name)
        print(f"{library} OK ✅")
    except (ModuleNotFoundError, ImportError):
        print(f"{library} NOT FOUND, Trying to install ⚠️")
        deps_status = resolv_deps(library)
        if not deps_status:
            print(f"{library} Unable to Install ! Setup can't continue further, I am going towards a crash.")
            sys.exit(-1)
        return None

def init(libraries):
    print("-" * 5 + "\tRESOLVING LIBRARIES 🍵")
    for lib in libraries:
        if lib:
            Import(lib)
    print("-" * 5 + "\tLIBRARIES RESOLVED ✅")

def get_os():
    return platform.system()

def clone_and_build():
    repository_url = "https://github.com/sirsevrusio/selftrack"
    clone_dir = "source"
    print("-" * 5 + "\tDOWNLOADING SOURCE CODE TO BUILD")
    try:
        dulwich.porcelain.clone(repository_url, f"./{clone_dir}")
    except FileExistsError:
        shutil.rmtree(os.path.abspath(clone_dir))
        dulwich.porcelain.clone(repository_url, f"./{clone_dir}")
    currdir = os.curdir
    os.chdir(clone_dir)
    print("\nSOURCE CODE DOWNLOADED SUCCESSFULLY....")
    print(f"\nENTERING BUILD DIR : {clone_dir}")

    templates_path = os.path.abspath("templates")
    data_path = os.path.abspath("static")

    if get_os() == "Windows":
        print(f"OS TYPE : WINDOWS {platform.machine()} {platform.architecture()[0]}")
        sep = ";"
    elif get_os() == "Linux":
        print(f"OS TYPE : LINUX {platform.machine()} {platform.architecture()[0]}")
        sep = ":"
    elif get_os() == "Darwin":
        print(f"OS TYPE : MACINTOSH {platform.machine()} {platform.architecture()[0]}")
        sep = ":"
    build_command = [
        "pyinstaller",
        "app.py",
        "--onefile",
        '--add-data',
        f'{templates_path}{sep}templates',
        '--add-data',
        f"{data_path}{sep}static",
        '--noconsole',
        '--name=SelfTrack'       
        ]
    t_start = time.time()
    print("BUILD STARTED, PLEASE WAIT PATIENTLY, IT WON'T TAKE LONG")
    result = subprocess.run(build_command, text=True, capture_output=True)
    t_end = time.time()
    if result.returncode == 0:
        print(f"Build Successfull, TIME ELAPSED : {int(t_end - t_start) // 60} Min {int(t_end - t_start) % 60} sec")
        return True
    else:
        print("BUILD FAILED")
        print(f"STDOUT : \n", result.stdout)
        print(f"STDERR :\n", result.stderr)
        return False

def create_dirs(dirs):
    try:
        for i in dirs:
            os.makedirs(i, exist_ok=True)
            print(f"DIR -> {i} CREATED OK")
        return True, None
    except Exception as e:
        return False, e

def execute(command):
    try:
        result = subprocess.run(command, text=True, capture_output=True)
        if result.returncode == 0:
            return True, result.stdout
        elif "permission denied" in result.stderr.lower():
            return False, "PERMISSION ERROR"
        else:
            return False, result.stderr
    except PermissionError:
        print("[ERROR] PermissionError ! Make sure you have permissions to make changes, or report this on https://github.com/sirsevrusio/selftrack Immediately if not fixed.")

def install():
    print("-" * 5 + "\tINSTALLATION STARTED")
    home_dir = os.path.expanduser("~")
    dirs = {
        "install_dir": os.path.join(home_dir, ".selftrack")
    }
    create_dirs(dirs.values())
    print("COPYING FILES")
    if get_os() == "Windows":
        ext = ".exe"
    else:
        ext = ""
    shutil.copy(os.path.join("dist", f"SelfTrack{ext}"), os.path.join(dirs["install_dir"], f"SelfTrack{ext}"))
    print("COPIED FILES SUCCESSFULLY...")
    print(f"You can run the application from {os.path.join(dirs["install_dir"], f"SelfTrack{ext}")}")

if __name__ == "__main__":
    for dep_name, import_name in dependencies.items():
        resolv_deps(dep_name)
    init(dependencies.values())
    clone_and_build()
    install()