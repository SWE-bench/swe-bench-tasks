
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

RUN <<EOF_948030431112
#!/bin/bash
set -euxo pipefail
source /opt/miniconda3/bin/activate
cat <<'EOF_539278f15a08' > /root/environment.yml
name: testbed
channels:
  - defaults
  - conda-forge
dependencies:
  - _libgcc_mutex=0.1=main
  - _openmp_mutex=5.1=1_gnu
  - bzip2=1.0.8=h5eee18b_6
  - ca-certificates=2024.9.24=h06a4308_0
  - ld_impl_linux-64=2.40=h12ee557_0
  - libffi=3.4.4=h6a678d5_1
  - libgcc-ng=11.2.0=h1234567_1
  - libgomp=11.2.0=h1234567_1
  - libstdcxx-ng=11.2.0=h1234567_1
  - libuuid=1.41.5=h5eee18b_0
  - ncurses=6.4=h6a678d5_0
  - openssl=3.0.15=h5eee18b_0
  - pip=24.2=py311h06a4308_0
  - python=3.11.10=he870216_0
  - readline=8.2=h5eee18b_0
  - setuptools=75.1.0=py311h06a4308_0
  - sqlite=3.45.3=h5eee18b_0
  - tk=8.6.14=h39e8969_0
  - tzdata=2024b=h04d1e81_0
  - xz=5.4.6=h5eee18b_1
  - zlib=1.2.13=h5eee18b_1
  - pip:
      - alabaster==0.7.13
      - asgiref==3.6.0
      - babel==2.12.1
      - build==0.10.0
      - cachetools==5.3.0
      - certifi==2022.12.7
      - cffi==1.15.1
      - cfgv==3.3.1
      - chardet==5.1.0
      - charset-normalizer==3.1.0
      - click==8.1.3
      - colorama==0.4.6
      - cryptography==40.0.1
      - distlib==0.3.6
      - docutils==0.17.1
      - filelock==3.11.0
      - identify==2.5.22
      - idna==3.4
      - imagesize==1.4.1
      - iniconfig==2.0.0
      - itsdangerous==2.1.2
      - jinja2==3.1.2
      - markupsafe==2.1.1
      - mypy==1.2.0
      - mypy-extensions==1.0.0
      - nodeenv==1.7.0
      - packaging==23.0
      - pallets-sphinx-themes==2.0.3
      - pip-compile-multi==2.6.2
      - pip-tools==6.13.0
      - platformdirs==3.2.0
      - pluggy==1.0.0
      - pre-commit==3.2.2
      - pycparser==2.21
      - pygments==2.15.0
      - pyproject-api==1.5.1
      - pyproject-hooks==1.0.0
      - pytest==7.3.0
      - python-dotenv==1.0.0
      - pyyaml==6.0
      - requests==2.28.2
      - snowballstemmer==2.2.0
      - sphinx==4.5.0
      - sphinx-issues==3.0.1
      - sphinx-tabs==3.3.1
      - sphinxcontrib-applehelp==1.0.4
      - sphinxcontrib-devhelp==1.0.2
      - sphinxcontrib-htmlhelp==2.0.1
      - sphinxcontrib-jsmath==1.0.1
      - sphinxcontrib-log-cabinet==1.0.1
      - sphinxcontrib-qthelp==1.0.3
      - sphinxcontrib-serializinghtml==1.1.5
      - toposort==1.10
      - tox==4.4.11
      - types-contextvars==2.4.7.2
      - types-dataclasses==0.6.6
      - types-setuptools==67.6.0.7
      - typing-extensions==4.5.0
      - urllib3==1.26.15
      - virtualenv==20.21.0
      - werkzeug==2.3.7
      - wheel==0.40.0
prefix: /opt/miniconda3/envs/testbed

EOF_539278f15a08
conda env create -f /root/environment.yml
conda activate testbed
EOF_948030431112


RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" > /root/.bashrc

RUN <<EOF_afc30ce01810
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/pallets/flask /testbed
chmod -R 777 /testbed
cd /testbed
git reset --hard 7ee9ceb71e868944a46e1ff00b506772a53a4f1d
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci 7ee9ceb71e868944a46e1ff00b506772a53a4f1d)
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
EOF_afc30ce01810


WORKDIR /testbed/
