
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

RUN <<EOF_882fe56b9c74
#!/bin/bash
set -euxo pipefail
source /opt/miniconda3/bin/activate
cat <<'EOF_9fd818c137a9' > /root/environment.yml
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
  - xz=5.4.6=h5eee18b_1
  - zlib=1.2.13=h5eee18b_1
  - pip:
      - alabaster==0.7.12
      - asgiref==3.4.1
      - attrs==21.2.0
      - babel==2.9.1
      - backports-entry-points-selectable==1.1.0
      - blinker==1.4
      - certifi==2021.5.30
      - cffi==1.14.6
      - cfgv==3.3.1
      - charset-normalizer==2.0.6
      - click==8.0.1
      - cryptography==35.0.0
      - distlib==0.3.3
      - docutils==0.16
      - filelock==3.2.0
      - greenlet==1.1.2
      - identify==2.2.15
      - idna==3.2
      - imagesize==1.2.0
      - iniconfig==1.1.1
      - itsdangerous==2.1.2
      - jinja2==3.0.1
      - markupsafe==2.1.3
      - mypy==0.910
      - mypy-extensions==0.4.3
      - nodeenv==1.6.0
      - packaging==21.0
      - pallets-sphinx-themes==2.0.1
      - pep517==0.11.0
      - pip-tools==6.3.0
      - platformdirs==2.4.0
      - pluggy==1.0.0
      - pre-commit==2.15.0
      - py==1.10.0
      - pycparser==2.20
      - pygments==2.10.0
      - pyparsing==2.4.7
      - pytest==6.2.5
      - python-dotenv==0.19.0
      - pytz==2021.1
      - pyyaml==5.4.1
      - requests==2.26.0
      - setuptools==70.0.0
      - six==1.16.0
      - snowballstemmer==2.1.0
      - sphinx==4.2.0
      - sphinx-issues==1.2.0
      - sphinx-tabs==3.2.0
      - sphinxcontrib-applehelp==1.0.2
      - sphinxcontrib-devhelp==1.0.2
      - sphinxcontrib-htmlhelp==2.0.0
      - sphinxcontrib-jsmath==1.0.1
      - sphinxcontrib-log-cabinet==1.0.1
      - sphinxcontrib-qthelp==1.0.3
      - sphinxcontrib-serializinghtml==1.1.5
      - toml==0.10.2
      - tomli==1.2.1
      - tox==3.24.4
      - types-contextvars==0.1.4
      - types-dataclasses==0.1.7
      - types-setuptools==57.4.0
      - typing-extensions==3.10.0.2
      - urllib3==1.26.7
      - virtualenv==20.8.1
      - werkzeug==2.3.7
      - wheel==0.37.0
prefix: /opt/miniconda3/envs/testbed

EOF_9fd818c137a9
conda env create -f /root/environment.yml
conda activate testbed
EOF_882fe56b9c74


RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" > /root/.bashrc

RUN <<EOF_9efa03c81df0
#!/bin/bash
set -euxo pipefail
git clone -o origin --single-branch https://github.com/pallets/flask /testbed
cd /testbed
git reset --hard 06cf349bb8b69d9946c3a6a64d32eb552cc7c28b
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci 06cf349bb8b69d9946c3a6a64d32eb552cc7c28b)
TARGET_EPOCH=$(git show -s --format=%ct 06cf349bb8b69d9946c3a6a64d32eb552cc7c28b)
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
EOF_9efa03c81df0


WORKDIR /testbed/
