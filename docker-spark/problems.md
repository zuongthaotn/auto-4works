Da cai dat thanh cong spark master va worker tren docker. Tuy nhien khong the ket noi duoc python notebook tu may local vao master hoac worker
- spark = SparkSession.builder.appName("HelloWorld").remote("sc://127.0.0.1:7077").getOrCreate()
    load mai ko ket noi dc
- spark = SparkSession.builder.appName("HelloWorld").master("spark://127.0.0.1:7077").getOrCreate()
/mnt/shares/dae-test-projects/.venv/lib/python3.11/site-packages/pyspark/sql/session.py:472, in SparkSession.Builder.getOrCreate(self)
    466 if (
    467     SparkContext._active_spark_context is None
    468     and SparkSession._instantiatedSession is None
    469 ):
    470     url = opts.get("spark.remote", os.environ.get("SPARK_REMOTE"))
--> 472     if url.startswith("local"):
    473         os.environ["SPARK_LOCAL_REMOTE"] = "1"
    474         RemoteSparkSession._start_connect_server(url, opts)

AttributeError: 'NoneType' object has no attribute 'startswith'