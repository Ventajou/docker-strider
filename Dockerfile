FROM node:latest

MAINTAINER Andrew Cutler <macropin@gmail.com>

EXPOSE 3000

ENV STRIDER_VERSION=v1.9.6 STRIDER_GIT_SRC=https://github.com/Strider-CD/strider.git STRIDER_HOME=/data STRIDER_SRC=/opt/strider
ENV NODE_ENV production

RUN useradd --comment "Strider CD" --home ${STRIDER_HOME} strider && mkdir -p ${STRIDER_HOME} && chown strider:strider ${STRIDER_HOME}
VOLUME [ "$STRIDER_HOME" ]

RUN mkdir -p $STRIDER_SRC && cd $STRIDER_SRC && \
    # Checkout into $STRIDER_SRC
    git clone $STRIDER_GIT_SRC . && \
    [ "$STRIDER_VERSION" != 'master' ] && git checkout tags/$STRIDER_VERSION || git checkout master && \
    rm -rf .git && \
    # Install NPM deps
    npm install && \
    # Create link to strider home dir so the modules can be used as a cache
    mv node_modules node_modules.cache && ln -s ${STRIDER_HOME}/node_modules node_modules && \
    # Allow strider user to update .restart file
    chown strider:strider ${STRIDER_SRC}/.restart && \
    # Cleanup Upstream cruft
    rm -rf /tmp/* && \
    mkdir -p $STRIDER_HOME/projects && \
    # take ownership the home folder so we can write stuff in there
    chown -R strider:strider ${STRIDER_HOME}/projects

VOLUME [ "$STRIDER_HOME/projects"]

ENV PATH ${STRIDER_SRC}/bin:$PATH

COPY entry.sh /
USER strider
ENTRYPOINT ["/entry.sh"]
CMD ["strider"]
