FROM mcr.microsoft.com/devcontainers/ruby:2-3.4-bullseye
USER root
# Install Rails
RUN su vscode -c "gem install rails webdrivers"
RUN su vscode -c "/usr/local/rvm/bin/rvm fix-permissions"

# Default value to allow debug server to serve content over GitHub Codespace's port forwarding service
# The value is a comma-separated list of allowed domains 
ENV RAILS_DEVELOPMENT_HOSTS=".githubpreview.dev,.preview.app.github.dev,.app.github.dev"

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# [Optional] Uncomment this line to install additional gems.
# RUN su vscode -c "gem install <your-gem-names-here>"

# [Optional] Uncomment this line to install global node packages.
# RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && npm install -g <your-package-here>" 2>&1


# --------------------------
# Node.js & npm (Cypress dependency)
# --------------------------
RUN apt-get update && apt-get install -y curl & 
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y nodejs

# --------------------------
# System libraries that Cypress depends on
# --------------------------
RUN apt-get update && apt-get install -y \
    libgtk2.0-0 \
    libgtk-3-0 \
    libgbm1 \
    libnotify-dev \
    libnss3 \
    libxss1 \
    libasound2 \
    xvfb \
    fonts-liberation \
    libappindicator3-1 \
    xauth \
    fluxbox \
    x11vnc \
    imagemagick \
    libmagickwand-dev \
    && rm -rf /var/lib/apt/lists/*

# --------------------------
# Install Cypress
# --------------------------
RUN npm install -g cypress

RUN cypress install

# --------------------------
# Set up VNC port
# --------------------------
EXPOSE 5900
