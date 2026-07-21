FROM julia:1.12.6-bookworm

ENV JULIA_DEPOT_PATH=/opt/julia-depot \
    JULIA_PROJECT=/app \
    JULIA_PKG_PRECOMPILE_AUTO=0

WORKDIR /app

RUN useradd --create-home --uid 10001 --shell /usr/sbin/nologin tcxreader \
    && mkdir -p "${JULIA_DEPOT_PATH}" \
    && chown -R tcxreader:tcxreader "${JULIA_DEPOT_PATH}"

COPY Project.toml ./
RUN julia --project=/app --startup-file=no --history-file=no -e \
    'using Pkg; Pkg.instantiate()'

COPY src/ src/
COPY bin/ bin/
COPY example_data/ example_data/

RUN julia --project=/app --startup-file=no --history-file=no -e \
    'using Pkg; Pkg.precompile(); using TCXReader' \
    && chown -R tcxreader:tcxreader /app "${JULIA_DEPOT_PATH}"

USER tcxreader

ENTRYPOINT ["julia", "--project=/app", "--startup-file=no", "--history-file=no", "/app/bin/tcxreader.jl"]
