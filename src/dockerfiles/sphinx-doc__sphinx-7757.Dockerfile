
FROM --platform=linux/amd64 ubuntu:jammy

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt update && apt install -y \
wget \
git \
build-essential \
libffi-dev \
libtiff-dev \
python3 \
python3-pip \
python-is-python3 \
jq \
curl \
locales \
locales-all \
tzdata \
&& rm -rf /var/lib/apt/lists/*

# Download and install conda
RUN wget 'https://repo.anaconda.com/miniconda/Miniconda3-py311_23.11.0-2-Linux-x86_64.sh' -O miniconda.sh \
    && bash miniconda.sh -b -p /opt/miniconda3
# Add conda to PATH
ENV PATH=/opt/miniconda3/bin:$PATH
# Add conda to shell startup scripts like .bashrc (DO NOT REMOVE THIS)
RUN conda init --all
RUN conda config --append channels conda-forge

RUN adduser --disabled-password --gecos 'dog' nonroot

RUN <<EOF_e254ba5bb493
#!/bin/bash
set -euxo pipefail
source /opt/miniconda3/bin/activate
cat <<'EOF_02c9813dc988' > /root/environment.yml
name: testbed
channels:
  - defaults
  - conda-forge
dependencies:
  - _libgcc_mutex=0.1=main
  - _openmp_mutex=5.1=1_gnu
  - ca-certificates=2024.9.24=h06a4308_0
  - ld_impl_linux-64=2.40=h12ee557_0
  - libffi=3.4.4=h6a678d5_1
  - libgcc-ng=11.2.0=h1234567_1
  - libgomp=11.2.0=h1234567_1
  - libstdcxx-ng=11.2.0=h1234567_1
  - ncurses=6.4=h6a678d5_0
  - openssl=3.0.15=h5eee18b_0
  - pip=24.2=py39h06a4308_0
  - python=3.9.20=he870216_1
  - readline=8.2=h5eee18b_0
  - setuptools=75.1.0=py39h06a4308_0
  - sqlite=3.45.3=h5eee18b_0
  - tk=8.6.14=h39e8969_0
  - tzdata=2024b=h04d1e81_0
  - wheel=0.44.0=py39h06a4308_0
  - xz=5.4.6=h5eee18b_1
  - zlib=1.2.13=h5eee18b_1
  - pip:
      - alabaster==0.7.11
      - babel==2.16.0
      - cachetools==5.5.0
      - certifi==2024.8.30
      - chardet==5.2.0
      - charset-normalizer==3.4.0
      - colorama==0.4.6
      - coverage==7.6.4
      - cython==3.0.11
      - distlib==0.3.9
      - docutils==0.21.2
      - exceptiongroup==1.2.2
      - filelock==3.16.1
      - html5lib==1.1
      - idna==3.10
      - imagesize==1.4.1
      - iniconfig==2.0.0
      - jinja2==2.11.3
      - markupsafe==2.0.1
      - packaging==24.1
      - platformdirs==4.3.6
      - pluggy==1.5.0
      - pygments==2.18.0
      - pyproject-api==1.8.0
      - pytest==8.3.3
      - pytest-cov==5.0.0
      - requests==2.32.3
      - six==1.16.0
      - snowballstemmer==2.2.0
      - tomli==2.0.2
      - tox==4.16.0
      - tox-current-env==0.0.11
      - typed-ast==1.5.5
      - urllib3==2.2.3
      - virtualenv==20.26.6
      - webencodings==0.5.1
prefix: /opt/miniconda3/envs/testbed

EOF_02c9813dc988
conda env create -f /root/environment.yml
conda activate testbed
EOF_e254ba5bb493


RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" > /root/.bashrc

RUN <<EOF_e6125b42af59
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/sphinx-doc/sphinx /testbed
chmod -R 777 /testbed
cd /testbed
git reset --hard 212fd67b9f0b4fae6a7c3501fdf1a9a5b2801329
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci 212fd67b9f0b4fae6a7c3501fdf1a9a5b2801329)
git tag -l | while read tag; do TAG_COMMIT=$(git rev-list -n 1 "$tag"); TAG_TIME=$(git show -s --format=%ci "$TAG_COMMIT"); if [[ "$TAG_TIME" > "$TARGET_TIMESTAMP" ]]; then git tag -d "$tag"; fi; done
git reflog expire --expire=now --all
git gc --prune=now --aggressive
AFTER_TIMESTAMP=$(date -d "$TARGET_TIMESTAMP + 1 second" '+%Y-%m-%d %H:%M:%S')
COMMIT_COUNT=$(git log --oneline --all --since="$AFTER_TIMESTAMP" | wc -l)
[ "$COMMIT_COUNT" -eq 0 ] || exit 1
cd - || true
source /opt/miniconda3/bin/activate
conda activate testbed
echo "Current environment: $CONDA_DEFAULT_ENV"
cd /testbed
sed -i 's/pytest/pytest -rA/' tox.ini
sed -i 's/Jinja2>=2.3/Jinja2<3.0/' setup.py
sed -i 's/sphinxcontrib-applehelp/sphinxcontrib-applehelp<=1.0.7/' setup.py
sed -i 's/sphinxcontrib-devhelp/sphinxcontrib-devhelp<=1.0.5/' setup.py
sed -i 's/sphinxcontrib-qthelp/sphinxcontrib-qthelp<=1.0.6/' setup.py
sed -i 's/alabaster>=0.7,<0.8/alabaster>=0.7,<0.7.12/' setup.py
sed -i "s/'packaging',/'packaging', 'markupsafe<=2.0.1',/" setup.py
sed -i 's/sphinxcontrib-htmlhelp/sphinxcontrib-htmlhelp<=2.0.4/' setup.py
sed -i 's/sphinxcontrib-serializinghtml/sphinxcontrib-serializinghtml<=1.1.9/' setup.py
python -m pip install -e .[test]

# Configure git
git config --global user.email setup@swebench.com
git config --global user.name SWE-bench
git commit --allow-empty -am SWE-bench
EOF_e6125b42af59


WORKDIR /testbed/
