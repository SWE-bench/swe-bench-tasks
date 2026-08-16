
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

RUN <<EOF_c388a5e414af
#!/bin/bash
set -euxo pipefail
source /opt/miniconda3/bin/activate
conda create -n testbed python=3.9 -y
conda activate testbed

# Create requirements file
cat > /root/requirements.txt << 'REQUIREMENTS_EOF'
matplotlib<3.7.3
numpy<1.26.0
pillow<10.1.0
pooch<1.8.0
scooby>=0.5.1,<0.8.0

cmocean<3.1
colorcet<3.1.0
hypothesis<6.83.1
imageio<2.32.0
imageio-ffmpeg<0.5.0
ipython<9.0.0
ipywidgets<9.0.0
meshio<5.4.0
nest_asyncio<1.5.8
numpydoc==1.5.0
param<1.14.0
pytest<7.5.0
pytest-cov<4.2.0
pytest-memprof<0.3.0
pytest-xdist<3.4.0
pytest_pyvista==0.1.8
Sphinx<7.2.0
sphinx-gallery<0.15.0
sympy<1.13.0
tqdm<4.67.0
trame>=2.5.2,<3.3
trame-vtk>=2.5.8,<2.6
trame-vuetify>=2.3.1,<2.4
trimesh<3.24.0

REQUIREMENTS_EOF

# Install requirements
python -m pip install -r /root/requirements.txt
rm /root/requirements.txt
conda activate testbed
python -m pip install pytest
EOF_c388a5e414af


RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" > /root/.bashrc

RUN <<EOF_30263852b76f
#!/bin/bash
set -euxo pipefail
git clone -o origin --single-branch https://github.com/pyvista/pyvista /testbed
cd /testbed
git reset --hard 4a44e4c63c6b8d6a3f1db0aa193f4ccb631ed698
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci 4a44e4c63c6b8d6a3f1db0aa193f4ccb631ed698)
TARGET_EPOCH=$(git show -s --format=%ct 4a44e4c63c6b8d6a3f1db0aa193f4ccb631ed698)
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
apt-get update && apt-get install -y ffmpeg libsm6 libxext6 libxrender1
python -m pip install -e .

# Configure git
git config --global user.email setup@swebench.com
git config --global user.name SWE-bench
git commit --allow-empty -am SWE-bench
EOF_30263852b76f


WORKDIR /testbed/
