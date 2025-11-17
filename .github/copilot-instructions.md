# Theia Docker Build - AI Coding Agent Instructions

## Project Overview
This is a **Theia IDE browser application** packaged for Docker deployment. The project creates a web-based VS Code-like IDE using the Theia framework, configured to run entirely in the browser without requiring desktop installation.

## Architecture & Key Components

### Multi-Stage Docker Build
- **Stage 1 (build-stage)**: Full Node.js environment with native compilation tools
  - Installs system dependencies for native modules (libx11-dev, libxkbfile-dev, libsecret-1-dev)
  - Downloads Theia plugins and builds the application
- **Stage 2 (runtime)**: Minimal Node.js slim image with only built artifacts
  - Runs as unprivileged `theia` user for security
  - Exposes port 3000 for browser access

### Theia Configuration (`package.json`)
- **Target**: `"browser"` - crucial distinction from Electron/desktop builds
- **Application Name**: "Theia Browser" (customizable via frontend config)
- **Plugin System**: Uses `theiaPluginsDir: "plugins"` with VS Code extension compatibility
- **Core Dependencies**: Minimal set focusing on editor, filesystem, terminal, and Monaco integration

## Development Workflows

### Building & Running
```bash
# Docker build (preferred method)
docker build -t theia-browser .
docker run -p 3000:3000 theia-browser

# Local development (requires native deps)
yarn install
yarn build        # Production build
yarn watch        # Development with hot reload
yarn start        # Start with local plugin directory
```

### Plugin Management
- Plugins are downloaded during Docker build via `yarn theia download:plugins`
- VS Code extensions work via `theiaPlugins` configuration
- Local plugins go in `plugins/` directory (referenced in start script)

## Project-Specific Patterns

### Security Model
- **No file trash**: `"files.enableTrash": false` - appropriate for containerized environments
- **Unprivileged execution**: Runtime container uses non-root `theia` user
- **Network binding**: Explicitly binds to `0.0.0.0` for container accessibility

### Browser-First Design
- All Theia packages selected for browser compatibility (no Electron dependencies)
- Monaco editor integration for VS Code-like experience
- Terminal functionality works through browser WebSocket connections

### Dependency Strategy
- Uses `"latest"` versions for rapid iteration (consider pinning for production)
- Minimal core package set - add specific Theia extensions as needed
- Native dependencies isolated to build stage only

## Integration Points

### Plugin Ecosystem
- VS Code extensions via `.vsix` files (see vscode-builtin-json example)
- Theia-native plugins via npm packages
- Plugin discovery through `theiaPluginsDir` and remote URLs

### Container Orchestration
- Port 3000 is the standard Theia browser port
- Volume mounts can provide persistent workspace storage
- Environment variables can override Theia configuration

## When Making Changes

### Adding Extensions
1. Add to `theiaPlugins` object with version/URL
2. Rebuild Docker image to download during build
3. For development: place in `plugins/` directory

### Configuration Updates
- Frontend preferences go in `package.json` → `theia.frontend.config.preferences`
- Backend configuration via command line args in Dockerfile CMD
- Plugin-specific config may require separate configuration files

### Performance Considerations
- Browser target means all processing happens in container backend
- Large workspaces may need memory limits adjustment
- Plugin loading affects startup time - minimize unnecessary extensions