FROM python:3.12-alpine
RUN adduser -D -u 65532 app
USER app
WORKDIR /opt/app
COPY app.py .
ENV PORT=8082
EXPOSE 8082
ENTRYPOINT ["python", "app.py"]
