
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

RUN <<EOF_6c7de4f258b8
#!/bin/bash
set -euxo pipefail
source /opt/miniconda3/bin/activate
cat <<'EOF_1163f8eecd5c' > /root/environment.yml
name: testbed
channels:
  - defaults
  - conda-forge
dependencies:
  - _libgcc_mutex=0.1=main
  - _openmp_mutex=5.1=1_gnu
  - atomicwrites=1.4.0=py_0
  - attrs=21.4.0=pyhd3eb1b0_0
  - backports=1.1=pyhd3eb1b0_1
  - ca-certificates=2025.12.2=h06a4308_0
  - certifi=2020.6.20=pyhd3eb1b0_3
  - configparser=4.0.2=py27_0
  - contextlib2=0.6.0.post1=pyhd3eb1b0_0
  - funcsigs=1.0.2=py27_0
  - importlib_metadata=1.3.0=py27_0
  - libffi=3.4.4=h6a678d5_1
  - libgcc=15.2.0=h69a1729_7
  - libgcc-ng=15.2.0=h166f726_7
  - libgomp=15.2.0=h4751f2c_7
  - libstdcxx=15.2.0=h39759b7_7
  - libstdcxx-ng=15.2.0=hc03a8fd_7
  - libxcb=1.17.0=h9b100fa_0
  - libzlib=1.3.1=hb25bd0a_0
  - more-itertools=5.0.0=py27_0
  - ncurses=6.5=h7934f7d_0
  - packaging=20.9=pyhd3eb1b0_0
  - pathlib2=2.3.5=py27_0
  - pip=19.3.1=py27_0
  - pluggy=0.13.1=py27_0
  - pthread-stubs=0.3=h0ce48e5_1
  - py=1.10.0=pyhd3eb1b0_0
  - pyparsing=2.4.7=pyhd3eb1b0_0
  - pytest=4.6.4=py27_0
  - python=2.7.18=h42bf7aa_3
  - readline=8.3=hc2a1206_0
  - scandir=1.10.0=pyh5d7bf9c_3
  - setuptools=44.0.0=py27_0
  - six=1.16.0=pyhd3eb1b0_1
  - sqlite=3.51.1=h3e8d24a_1
  - tk=8.6.15=h54e0aa7_0
  - wcwidth=0.2.5=pyhd3eb1b0_0
  - wheel=0.37.1=pyhd3eb1b0_0
  - xorg-libx11=1.8.12=h9b100fa_1
  - xorg-libxau=1.0.12=h9b100fa_0
  - xorg-libxdmcp=1.1.5=h9b100fa_0
  - xorg-xorgproto=2024.1=h5eee18b_1
  - zipp=0.6.0=py_0
  - zlib=1.3.1=hb25bd0a_0
  - pip:
    - backports-functools-lru-cache==1.6.6
prefix: /opt/miniconda3/envs/testbed

EOF_1163f8eecd5c
conda env create -f /root/environment.yml
conda activate testbed
EOF_6c7de4f258b8


RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" > /root/.bashrc

RUN <<EOF_161e1a09376b
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/psf/requests /testbed
chmod -R 777 /testbed
cd /testbed
git reset --hard 1ba83c47ce7b177efe90d5f51f7760680f72eda0
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci 1ba83c47ce7b177efe90d5f51f7760680f72eda0)
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
python -m pip install .

# Configure git
git config --global user.email setup@swebench.com
git config --global user.name SWE-bench
git commit --allow-empty -am SWE-bench
EOF_161e1a09376b


WORKDIR /testbed/
