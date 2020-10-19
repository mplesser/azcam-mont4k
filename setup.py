from setuptools import setup, find_packages

requirements = [
    "numpy",
    "ipython",
    "matplotlib",
    "scipy",
    "flask",
    "azcam",
    "azcam-focus",
    "azcam-observe",
]

with open("README.md", "r") as fh:
    long_description = fh.read()

setup(
    name="azcam-mont4k",
    version="20.3",
    description="azcam environment for Kuiper 61-inch",
    long_description=long_description,
    author="Michael Lesser",
    author_email="mlesser@arizona.edu",
    keywords="python parameters",
    packages=find_packages(),
    zip_safe=False,
    install_requires=[requirements],
)
