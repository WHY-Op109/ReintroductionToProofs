FROM mcr.microsoft.com/devcontainers/javascript-node:26-bookworm

# The game server (leangame). The `main` branch is used because the game uses a Lean release
# candidate, and leangame only has tags for stable Lean versions. It finds the game as a sibling
# folder in `/workspaces`, which only root can write to. Docker caches this step: to get a newer
# `main`, rebuild without cache.
COPY lean-toolchain /tmp/lean-toolchain
RUN git clone --depth 1 --branch main https://github.com/leanprover-community/lean4game.git /workspaces/leangame \
  && chown -R node:node /workspaces/leangame

USER node

# the browser for the tests of the game server is not needed
RUN cd /workspaces/leangame && CYPRESS_INSTALL_BINARY=0 npm ci && npm cache clean --force

# install elan and the Lean toolchain of the game
RUN curl https://elan.lean-lang.org/elan-init.sh -sSf \
  | sh -s -- -y --default-toolchain "$(cat /tmp/lean-toolchain)"
ENV PATH="/home/node/.elan/bin:${PATH}"
