run file install.sh
modify ~/.profile
add to bottom
export SPARK_HOME=/mnt/shares/auto-4works/spark/spark_home
export PYTHONPATH=$SPARK_HOME/python
export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin

# Start spark master & worker
run file start-spark.sh


### Reference
https://www.youtube.com/watch?v=2eljVLZ7-bM&ab_channel=r2schools
https://spark.apache.org/docs/latest/quick-start.html
https://spark.apache.org/downloads.html