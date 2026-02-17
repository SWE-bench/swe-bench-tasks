
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

RUN <<EOF_b4c03f5616a4
#!/bin/bash
set -euxo pipefail
source /opt/miniconda3/bin/activate
cat <<'EOF_88078a922875' > /root/environment.yml
name: testbed
channels:
  - defaults
  - conda-forge
dependencies:
  - _libgcc_mutex=0.1=conda_forge
  - _openmp_mutex=4.5=2_gnu
  - blas=1.0=openblas
  - bottleneck=1.4.2=py39ha9d4c09_0
  - brotli=1.0.9=h5eee18b_8
  - brotli-bin=1.0.9=h5eee18b_8
  - bzip2=1.0.8=h5eee18b_6
  - c-ares=1.19.1=h5eee18b_0
  - ca-certificates=2024.11.26=h06a4308_0
  - contourpy=1.3.0=py39h74842e3_2
  - cycler=0.11.0=pyhd3eb1b0_0
  - cyrus-sasl=2.1.28=h52b45da_1
  - cython=3.0.7=py39h3d6467e_0
  - dbus=1.13.18=hb2f20db_0
  - exceptiongroup=1.2.0=py39h06a4308_0
  - expat=2.6.4=h6a678d5_0
  - fontconfig=2.14.1=h55d465d_3
  - fonttools=4.51.0=py39h5eee18b_0
  - freetype=2.12.1=h4a9f257_0
  - glib=2.78.4=h6a678d5_0
  - glib-tools=2.78.4=h6a678d5_0
  - gst-plugins-base=1.14.1=h6a678d5_1
  - gstreamer=1.14.1=h5eee18b_1
  - icu=73.1=h6a678d5_0
  - importlib_resources=6.4.0=py39h06a4308_0
  - iniconfig=1.1.1=pyhd3eb1b0_0
  - joblib=1.4.2=py39h06a4308_0
  - jpeg=9e=h5eee18b_3
  - kiwisolver=1.4.4=py39h6a678d5_0
  - krb5=1.20.1=h143b758_1
  - lcms2=2.16=hb9589c4_0
  - ld_impl_linux-64=2.40=h12ee557_0
  - lerc=4.0.0=h6a678d5_0
  - libabseil=20240116.2=cxx17_h6a678d5_0
  - libblas=3.9.0=26_linux64_openblas
  - libbrotlicommon=1.0.9=h5eee18b_8
  - libbrotlidec=1.0.9=h5eee18b_8
  - libbrotlienc=1.0.9=h5eee18b_8
  - libcblas=3.9.0=26_linux64_openblas
  - libclang=14.0.6=default_hc6dbbc7_2
  - libclang13=14.0.6=default_he11475f_2
  - libcups=2.4.2=h2d74bed_1
  - libcurl=8.11.1=hc9e6f67_0
  - libdeflate=1.22=h5eee18b_0
  - libedit=3.1.20230828=h5eee18b_0
  - libev=4.33=h7f8727e_1
  - libffi=3.4.4=h6a678d5_1
  - libgcc=14.2.0=h77fa898_1
  - libgcc-ng=14.2.0=h69a702a_1
  - libgfortran-ng=8.2.0=hdf63c60_1
  - libgfortran5=14.2.0=hd5240d6_1
  - libglib=2.78.4=hdc74915_0
  - libgomp=14.2.0=h77fa898_1
  - libiconv=1.16=h5eee18b_3
  - liblapack=3.9.0=26_linux64_openblas
  - libllvm14=14.0.6=hecde1de_4
  - libnghttp2=1.57.0=h2d74bed_0
  - libopenblas=0.3.28=pthreads_h94d23a6_0
  - libpng=1.6.39=h5eee18b_0
  - libpq=17.2=hdbd6064_0
  - libprotobuf=4.25.3=he621ea3_0
  - libssh2=1.11.1=h251f7ec_0
  - libstdcxx=14.2.0=hc0a3c3a_1
  - libstdcxx-ng=14.2.0=h4852527_1
  - libtiff=4.5.1=hffd6297_1
  - libuuid=1.41.5=h5eee18b_0
  - libwebp-base=1.3.2=h5eee18b_1
  - libxcb=1.15=h7f8727e_0
  - libxkbcommon=1.0.1=h097e994_2
  - libxml2=2.13.5=hfdd30dd_0
  - lz4-c=1.9.4=h6a678d5_1
  - matplotlib=3.9.2=py39h06a4308_1
  - matplotlib-base=3.9.2=py39hbfdbfaf_1
  - mysql=8.4.0=h29a9f33_1
  - ncurses=6.4=h6a678d5_0
  - numexpr=2.10.1=py39hd28fd6d_0
  - openjpeg=2.5.2=he7f1fd0_0
  - openldap=2.6.4=h42fbc30_0
  - openssl=3.0.15=h5eee18b_0
  - packaging=24.2=py39h06a4308_0
  - pandas=2.2.3=py39h6a678d5_0
  - pcre2=10.42=hebb0a14_1
  - pillow=11.0.0=py39hcea889d_1
  - pip=24.2=py39h06a4308_0
  - pluggy=1.5.0=py39h06a4308_0
  - ply=3.11=py39h06a4308_0
  - pyparsing=3.2.0=py39h06a4308_0
  - pyqt=5.15.10=py39h6a678d5_0
  - pyqt5-sip=12.13.0=py39h5eee18b_0
  - pytest=7.4.4=py39h06a4308_0
  - python=3.9.21=he870216_1
  - python-dateutil=2.9.0post0=py39h06a4308_2
  - python-tzdata=2023.3=pyhd3eb1b0_0
  - python_abi=3.9=2_cp39
  - pytz=2024.1=py39h06a4308_0
  - qt-main=5.15.2=hb6262e9_11
  - readline=8.2=h5eee18b_0
  - scipy=1.13.0=py39haf93ffa_1
  - setuptools=75.1.0=py39h06a4308_0
  - sip=6.7.12=py39h6a678d5_0
  - six=1.16.0=pyhd3eb1b0_1
  - sqlite=3.45.3=h5eee18b_0
  - threadpoolctl=3.5.0=py39h2f386ee_0
  - tk=8.6.14=h39e8969_0
  - tomli=2.0.1=py39h06a4308_0
  - tornado=6.4.2=py39h5eee18b_0
  - tzdata=2024b=h04d1e81_0
  - unicodedata2=15.1.0=py39h5eee18b_0
  - wheel=0.44.0=py39h06a4308_0
  - xz=5.4.6=h5eee18b_1
  - zipp=3.21.0=py39h06a4308_0
  - zlib=1.2.13=h5eee18b_1
  - zstd=1.5.6=hc292b87_0
  - pip:
      - numpy==1.26.4
prefix: /opt/miniconda3/envs/testbed

EOF_88078a922875
conda env create -f /root/environment.yml
conda activate testbed
EOF_b4c03f5616a4


RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" > /root/.bashrc

RUN <<EOF_312b7958b050
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/scikit-learn/scikit-learn /testbed
chmod -R 777 /testbed
cd /testbed
git reset --hard e886ce4e1444c61b865e7839c9cff5464ee20ace
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci e886ce4e1444c61b865e7839c9cff5464ee20ace)
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
EOF_312b7958b050


WORKDIR /testbed/
