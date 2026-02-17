
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

RUN <<EOF_9b40b53aef0f
#!/bin/bash
set -euxo pipefail
source /opt/miniconda3/bin/activate
cat <<'EOF_6e60d6f4e355' > /root/environment.yml
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
  - sqlite=3.45.3=h5eee18b_0
  - tk=8.6.14=h39e8969_0
  - tzdata=2024b=h04d1e81_0
  - wheel=0.44.0=py39h06a4308_0
  - xz=5.4.6=h5eee18b_1
  - zlib=1.2.13=h5eee18b_1
  - pip:
      - attrs==23.1.0
      - coverage==7.6.2
      - exceptiongroup==1.1.3
      - execnet==2.0.2
      - hypothesis==6.82.6
      - iniconfig==2.0.0
      - numpy==1.25.2
      - packaging==23.1
      - pluggy==1.3.0
      - psutil==5.9.5
      - pyerfa==2.0.0.3
      - pytest==7.4.0
      - pytest-arraydiff==0.5.0
      - pytest-astropy==0.10.0
      - pytest-astropy-header==0.2.2
      - pytest-cov==4.1.0
      - pytest-doctestplus==1.0.0
      - pytest-filter-subpackage==0.1.2
      - pytest-mock==3.11.1
      - pytest-openfiles==0.5.0
      - pytest-remotedata==0.4.0
      - pytest-xdist==3.3.1
      - pyyaml==6.0.1
      - setuptools==68.0.0
      - sortedcontainers==2.4.0
      - tomli==2.0.1
prefix: /opt/miniconda3/envs/testbed

EOF_6e60d6f4e355
conda env create -f /root/environment.yml
conda activate testbed
EOF_9b40b53aef0f


RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" > /root/.bashrc

RUN <<EOF_a9f0603cdd63
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/astropy/astropy /testbed
chmod -R 777 /testbed
cd /testbed
git reset --hard a3f4ae6cd24d5ecdf49f213d77b3513dd509a06c
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci a3f4ae6cd24d5ecdf49f213d77b3513dd509a06c)
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
sed -i 's/requires = \["setuptools",/requires = \["setuptools==68.0.0",/' pyproject.toml
python -m pip install -e .[test] --verbose

# Configure git
git config --global user.email setup@swebench.com
git config --global user.name SWE-bench
git commit --allow-empty -am SWE-bench
EOF_a9f0603cdd63


WORKDIR /testbed/
