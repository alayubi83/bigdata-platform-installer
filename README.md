# Big Data Platform Installer

Production-ready installer for a standalone Big Data platform on Ubuntu 22.04 LTS.

---

## Supported Software

| Component | Version |
|----------|---------|
| Ubuntu | 22.04 LTS |
| OpenJDK | 8u492 |
| Hadoop | 3.2.4 |
| Hive | 2.3.9 |
| Spark | 2.4.8 |
| Scala | 2.11.12 |
| PostgreSQL | 15 |

---

## Features

- Modular installer
- Automatic dependency installation
- Automatic environment configuration
- Hadoop configuration
- Hive Metastore configuration
- Spark configuration
- Spark History Server
- HDFS initialization
- YARN initialization
- Validation script
- Logging
- Idempotent installation
- Resume installation
- Service management

---

## Directory Structure

```
bigdata-platform-installer
│
├── install.sh
├── uninstall.sh
├── version.conf
├── README.md
│
├── config
│   ├── hadoop
│   ├── hive
│   ├── postgres
│   └── spark
│
├── downloads
│
├── logs
│
└── scripts
    ├── common.sh
    ├── downloader.sh
    ├── environment.sh
    ├── menu.sh
    ├── service.sh
    ├── validator.sh
    │
    └── install
        ├── 01_prerequisite.sh
        ├── 02_java.sh
        ├── 03_postgresql.sh
        ├── 04_hadoop.sh
        ├── 05_hive.sh
        ├── 06_spark.sh
        ├── 07_configuration.sh
        ├── 08_initialize.sh
        ├── 09_start_services.sh
        ├── 10_validation.sh
        └── 11_finish.sh
```

---

## Installation

```bash
chmod +x install.sh
./install.sh
```

---

## Validation

```bash
java -version

hdfs dfs -ls /

hdfs dfsadmin -report

yarn node -list

mapred job -list-all

hive

spark-shell

spark-submit

pyspark
```

---

## Web UI

| Service | URL |
|---------|-----|
| NameNode | http://localhost:9870 |
| ResourceManager | http://localhost:8088 |
| JobHistory | http://localhost:19888 |
| Spark History | http://localhost:18080 |

---

## License

MIT License
