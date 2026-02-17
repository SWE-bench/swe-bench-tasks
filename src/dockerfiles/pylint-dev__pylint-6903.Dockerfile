
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

RUN <<EOF_c5e0c1364d92
#!/bin/bash
set -euxo pipefail
source /opt/miniconda3/bin/activate
cat <<'EOF_160da9470e71' > /root/environment.yml
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
      - astroid==2.11.7
      - black==22.6.0
      - cachetools==5.5.0
      - certifi==2024.8.30
      - cfgv==3.4.0
      - chardet==5.2.0
      - charset-normalizer==3.4.0
      - cli-ui==0.17.2
      - click==8.1.7
      - click-default-group==1.2.4
      - colorama==0.4.6
      - contributors-txt==1.0.0
      - coverage==6.5.0
      - coveralls==3.3.1
      - dill==0.3.9
      - distlib==0.3.9
      - docopt==0.6.2
      - exceptiongroup==1.2.2
      - execnet==2.1.1
      - filelock==3.16.1
      - flake8==5.0.4
      - flake8-typing-imports==1.13.0
      - gprof2dot==2024.6.6
      - identify==2.6.1
      - idna==3.10
      - incremental==24.7.2
      - iniconfig==2.0.0
      - isort==5.10.1
      - jinja2==3.1.4
      - lazy-object-proxy==1.10.0
      - markupsafe==3.0.2
      - mccabe==0.7.0
      - mypy==0.971
      - mypy-extensions==1.0.0
      - nodeenv==1.9.1
      - packaging==24.1
      - pathspec==0.12.1
      - platformdirs==4.3.6
      - pluggy==1.5.0
      - pre-commit==2.21.0
      - py==1.11.0
      - py-cpuinfo==9.0.0
      - pycodestyle==2.9.1
      - pyflakes==2.5.0
      - pyproject-api==1.8.0
      - pytest==7.4.4
      - pytest-benchmark==4.0.0
      - pytest-cov==3.0.0
      - pytest-forked==1.6.0
      - pytest-profiling==1.7.0
      - pytest-timeout==2.3.1
      - pytest-xdist==2.5.0
      - pyyaml==6.0.2
      - requests==2.32.3
      - schema==0.7.7
      - six==1.16.0
      - tabulate==0.8.10
      - tbump==6.9.0
      - tomli==2.0.2
      - tomlkit==0.13.2
      - towncrier==22.12.0
      - tox==4.23.2
      - types-pkg-resources==0.1.3
      - typing-extensions==4.12.2
      - unidecode==1.3.8
      - urllib3==2.2.3
      - virtualenv==20.27.0
      - wrapt==1.16.0
prefix: /opt/miniconda3/envs/testbed

EOF_160da9470e71
conda env create -f /root/environment.yml
conda activate testbed
EOF_c5e0c1364d92


RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" > /root/.bashrc

RUN <<EOF_3fe21dacd846
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/pylint-dev/pylint /testbed
chmod -R 777 /testbed
cd /testbed
git reset --hard ca80f03a43bc39e4cc2c67dc99817b3c9f13b8a6
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci ca80f03a43bc39e4cc2c67dc99817b3c9f13b8a6)
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
python -m pip install -e .

# Configure git
git config --global user.email setup@swebench.com
git config --global user.name SWE-bench
git commit --allow-empty -am SWE-bench
EOF_3fe21dacd846


WORKDIR /testbed/
