1. new created DAGs not show in web UI
Solution:
    Chua ro nguy nhan tuy nhien co the check theo cac steps sau:
    - airflow config get-value core dags_folder
        kiem tra config cho thu muc dags
    - airflow dags list
        kiem tra xem dag vua tao co trong list chua
    - python my_dag.py
        kiem tra loi cu phap
    - Ensure schedule_interval and start_date Are Correct
    - Trigger DAG Manually
        airflow dags trigger my_dag_id