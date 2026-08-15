
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

RUN <<EOF_d754637d93e6
#!/bin/bash
set -euxo pipefail
source /opt/miniconda3/bin/activate
cat <<'EOF_a0dcba805f00' > /root/environment.yml
name: testbed
channels:
  - defaults
  - conda-forge
dependencies:
  - _libgcc_mutex=0.1=main
  - _openmp_mutex=5.1=1_gnu
  - blas=1.0=openblas
  - bottleneck=1.4.2=py39ha9d4c09_0
  - brotli-python=1.0.9=py39h6a678d5_9
  - bzip2=1.0.8=h5eee18b_6
  - c-ares=1.19.1=h5eee18b_0
  - ca-certificates=2025.2.25=h06a4308_0
  - contourpy=1.0.5=py39hdb19cb5_0
  - cycler=0.11.0=pyhd3eb1b0_0
  - cyrus-sasl=2.1.28=h52b45da_1
  - cython=3.0.10=py39h5eee18b_0
  - exceptiongroup=1.2.0=py39h06a4308_0
  - expat=2.6.4=h6a678d5_0
  - fontconfig=2.14.1=h55d465d_3
  - fonttools=4.55.3=py39h5eee18b_0
  - freetype=2.12.1=h4a9f257_0
  - icu=73.1=h6a678d5_0
  - iniconfig=1.1.1=pyhd3eb1b0_0
  - joblib=1.4.2=py39h06a4308_0
  - jpeg=9e=h5eee18b_3
  - kiwisolver=1.4.4=py39h6a678d5_0
  - krb5=1.20.1=h143b758_1
  - lcms2=2.16=hb9589c4_0
  - ld_impl_linux-64=2.40=h12ee557_0
  - lerc=4.0.0=h6a678d5_0
  - libabseil=20240116.2=cxx17_h6a678d5_0
  - libcups=2.4.2=h2d74bed_1
  - libcurl=8.12.1=hc9e6f67_0
  - libdeflate=1.22=h5eee18b_0
  - libedit=3.1.20230828=h5eee18b_0
  - libev=4.33=h7f8727e_1
  - libffi=3.4.4=h6a678d5_1
  - libgcc=14.2.0=h767d61c_2
  - libgcc-ng=14.2.0=h69a702a_2
  - libgfortran-ng=7.5.0=ha8ba4b0_17
  - libgfortran4=7.5.0=ha8ba4b0_17
  - libgfortran5=14.2.0=hf1ad2bd_2
  - libglib=2.78.4=hdc74915_0
  - libgomp=14.2.0=h767d61c_2
  - libiconv=1.16=h5eee18b_3
  - libnghttp2=1.57.0=h2d74bed_0
  - libopenblas=0.3.21=h043d6bf_0
  - libpng=1.6.39=h5eee18b_0
  - libpq=17.2=hdbd6064_0
  - libprotobuf=4.25.3=he621ea3_0
  - libssh2=1.11.1=h251f7ec_0
  - libstdcxx-ng=11.2.0=h1234567_1
  - libtiff=4.5.1=hffd6297_1
  - libuuid=1.41.5=h5eee18b_0
  - libwebp-base=1.3.2=h5eee18b_1
  - libxcb=1.15=h7f8727e_0
  - libxkbcommon=1.0.1=h097e994_2
  - libxml2=2.13.5=hfdd30dd_0
  - lz4-c=1.9.4=h6a678d5_1
  - matplotlib=3.6.2=py39h06a4308_0
  - matplotlib-base=3.6.2=py39h945d387_0
  - mysql=8.4.0=h29a9f33_1
  - ncurses=6.4=h6a678d5_0
  - numexpr=2.8.4=py39hd2a5715_1
  - numpy=1.19.2=py39hc896f84_1
  - numpy-base=1.19.2=py39h21a3de8_1
  - openjpeg=2.5.2=he7f1fd0_0
  - openldap=2.6.4=h42fbc30_0
  - openssl=3.0.15=h5eee18b_0
  - packaging=24.2=py39h06a4308_0
  - pandas=1.4.4=py39h6a678d5_0
  - pcre2=10.42=hebb0a14_1
  - pillow=11.1.0=py39hcea889d_0
  - pip=25.0=py39h06a4308_0
  - pluggy=1.5.0=py39h06a4308_0
  - pyparsing=3.2.0=py39h06a4308_0
  - pyqt=6.7.1=py39h6a678d5_0
  - pyqt6-sip=13.9.1=py39h5eee18b_0
  - pytest=8.3.4=py39h06a4308_0
  - python=3.9.21=he870216_1
  - python-dateutil=2.9.0post0=py39h06a4308_2
  - pytz=2024.1=py39h06a4308_0
  - qtbase=6.7.2=hdaa5aa8_1
  - qtdeclarative=6.7.2=h6a678d5_0
  - qtsvg=6.7.2=he621ea3_0
  - qttools=6.7.2=h80c7b02_0
  - qtwebchannel=6.7.2=h6a678d5_0
  - qtwebsockets=6.7.2=h6a678d5_0
  - readline=8.2=h5eee18b_0
  - scipy=1.5.2=py39hf56f3a7_0
  - setuptools=75.8.0=py39h06a4308_0
  - sip=6.10.0=py39h6a678d5_0
  - six=1.16.0=pyhd3eb1b0_1
  - sqlite=3.45.3=h5eee18b_0
  - threadpoolctl=3.5.0=py39h2f386ee_0
  - tk=8.6.14=h39e8969_0
  - tomli=2.0.1=py39h06a4308_0
  - tornado=6.4.2=py39h5eee18b_0
  - tzdata=2025a=h04d1e81_0
  - unicodedata2=15.1.0=py39h5eee18b_1
  - wheel=0.45.1=py39h06a4308_0
  - xcb-util-cursor=0.1.4=h5eee18b_0
  - xz=5.6.4=h5eee18b_1
  - zlib=1.2.13=h5eee18b_1
  - zstd=1.5.6=hc292b87_0
prefix: /opt/miniconda3/envs/testbed

EOF_a0dcba805f00
conda env create -f /root/environment.yml
conda activate testbed
EOF_d754637d93e6


RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" > /root/.bashrc

RUN <<EOF_25dcd46b34db
#!/bin/bash
set -euxo pipefail
git clone -o origin --single-branch https://github.com/scikit-learn/scikit-learn /testbed
cd /testbed
git reset --hard c3bfe86b45577a9405a4680d9971efa9594a0657
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci c3bfe86b45577a9405a4680d9971efa9594a0657)
TARGET_EPOCH=$(git show -s --format=%ct c3bfe86b45577a9405a4680d9971efa9594a0657)
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
python -m pip install -v --no-use-pep517 --no-build-isolation -e .

# Configure git
git config --global user.email setup@swebench.com
git config --global user.name SWE-bench
git commit --allow-empty -am SWE-bench
EOF_25dcd46b34db


WORKDIR /testbed/
