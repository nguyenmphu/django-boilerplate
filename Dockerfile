FROM python:3.10-alpine AS base

FROM base AS deps

RUN pip install pipenv
COPY Pipfile .
RUN PIPENV_VENV_IN_PROJECT=1 pipenv install --deploy

FROM base AS runtime

COPY --from=deps /.venv/ /.venv/
ENV PATH="/.venv/bin/:$PATH"

WORKDIR /web

COPY . .
ENV PYTHONPATH="/web/app/:$PYTHONPATH"

RUN cd app \
    && python manage.py collectstatic \
    && python manage.py migrate

ENTRYPOINT [ "gunicorn" ]
CMD [ "app.wsgi:application", "-b", "0.0.0.0:8888" ]
