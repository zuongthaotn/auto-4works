
#!/bin/bash
#
spark_version=spark-3.5.5-bin-hadoop3
spark_file=$spark_version.tgz
spark_url="https://dlcdn.apache.org/spark/spark-3.5.5/spark-3.5.5-bin-hadoop3.tgz"
current_folder=$(pwd)
spark_home=spark_home
#
if [ ! -e "./$spark_file" ]; then
    wget -O ./$spark_file $spark_url
fi
#
if [ -e "./$spark_file" ]; then
    if [ -e "./$spark_home" ]; then
        rm -rf ./$spark_home
    fi
    tar -xzvf $spark_file
    mv $spark_version ./$spark_home
fi