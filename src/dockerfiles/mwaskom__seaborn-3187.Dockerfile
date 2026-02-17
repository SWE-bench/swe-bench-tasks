
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

RUN <<EOF_65b245f77ae3
#!/bin/bash
set -euxo pipefail
source /opt/miniconda3/bin/activate
cat <<'EOF_720417db0f79' > /root/environment.yml
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
  - wheel=0.44.0=py39h06a4308_0
  - xz=5.4.6=h5eee18b_1
  - zlib=1.2.13=h5eee18b_1
  - pip:
      - certifi==2024.8.30
      - cfgv==3.4.0
      - charset-normalizer==3.4.0
      - contourpy==1.1.0
      - coverage==7.6.4
      - cycler==0.11.0
      - distlib==0.3.9
      - docutils==0.21.2
      - exceptiongroup==1.2.2
      - execnet==2.1.1
      - filelock==3.16.1
      - flake8==7.1.1
      - flit==3.9.0
      - flit-core==3.9.0
      - fonttools==4.42.1
      - identify==2.6.1
      - idna==3.10
      - importlib-resources==6.0.1
      - iniconfig==2.0.0
      - kiwisolver==1.4.5
      - matplotlib==3.7.2
      - mccabe==0.7.0
      - mypy==1.13.0
      - mypy-extensions==1.0.0
      - nodeenv==1.9.1
      - numpy==1.25.2
      - packaging==23.1
      - pandas==2.0.0
      - pandas-stubs==2.2.2.240807
      - pillow==10.0.0
      - platformdirs==4.3.6
      - pluggy==1.5.0
      - pre-commit==4.0.1
      - pycodestyle==2.12.1
      - pyflakes==3.2.0
      - pyparsing==3.0.9
      - pytest==8.3.3
      - pytest-cov==5.0.0
      - pytest-xdist==3.6.1
      - python-dateutil==2.8.2
      - pytz==2023.3.post1
      - pyyaml==6.0.2
      - requests==2.32.3
      - scipy==1.11.2
      - six==1.16.0
      - tomli==2.0.2
      - tomli-w==1.1.0
      - types-pytz==2024.2.0.20241003
      - typing-extensions==4.12.2
      - tzdata==2023.1
      - urllib3==2.2.3
      - virtualenv==20.27.0
      - zipp==3.16.2
prefix: /opt/miniconda3/envs/testbed

EOF_720417db0f79
conda env create -f /root/environment.yml
conda activate testbed
EOF_65b245f77ae3


RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" > /root/.bashrc

RUN <<EOF_1617e45fcf0c
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/mwaskom/seaborn /testbed
chmod -R 777 /testbed
cd /testbed
git reset --hard 22cdfb0c93f8ec78492d87edb810f10cb7f57a31
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci 22cdfb0c93f8ec78492d87edb810f10cb7f57a31)
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
python -m pip install -e .[dev]

# Configure git
git config --global user.email setup@swebench.com
git config --global user.name SWE-bench
git commit --allow-empty -am SWE-bench
EOF_1617e45fcf0c


WORKDIR /testbed/
