FROM solr:7.7.2-slim
LABEL maintainer="Ank"

COPY --chown=solr:solr ./scripts/* /opt/docker-solr/scripts/

EXPOSE 8983
WORKDIR /opt/solr
USER $SOLR_USER
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["intermine", "intermine"]