
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

RUN <<EOF_c432e2444953
#!/bin/bash
set -euxo pipefail
source /opt/miniconda3/bin/activate
conda create -n testbed python=3.9 -y
conda activate testbed

# Create requirements file
cat > /root/requirements.txt << 'REQUIREMENTS_EOF'
flake8
flake8-docstrings
black>=22.1.0
flake8-black>=0.2.4
doc8
Pygments
coverage==6.2
hypothesis
pytest
pytest-cov
pytest-sugar
pytest-xdist
mypy
types-toml
types-setuptools
types-chardet
types-appdirs
types-colorama
types-pyyaml
types-Jinja2
types-regex
requests
yamllint

REQUIREMENTS_EOF

# Install requirements
python -m pip install -r /root/requirements.txt
rm /root/requirements.txt
conda activate testbed
EOF_c432e2444953


RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" > /root/.bashrc

RUN <<EOF_3ce9395542e0
#!/bin/bash
set -euxo pipefail
git clone -o origin --single-branch https://github.com/sqlfluff/sqlfluff /testbed
cd /testbed
git reset --hard 305159ea643baf6b4744b98c3566613754b2f659
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci 305159ea643baf6b4744b98c3566613754b2f659)
TARGET_EPOCH=$(git show -s --format=%ct 305159ea643baf6b4744b98c3566613754b2f659)
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
EOF_3ce9395542e0


WORKDIR /testbed/
