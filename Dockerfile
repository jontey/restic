# Take the official static restic binary instead of compiling it here
FROM restic/restic:0.19.1@sha256:136600b6ff6843d61d355f7f71f460a166429f35de6fd11b568fece3c9a4d510 AS restic

# Release phase
FROM alpine:3.22

# Backup options
ENV RESTIC_BACKUP_OPTIONS=""

# Cleanup params
ENV RESTIC_CLEANUP_KEEP_DAILY=7
ENV RESTIC_CLEANUP_KEEP_WEEKLY=5
ENV RESTIC_CLEANUP_KEEP_MONTHLY=12
ENV RESTIC_CLEANUP_KEEP_YEARLY=75
ENV RESTIC_CLEANUP_OPTIONS="--prune"

# Default interval times can be set in cron expression
# Fire at 03:15 every day
ENV CRON_BACKUP_EXPRESSION="15   3  *   *   *"
# Fire at 00:15 on the first day of every month
ENV CRON_CLEANUP_EXPRESSION="15  0  0   *   *"

# Script and config
COPY --from=restic /usr/bin/restic /go/bin/restic
ADD ./target/start_cron.sh /go/bin
ADD ./target/supervisor_restic.ini /etc/supervisor.d/restic.ini

RUN apk update && \
    apk add ca-certificates fuse gnupg openssh supervisor && \
    chmod +x /go/bin/start_cron.sh && \
    mkdir -p /var/log/supervisor && \
    rm -rf /var/cache/apk/*

# Start the process
CMD supervisord -c /etc/supervisord.conf

