from setuptools import setup, find_packages

setup(
    name="nyc_taxi_pipeline",
    version="0.1",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    install_requires=[
        "watchtower",
        "opentelemetry-api",
        "opentelemetry-sdk",
        "opentelemetry-exporter-otlp"
    ],
)