FROM solr:7.7.2-slim
LABEL maintainer="Ank"

COPY ./scripts/intermine.sh /opt/scripts/intermine.sh

EXPOSE 8983
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["/opt/scripts/intermine.sh", "biotestmine"]