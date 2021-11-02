# Instalation

## URL

```
https://sourceforge.net/projects/mageck/files/0.5/
https://sourceforge.net/p/mageck/wiki/Home/?version=25
```

## Install

Need to load newer version of GCC

```
module load gcc
python3 -m venv venv
. venv/bin/activate
pip install numpy
pip install --upgrade pip
pip install  scipy
tar xvfz mageck-0.5.9.4.tar.gz 
cd mageck-0.5.9.4/
python setup.py install
cd ..
```