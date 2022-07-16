import os
import re
import sys
import glob
import time
import subprocess
from jinja2 import Environment, FileSystemLoader, select_autoescape


# Should existing files be overwritten
OVERWRITE = False

# Map of jinja variables to environment variables
jinja_to_env = {
    "golly_wiki_pod_install_dir": "POD_GOLLY_WIKI_DIR",
    "golly_wiki_server_name": "POD_GOLLY_WIKI_TLD",
    # docker-compose:
    "golly_wiki_vpn_ip_addr": "POD_GOLLY_WIKI_VPN_IP_ADDR",
    "golly_wiki_mw_secretkey": "POD_GOLLY_WIKI_MW_SECRET_KEY",
    "golly_wiki_mysql_password": "POD_GOLLY_WIKI_MYSQL_PASSWORD",
    # mediawiki: (no templates)
    # aws: (no templates)
}

scripts_dir = os.path.dirname(os.path.abspath(__file__))
repo_root = os.path.abspath(os.path.join(scripts_dir, '..'))


def check_env_vars():
    env_var_list = jinja_to_env.values()
    nerrs = 0
    print("Checking environment variables")
    for env_var in env_var_list:
        try:
            _ = os.environ[env_var]
        except KeyError:
            nerrs += 1
            print(f"Missing environment variable: {env_var}")
    if nerrs > 0:
        raise Exception("Environment variables check did not succeed")


def main():

    check_env_vars()

    ignore_list = ['environment']

    p = os.path.join(repo_root,'**','*.j2')
    template_files = glob.glob(p, recursive=True)

    print(f"Found {len(template_files)} template files in {repo_root}:")
    print("\n".join([f"- {j}" for j in template_files]))
    print("")
    
    for template_file in template_files:
        
        # get paths and filenames for template file and output file
        tpath = os.path.abspath(template_file)
        tdir, tname = os.path.split(tpath)
        rname = tname[:-3]
        rpath = os.path.join(tdir, rname)

        if rname in ignore_list:
            print(f"\nSkipping template on ignore list: {tname}\n")
            continue

        env = Environment(loader=FileSystemLoader(tdir))
    
        print(f"Rendering template {tname}:")
        print(f"    Template path: {tpath}")
        print(f"    Output path: {rpath}")

        jinja_vars = {}
        for k, v in jinja_to_env.items():
            jinja_vars[k] = os.environ[v]

        content = env.get_template(tname).render(jinja_vars)
    
        # Write to file
        if os.path.exists(rpath) and not OVERWRITE:
            msg = "\n[!!!] Warning: file %s already exists! Skipping...\n"%(rpath)
            print(msg)
            time.sleep(1)
        else:
            with open(rpath,'w') as f:
                f.write(content)
            print(f"    Done!")
            print("")

        if rpath[-3:] == ".sh":
            subprocess.call(['chmod', '+x', rpath])
    
if __name__=="__main__":
    main()
