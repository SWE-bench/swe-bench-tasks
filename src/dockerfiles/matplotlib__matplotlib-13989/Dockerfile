
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

RUN <<EOF_9990e3abd723
#!/bin/bash
set -euxo pipefail
source /opt/miniconda3/bin/activate
cat <<'EOF_18a7da002ba8' > /root/environment.yml
name: testbed
channels:
  - defaults
  - conda-forge
dependencies:
  - _libgcc_mutex=0.1=main
  - _openmp_mutex=5.1=1_gnu
  - ca-certificates=2025.2.25=h06a4308_0
  - certifi=2022.12.7=py37h06a4308_0
  - ld_impl_linux-64=2.40=h12ee557_0
  - libffi=3.4.4=h6a678d5_1
  - libgcc-ng=11.2.0=h1234567_1
  - libgomp=11.2.0=h1234567_1
  - libstdcxx-ng=11.2.0=h1234567_1
  - ncurses=6.4=h6a678d5_0
  - openssl=1.1.1w=h7f8727e_0
  - pip=22.3.1=py37h06a4308_0
  - python=3.7.16=h7a1cb2a_0
  - readline=8.2=h5eee18b_0
  - setuptools=65.6.3=py37h06a4308_0
  - sqlite=3.45.3=h5eee18b_0
  - tk=8.6.14=h39e8969_0
  - wheel=0.38.4=py37h06a4308_0
  - xz=5.6.4=h5eee18b_1
  - zlib=1.2.13=h5eee18b_1
  - pip:
      - cachetools==5.5.2
      - chardet==5.2.0
      - charset-normalizer==3.4.1
      - codecov==2.1.13
      - colorama==0.4.6
      - coverage==7.2.7
      - cycler==0.11.0
      - distlib==0.3.9
      - exceptiongroup==1.2.2
      - execnet==2.0.2
      - filelock==3.12.2
      - idna==3.10
      - importlib-metadata==6.7.0
      - iniconfig==2.0.0
      - kiwisolver==1.4.5
      - numpy==1.21.6
      - packaging==24.0
      - pillow==9.5.0
      - platformdirs==4.0.0
      - pluggy==1.2.0
      - pyparsing==3.1.4
      - pyproject-api==1.5.3
      - pytest==7.4.4
      - pytest-cov==4.1.0
      - pytest-faulthandler==2.0.1
      - pytest-rerunfailures==13.0
      - pytest-timeout==2.3.1
      - pytest-xdist==3.5.0
      - python-dateutil==2.9.0.post0
      - requests==2.31.0
      - six==1.17.0
      - tomli==2.0.1
      - tornado==6.2
      - tox==4.8.0
      - typing-extensions==4.7.1
      - urllib3==2.0.7
      - virtualenv==20.26.6
      - zipp==3.15.0
prefix: /opt/miniconda3/envs/testbed

EOF_18a7da002ba8
conda env create -f /root/environment.yml
conda activate testbed
EOF_9990e3abd723


RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" > /root/.bashrc

RUN <<EOF_f97ba1f250ad
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/matplotlib/matplotlib /testbed
chmod -R 777 /testbed
cd /testbed
git reset --hard a3e2897bfaf9eaac1d6649da535c4e721c89fa69
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci a3e2897bfaf9eaac1d6649da535c4e721c89fa69)
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
apt-get -y update && apt-get -y upgrade && apt-get install -y imagemagick ffmpeg libfreetype6-dev pkg-config
QHULL_URL="http://www.qhull.org/download/qhull-2020-src-8.0.2.tgz"
QHULL_TAR="/tmp/qhull-2020-src-8.0.2.tgz"
QHULL_BUILD_DIR="/testbed/build"
wget -O "$QHULL_TAR" "$QHULL_URL"
mkdir -p "$QHULL_BUILD_DIR"
tar -xvzf "$QHULL_TAR" -C "$QHULL_BUILD_DIR"
python -m pip install -e .

# Configure git
git config --global user.email setup@swebench.com
git config --global user.name SWE-bench
git commit --allow-empty -am SWE-bench
EOF_f97ba1f250ad


WORKDIR /testbed/
