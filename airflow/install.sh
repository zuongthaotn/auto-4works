#!/bin/bash
#
export AIRFLOW_HOME=~/airflow
#
python -m venv ./.venv
#
source ./.venv/bin/activate
#
pip3 install apache-airflow
#
# airflow db init
# airflow users  create --role Admin --username admin --email admin --firstname admin --lastname admin --password admin
# airflow webserver -p 8080
# airflow scheduler