FROM solr:7.7.2-slim
LABEL maintainer="Ank"

COPY --chown=solr:solr ./scripts/intermine.sh /opt/scripts/intermine.sh

EXPOSE 8983
USER $SOLR_USER
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["/opt/scripts/intermine.sh", "biotestmine"]