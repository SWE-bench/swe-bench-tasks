
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

RUN <<EOF_7724f09cce4e
#!/bin/bash
set -euxo pipefail
source /opt/miniconda3/bin/activate
cat <<'EOF_890442fa12a6' > /root/environment.yml
name: testbed
channels:
  - defaults
  - conda-forge
dependencies:
  - _libgcc_mutex=0.1=main
  - _openmp_mutex=5.1=1_gnu
  - attrs=21.4.0=pyhd3eb1b0_0
  - blas=1.0=openblas
  - ca-certificates=2024.9.24=h06a4308_0
  - certifi=2021.5.30=py36h06a4308_0
  - cycler=0.11.0=pyhd3eb1b0_0
  - cython=0.29.24=py36h295c915_0
  - dbus=1.13.18=hb2f20db_0
  - expat=2.6.3=h6a678d5_0
  - fontconfig=2.14.1=h52c9d5c_1
  - freetype=2.12.1=h4a9f257_0
  - giflib=5.2.1=h5eee18b_3
  - glib=2.69.1=h4ff587b_1
  - gst-plugins-base=1.14.1=h6a678d5_1
  - gstreamer=1.14.1=h5eee18b_1
  - icu=58.2=he6710b0_3
  - importlib-metadata=4.8.1=py36h06a4308_0
  - importlib_metadata=4.8.1=hd3eb1b0_0
  - iniconfig=1.1.1=pyhd3eb1b0_0
  - jpeg=9e=h5eee18b_3
  - kiwisolver=1.3.1=py36h2531618_0
  - lcms2=2.12=h3be6417_0
  - ld_impl_linux-64=2.40=h12ee557_0
  - lerc=3.0=h295c915_0
  - libdeflate=1.17=h5eee18b_1
  - libffi=3.3=he6710b0_2
  - libgcc-ng=11.2.0=h1234567_1
  - libgfortran-ng=7.5.0=ha8ba4b0_17
  - libgfortran4=7.5.0=ha8ba4b0_17
  - libgomp=11.2.0=h1234567_1
  - libopenblas=0.3.18=hf726d26_0
  - libpng=1.6.39=h5eee18b_0
  - libstdcxx-ng=11.2.0=h1234567_1
  - libtiff=4.5.1=h6a678d5_0
  - libuuid=1.41.5=h5eee18b_0
  - libwebp=1.2.4=h11a3e52_1
  - libwebp-base=1.2.4=h5eee18b_1
  - libxcb=1.15=h7f8727e_0
  - libxml2=2.9.14=h74e7548_0
  - lz4-c=1.9.4=h6a678d5_1
  - matplotlib=3.3.4=py36h06a4308_0
  - matplotlib-base=3.3.4=py36h62a2d02_0
  - more-itertools=8.12.0=pyhd3eb1b0_0
  - ncurses=6.4=h6a678d5_0
  - numpy=1.19.2=py36h6163131_0
  - numpy-base=1.19.2=py36h75fe3a5_0
  - olefile=0.46=pyhd3eb1b0_0
  - openssl=1.1.1w=h7f8727e_0
  - packaging=21.3=pyhd3eb1b0_0
  - pandas=1.1.5=py36ha9443f7_0
  - pcre=8.45=h295c915_0
  - pillow=8.3.1=py36h5aabda8_0
  - pip=21.2.2=py36h06a4308_0
  - pluggy=0.13.1=py36h06a4308_0
  - py=1.11.0=pyhd3eb1b0_0
  - pyparsing=3.0.4=pyhd3eb1b0_0
  - pyqt=5.9.2=py36h05f1152_2
  - pytest=6.2.4=py36h06a4308_2
  - python=3.6.13=h12debd9_1
  - python-dateutil=2.8.2=pyhd3eb1b0_0
  - pytz=2021.3=pyhd3eb1b0_0
  - qt=5.9.7=h5867ecd_1
  - readline=8.2=h5eee18b_0
  - scipy=1.5.2=py36habc2bb6_0
  - setuptools=58.0.4=py36h06a4308_0
  - sip=4.19.8=py36hf484d3e_0
  - six=1.16.0=pyhd3eb1b0_1
  - sqlite=3.45.3=h5eee18b_0
  - tk=8.6.14=h39e8969_0
  - toml=0.10.2=pyhd3eb1b0_0
  - tornado=6.1=py36h27cfd23_0
  - typing_extensions=4.1.1=pyh06a4308_0
  - wheel=0.37.1=pyhd3eb1b0_0
  - xz=5.4.6=h5eee18b_1
  - zipp=3.6.0=pyhd3eb1b0_0
  - zlib=1.2.13=h5eee18b_1
  - zstd=1.5.6=hc292b87_0
prefix: /opt/miniconda3/envs/testbed

EOF_890442fa12a6
conda env create -f /root/environment.yml
conda activate testbed
EOF_7724f09cce4e


RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" > /root/.bashrc

RUN <<EOF_de9fe497d06c
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/scikit-learn/scikit-learn /testbed
chmod -R 777 /testbed
cd /testbed
git reset --hard 97523985b39ecde369d83352d7c3baf403b60a22
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci 97523985b39ecde369d83352d7c3baf403b60a22)
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
python -m pip install -v --no-use-pep517 --no-build-isolation -e .

# Configure git
git config --global user.email setup@swebench.com
git config --global user.name SWE-bench
git commit --allow-empty -am SWE-bench
EOF_de9fe497d06c


WORKDIR /testbed/
