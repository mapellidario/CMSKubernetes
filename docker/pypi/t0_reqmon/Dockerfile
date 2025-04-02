FROM registry.cern.ch/cmsweb/dmwm-base:20250327
MAINTAINER Valentin Kuznetsov vkuznet@gmail.com
# TAG to be passed at build time through `--build-arg TAG=<PYPI_TAG>`. Default: None
ARG TAG=None

# new install
ENV WMA_PKG=reqmon
ENV REPO=mapellidario
ADD install_from_src.sh ${WMA_ROOT_DIR}/install_from_src.sh
# Install the requested WMA_TAG.
RUN ${WMA_ROOT_DIR}/install_from_src.sh -t ${TAG} -p ${WMA_PKG} -r ${REPO}
# old install
#RUN pip install reqmgr2==$TAG
#RUN pip install reqmon==$TAG

ENV WDIR=/data
ENV USER=_t0_reqmon
RUN useradd ${USER} && install -o ${USER} -d ${WDIR}
RUN echo "%$USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER ${USER}
RUN sudo chown -R $USER.$USER $WDIR
WORKDIR $WDIR
RUN sed -i -e "s,srv=.*,srv=t0_reqmon,g" run.sh
CMD ["python3"]
