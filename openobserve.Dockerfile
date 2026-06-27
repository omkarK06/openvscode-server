FROM node:22-bullseye

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	git \
	python3 \
	python3-pip \
	curl \
	build-essential \
	libstdc++6 \
	gcc \
	g++ \
	make \
	libx11-dev \
	libxkbfile-dev \
	libsecret-1-dev \
	libnotify4 \
	libnss3 \
	libasound2 \
	libgbm1 \
	libgtk-3-dev \
	&& apt-get clean \
	&& rm -rf /var/cache/apt/* && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*

# Set working directory
WORKDIR /app

# Clone the sample tracing repository
RUN git clone --depth 1 https://github.com/openobserve/sample-tracing-python.git

# Clone the OpenVSCode repository
RUN git clone --depth 1 https://github.com/omkarK06/openvscode-server.git

# Set working directory for the OpenVSCode repository
WORKDIR /app/openvscode-server

# Add the upstream remote manually if not set
RUN git remote add upstream https://github.com/omkarK06/openvscode-server.git

# Fetch all branches from the upstream remote
RUN git fetch upstream

# Checkout the specific branch
RUN git checkout upstream/omkark06/o2_actions_vscode

# Install dependencies
RUN rm -rf node_modules && npm cache clean --force && npm install

# Build the project
RUN yarn gulp vscode-reh-web-linux-x64-min

# Set working directory for built OpenVSCode
WORKDIR /app/vscode-reh-web-linux-x64

# Clone and build the OpenObserve extension
RUN mkdir builtin-extensions

WORKDIR /app/vscode-reh-web-linux-x64/builtin-extensions
RUN git clone --depth 1 https://github.com/openobserve/actions-vscode-extension.git

WORKDIR /app/vscode-reh-web-linux-x64/builtin-extensions/actions-vscode-extension
RUN npm install && npm run compile

# Clean up the OpenVSCode server repo after building
WORKDIR /app
RUN rm -rf openvscode-server

# Set entrypoint (adjust if needed)
WORKDIR /app
CMD ["node", "vscode-reh-web-linux-x64/out/server-main.js", "--default-folder", "sample-tracing-python", "--disable-workspace-trust", "--host", "0.0.0.0", "--port", "9888"]
