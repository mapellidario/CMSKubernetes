FROM registry.cern.ch/cmsweb/dmwm-base:20250327
MAINTAINER Valentin Kuznetsov vkuznet@gmail.com
# TAG to be passed at build time through `--build-arg TAG=<PYPI_TAG>`. Default: None
ARG TAG=None

# new install
ENV WMA_PKG=global-workqueue
ENV REPO=mapellidario
ADD install_from_src.sh ${WMA_ROOT_DIR}/install_from_src.sh
# Install the requested WMA_TAG.
RUN ${WMA_ROOT_DIR}/install_from_src.sh -t ${TAG} -p ${WMA_PKG} -r ${REPO}
# old install
#RUN pip install global-workqueue==$TAG

ENV WDIR=/data
ENV USER=_workqueue
RUN useradd ${USER} && install -o ${USER} -d ${WDIR}
RUN echo "%$USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER ${USER}
RUN sudo chown -R $USER.$USER $WDIR
WORKDIR $WDIR
CMD ["python3"]
