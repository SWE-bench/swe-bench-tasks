
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

RUN <<EOF_eb2627606583
#!/bin/bash
set -euxo pipefail
source /opt/miniconda3/bin/activate
cat <<'EOF_402e20f4124a' > /root/environment.yml
name: testbed
channels:
  - defaults
  - conda-forge
dependencies:
  - _libgcc_mutex=0.1=main
  - _openmp_mutex=5.1=1_gnu
  - bzip2=1.0.8=h5eee18b_6
  - ca-certificates=2025.2.25=h06a4308_0
  - ld_impl_linux-64=2.40=h12ee557_0
  - libffi=3.4.4=h6a678d5_1
  - libgcc-ng=11.2.0=h1234567_1
  - libgomp=11.2.0=h1234567_1
  - libstdcxx-ng=11.2.0=h1234567_1
  - libuuid=1.41.5=h5eee18b_0
  - ncurses=6.4=h6a678d5_0
  - openssl=3.0.15=h5eee18b_0
  - pip=25.0=py311h06a4308_0
  - python=3.11.11=he870216_0
  - readline=8.2=h5eee18b_0
  - sqlite=3.45.3=h5eee18b_0
  - tk=8.6.14=h39e8969_0
  - tzdata=2025a=h04d1e81_0
  - xz=5.6.4=h5eee18b_1
  - zlib=1.2.13=h5eee18b_1
  - pip:
      - alabaster==0.7.12
      - asgiref==3.5.2
      - attrs==21.4.0
      - babel==2.10.3
      - blinker==1.4
      - build==0.8.0
      - certifi==2022.6.15
      - cffi==1.15.1
      - cfgv==3.3.1
      - charset-normalizer==2.1.0
      - click==8.1.3
      - cryptography==37.0.4
      - distlib==0.3.4
      - docutils==0.17.1
      - filelock==3.7.1
      - identify==2.5.1
      - idna==3.3
      - imagesize==1.4.1
      - iniconfig==1.1.1
      - itsdangerous==2.1.2
      - jinja2==3.1.2
      - markupsafe==2.1.1
      - mypy==0.961
      - mypy-extensions==0.4.3
      - nodeenv==1.7.0
      - packaging==21.3
      - pallets-sphinx-themes==2.0.2
      - pep517==0.12.0
      - pip-compile-multi==2.4.5
      - pip-tools==6.8.0
      - platformdirs==2.5.2
      - pluggy==1.0.0
      - pre-commit==2.20.0
      - py==1.11.0
      - pycparser==2.21
      - pygments==2.12.0
      - pyparsing==3.0.9
      - pytest==7.1.2
      - python-dotenv==0.20.0
      - pytz==2022.1
      - pyyaml==6.0
      - requests==2.28.1
      - setuptools==70.0.0
      - six==1.16.0
      - snowballstemmer==2.2.0
      - sphinx==4.5.0
      - sphinx-issues==3.0.1
      - sphinx-tabs==3.3.1
      - sphinxcontrib-applehelp==1.0.2
      - sphinxcontrib-devhelp==1.0.2
      - sphinxcontrib-htmlhelp==2.0.0
      - sphinxcontrib-jsmath==1.0.1
      - sphinxcontrib-log-cabinet==1.0.1
      - sphinxcontrib-qthelp==1.0.3
      - sphinxcontrib-serializinghtml==1.1.5
      - toml==0.10.2
      - tomli==2.0.1
      - toposort==1.7
      - tox==3.25.1
      - types-contextvars==2.4.7
      - types-dataclasses==0.6.6
      - types-setuptools==62.6.1
      - typing-extensions==4.3.0
      - urllib3==1.26.10
      - virtualenv==20.15.1
      - werkzeug==2.3.7
      - wheel==0.37.1
prefix: /opt/miniconda3/envs/testbed

EOF_402e20f4124a
conda env create -f /root/environment.yml
conda activate testbed
EOF_eb2627606583


RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" > /root/.bashrc

RUN <<EOF_c379745fc7a1
#!/bin/bash
set -euxo pipefail
git clone -o origin --single-branch https://github.com/pallets/flask /testbed
cd /testbed
git reset --hard 97298e06fe19298c3ff9d2e0ed9ba70bb3fda2c8
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci 97298e06fe19298c3ff9d2e0ed9ba70bb3fda2c8)
TARGET_EPOCH=$(git show -s --format=%ct 97298e06fe19298c3ff9d2e0ed9ba70bb3fda2c8)
for tag in $(git tag -l); do TAG_EPOCH=$(git log -1 --format=%ct "$tag" 2>/dev/null || echo 0); if [ "${TAG_EPOCH:-0}" -gt "$TARGET_EPOCH" ]; then git tag -d "$tag" >/dev/null 2>&1 || true; fi; done
git branch | grep -v '^\*' | xargs -r git branch -D || true
git reflog expire --expire=now --all
git gc --prune=now --aggressive
AFTER_TIMESTAMP=$(date -d "$TARGET_TIMESTAMP + 1 second" '+%Y-%m-%d %H:%M:%S')
COMMIT_COUNT=$(git log --oneline --all --since="$AFTER_TIMESTAMP" | wc -l)
[ "$COMMIT_COUNT" -eq 0 ] || exit 1
chmod -R 777 /testbed
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
EOF_c379745fc7a1


WORKDIR /testbed/
