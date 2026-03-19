
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

RUN <<EOF_594218b5bc4f
#!/bin/bash
set -euxo pipefail
source /opt/miniconda3/bin/activate
cat <<'EOF_205b8830023a' > /root/environment.yml
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
      - asttokens==2.4.1
      - attrs==23.1.0
      - certifi==2024.8.30
      - contourpy==1.3.0
      - coverage==7.6.2
      - cycler==0.12.1
      - decorator==5.1.1
      - exceptiongroup==1.1.3
      - execnet==2.0.2
      - executing==2.1.0
      - fonttools==4.54.1
      - hypothesis==6.82.6
      - importlib-resources==6.4.5
      - iniconfig==2.0.0
      - ipython==8.18.1
      - jedi==0.19.1
      - jinja2==3.1.4
      - jplephem==2.22
      - kiwisolver==1.4.7
      - markupsafe==3.0.2
      - matplotlib==3.9.2
      - matplotlib-inline==0.1.7
      - numpy==1.25.2
      - objgraph==3.6.2
      - packaging==23.1
      - parso==0.8.4
      - pexpect==4.9.0
      - pillow==11.0.0
      - pluggy==1.3.0
      - prompt-toolkit==3.0.48
      - psutil==5.9.5
      - ptyprocess==0.7.0
      - pure-eval==0.2.3
      - pyerfa==2.0.0.3
      - pygments==2.18.0
      - pyparsing==3.2.0
      - pytest==7.1.2
      - pytest-arraydiff==0.5.0
      - pytest-astropy==0.10.0
      - pytest-astropy-header==0.2.2
      - pytest-cov==4.1.0
      - pytest-doctestplus==1.0.0
      - pytest-filter-subpackage==0.1.2
      - pytest-mock==3.11.1
      - pytest-mpl==0.17.0
      - pytest-openfiles==0.5.0
      - pytest-remotedata==0.4.0
      - pytest-xdist==3.3.1
      - python-dateutil==2.9.0.post0
      - pyyaml==6.0.1
      - setuptools==58.0.0
      - sgp4==2.23
      - six==1.16.0
      - skyfield==1.49
      - sortedcontainers==2.4.0
      - stack-data==0.6.3
      - tomli==2.0.1
      - traitlets==5.14.3
      - typing-extensions==4.12.2
      - wcwidth==0.2.13
      - zipp==3.20.2
      - py==1.11.0
prefix: /opt/miniconda3/envs/testbed

EOF_205b8830023a
conda env create -f /root/environment.yml
conda activate testbed
EOF_594218b5bc4f


RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" > /root/.bashrc

RUN <<EOF_9fd3a8b4828d
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/astropy/astropy /testbed
chmod -R 777 /testbed
cd /testbed
git reset --hard a85a0747c54bac75e9c3b2fe436b105ea029d6cf
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci a85a0747c54bac75e9c3b2fe436b105ea029d6cf)
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
python -m pip install -e .[test] --verbose

# Configure git
git config --global user.email setup@swebench.com
git config --global user.name SWE-bench
git commit --allow-empty -am SWE-bench
EOF_9fd3a8b4828d


WORKDIR /testbed/
