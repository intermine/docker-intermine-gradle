FROM solr:8.4.1-slim
LABEL maintainer="Ank"
COPY --chown=solr:solr ./scripts/intermine.sh /opt/scripts/intermine.sh
ENV MEM_OPTS="-Xmx2g -Xms1g"
ENV JAVA_OPTS="$JAVA_OPTS -Dorg.apache.el.parser.SKIP_IDENTIFIER_CHECK=true ${MEM_OPTS} -XX:+UseParallelGC -XX:SoftRefLRUPolicyMSPerMB=1 -XX:MaxHeapFreeRatio=99"
HEALTHCHECK CMD \
  wget -qO - http://localhost:8983/solr/${MINE_NAME:-biotestmine}-search/admin/ping || exit 1
EXPOSE 8983
USER $SOLR_USER
ENTRYPOINT ["docker-entrypoint.sh"]
CMD /opt/scripts/intermine.sh ${MINE_NAME:-biotestmine}
