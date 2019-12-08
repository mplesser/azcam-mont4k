from setuptools import setup, find_packages

setup(
    name="azcam-mont4k",
    version="19.1",
    description="AzCam files for UA's Kuiper telescope Mont4k camera",
    author="Michael Lesser",
    author_email="mlesser@email.arizona.edu",
    url="http://www.itl.arizona.edu/doku.php?id=azcam",
    keywords="ccd imaging astronomy",
    packages=find_packages(),
    zip_safe=False,
    install_requires=[],
)
