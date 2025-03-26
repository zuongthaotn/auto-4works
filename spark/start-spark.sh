# export PATH = $PATH:/mnt/shares/auto-4works/spark/spark_home/bin
export SPARK_HOME=/mnt/shares/auto-4works/spark/spark_home
export PYTHONPATH=$SPARK_HOME/python
#
# spark_home/bin/spark-shell --version
# spark_home/bin/spark-shell 
./spark_home/sbin/start-master.sh
./spark_home/sbin/start-worker.sh spark:127.0.0.1:7077